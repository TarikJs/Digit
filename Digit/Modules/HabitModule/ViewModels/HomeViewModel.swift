import SwiftUI
import Combine

@MainActor
final class HomeViewModel: ObservableObject {
    // MARK: - Published Properties
    @Published var selectedDate = Date()
    @Published var habits: [Habit] = []
    @Published var userName: String = "Name Surname"
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published private var habitProgress: [UUID: HabitProgress] = [:] // Key: habit.id
    @Published var confettiHabitID: UUID?
    @Published var confettiDate: String?
    var onHabitCompleted: (() -> Void)?
    @Published var habitHistory: [UUID: [String: HabitProgress]] = [:] // habitId -> (dateString -> progress)
    
    // MARK: - Private Properties
    private var cancellables = Set<AnyCancellable>()
    private let calendar = Calendar.current
    private let habitService: HabitServiceProtocol
    private let progressService: HabitProgressServiceProtocol
    private var userId: UUID
    // Track which (habit, date) pairs are currently updating to prevent race conditions
    private var updatingProgressKeys = Set<String>()
    // Track which (habit, date) pairs have local updates not yet confirmed by backend
    private var dirtyProgressKeys = Set<String>()
    // Use UTC calendar for all progress keying and lookups
    private let utcCalendar: Calendar = {
        var cal = Calendar.current
        cal.timeZone = TimeZone(secondsFromGMT: 0)!
        return cal
    }()
    
    // Helper to create a unique key for a habit/date pair
    private func progressKey(for habit: Habit, date: Date) -> String {
        "\(habit.id.uuidString)-\(utcCalendar.startOfDay(for: date).timeIntervalSince1970)"
    }

    // Expose to UI: is a habit/date currently updating?
    func isUpdatingProgress(for habit: Habit, on date: Date) -> Bool {
        updatingProgressKeys.contains(progressKey(for: habit, date: date))
    }
    
    // MARK: - Initialization
    init(habitService: HabitServiceProtocol, progressService: HabitProgressServiceProtocol, userId: UUID) {
        self.habitService = habitService
        self.progressService = progressService
        self.userId = userId
        loadInitialData()
        setupDateObserver()
    }
    
    // MARK: - Public Methods
    func selectDate(_ date: Date) {
        Task { @MainActor in
            self.selectedDate = calendar.startOfDay(for: date)
        }
        Task {
            await loadHabitsAndProgressForVisibleDates()
        }
    }
    
    // Returns the progress for a given habit on a specific date
    func progress(for habit: Habit, on date: Date) -> Int {
        let key = dateKey(for: date)
        let keys = habitHistory[habit.id]?.keys.map { $0 } ?? []
        print("[DEBUG] progress(for: \(habit.name), on: \(key)) -- available keys: \(keys)")
        if let value = habitHistory[habit.id]?[key]?.progress {
            print("[DEBUG] Found progress for key \(key): \(value)")
            return value
        } else {
            print("[DEBUG] No progress found for key \(key)")
            return 0
        }
    }

    // Returns the goal for a given habit on a specific date
    func goal(for habit: Habit, on date: Date) -> Int {
        let key = dateKey(for: date)
        let keys = habitHistory[habit.id]?.keys.map { $0 } ?? []
        print("[DEBUG] goal(for: \(habit.name), on: \(key)) -- available keys: \(keys)")
        if let value = habitHistory[habit.id]?[key]?.goal {
            print("[DEBUG] Found goal for key \(key): \(value)")
            return value
        } else {
            print("[DEBUG] No goal found for key \(key)")
            return habit.dailyGoal
        }
    }

    // Increment progress for a habit on a specific date (now with race protection)
    func incrementProgress(for habit: Habit, on date: Date) {
        let key = progressKey(for: habit, date: date)
        guard !updatingProgressKeys.contains(key) else { return }
        updatingProgressKeys.insert(key)
        Task {
            let day = utcCalendar.startOfDay(for: date)
            let dateKeyString = dateKey(for: day)
            var progress = habitHistory[habit.id]?[dateKeyString]?.progress ?? 0
            let goal = habitHistory[habit.id]?[dateKeyString]?.goal ?? habit.dailyGoal
            print("[DEBUG] Before increment: progress=\(progress), goal=\(goal)")
            if progress < goal {
                progress += 1
                await upsertProgress(for: habit, progress: progress, goal: goal, date: day)
                await MainActor.run {
                    if self.habitHistory[habit.id] == nil { self.habitHistory[habit.id] = [:] }
                    if self.habitHistory[habit.id]?[dateKeyString] == nil {
                        // If no row exists, create a new HabitProgress for this day
                        let now = Date()
                        self.habitHistory[habit.id]?[dateKeyString] = HabitProgress(
                            id: UUID().uuidString,
                            userId: self.userId.uuidString,
                            habitId: habit.id.uuidString,
                            date: day,
                            progress: progress,
                            goal: goal,
                            createdAt: now,
                            updatedAt: now
                        )
                    } else {
                        self.habitHistory[habit.id]?[dateKeyString]?.progress = progress
                    }
                    print("[DEBUG] After upsert (in-memory, no fetch): progress=\(progress), goal=\(goal)")
                    if progress == goal {
                        triggerConfetti(for: habit)
                        onHabitCompleted?()
                    }
                }
            }
            updatingProgressKeys.remove(key)
        }
    }

    // Decrement progress for a habit on a specific date (now with race protection)
    func decrementProgress(for habit: Habit, on date: Date) {
        let key = progressKey(for: habit, date: date)
        guard !updatingProgressKeys.contains(key) else { return }
        updatingProgressKeys.insert(key)
        Task {
            let day = utcCalendar.startOfDay(for: date)
            var progress = habitHistory[habit.id]?[key]?.progress ?? 0
            let goal = habitHistory[habit.id]?[key]?.goal ?? habit.dailyGoal
            if progress > 0 {
                progress -= 1
                await upsertProgress(for: habit, progress: progress, goal: goal, date: day)
            }
            updatingProgressKeys.remove(key)
        }
    }
    
    // MARK: - Data Loading
    private func loadInitialData() {
        Task {
            await loadHabitsAndProgressForVisibleDates()
        }
    }
    
    private func setupDateObserver() {
        // Setup any observers if needed
    }
    
    private func loadHabitsAndProgressForVisibleDates() async {
        await MainActor.run {
            self.isLoading = true
            self.errorMessage = nil
        }
        do {
            let fetchedHabits = try await habitService.fetchHabits()
            await MainActor.run {
                self.habits = fetchedHabits
            }
            let today = utcCalendar.startOfDay(for: Date())
            let startOfRange = utcCalendar.date(byAdding: .day, value: -89, to: today) ?? today
            var mergedHabitHistory = self.habitHistory
            for habit in fetchedHabits {
                let progressList = try await progressService.fetchProgressForRange(
                    userId: userId,
                    habitId: habit.id,
                    startDate: startOfRange,
                    endDate: today
                )
                let loadedKeys = progressList.map { dateKey(for: $0.date) }
                print("[DEBUG] Loaded progress keys from Supabase for habit \(habit.name): \(loadedKeys)")
                var dateDict = mergedHabitHistory[habit.id] ?? [:]
                for progress in progressList {
                    let key = dateKey(for: progress.date)
                    if let local = dateDict[key], dirtyProgressKeys.contains(progressKey(for: habit, date: progress.date)) {
                        if local.progress == progress.progress && local.goal == progress.goal {
                            dirtyProgressKeys.remove(progressKey(for: habit, date: progress.date))
                        }
                    } else {
                        dateDict[key] = progress
                    }
                }
                mergedHabitHistory[habit.id] = dateDict
            }
            await MainActor.run {
                self.habitHistory = mergedHabitHistory
                self.isLoading = false
            }
        } catch {
            await MainActor.run {
                self.errorMessage = "Failed to load habits or progress: \(error.localizedDescription)"
                self.isLoading = false
            }
        }
    }
    
    private func upsertProgress(for habit: Habit, progress: Int, goal: Int, date: Date) async {
        print("[DEBUG] Upserting progress: habit=\(habit.name), date=\(date), progress=\(progress), goal=\(goal)")
        let key = dateKey(for: date)
        let progressId = habitHistory[habit.id]?[key]?.id ?? UUID().uuidString
        let now = Date()
        let progressRow = HabitProgress(
            id: progressId,
            userId: userId.uuidString,
            habitId: habit.id.uuidString,
            date: date,
            progress: progress,
            goal: goal,
            createdAt: habitHistory[habit.id]?[key]?.createdAt ?? now,
            updatedAt: now
        )
        dirtyProgressKeys.insert(progressKey(for: habit, date: date))
        do {
            try await progressService.upsertProgress(progress: progressRow)
            print("[DEBUG] Upserted progress for habit=\(habit.name), date=\(date), progress=\(progress), goal=\(goal)")
            await MainActor.run {
                self.habitProgress[habit.id] = progressRow
                if self.habitHistory[habit.id] == nil {
                    self.habitHistory[habit.id] = [:]
                }
                self.habitHistory[habit.id]?[key] = progressRow
                print("[DEBUG] After upsert (in-memory): progress=\(progressRow.progress), goal=\(progressRow.goal)")
            }
        } catch {
            await MainActor.run {
                self.errorMessage = "Failed to update progress: \(error.localizedDescription)"
            }
        }
    }
    
    func triggerConfetti(for habit: Habit) {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let dateString = formatter.string(from: selectedDate)
        confettiHabitID = habit.id
        confettiDate = dateString
        print("[DEBUG] triggerConfetti: habitID=\(habit.id), date=\(dateString)")
    }
    
    var selectedDateString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let dateString = formatter.string(from: selectedDate)
        print("[DEBUG] selectedDateString: \(dateString)")
        return dateString
    }
    
    // MARK: - Analytics & History
    /// Fetch all progress for a habit over a date range (for calendar, streaks, analytics)
    func fetchProgressHistory(for habit: Habit, startDate: Date, endDate: Date) async {
        do {
            let progressList = try await progressService.fetchProgressForRange(userId: userId, habitId: habit.id, startDate: startDate, endDate: endDate)
            var dateDict: [String: HabitProgress] = [:]
            for progress in progressList {
                let key = dateKey(for: progress.date)
                dateDict[key] = progress
            }
            await MainActor.run {
                self.habitHistory[habit.id] = dateDict
            }
        } catch {
            await MainActor.run {
                self.errorMessage = "Failed to load progress history: \(error.localizedDescription)"
            }
        }
    }

    /// Check if a habit is completed for a given date
    func isHabitCompleted(_ habit: Habit, on date: Date) -> Bool {
        let key = dateKey(for: date)
        if let progress = habitHistory[habit.id]?[key] {
            return progress.progress >= progress.goal
        }
        return false
    }
    
    // MARK: - User ID Update
    public func updateUserId(_ newUserId: UUID) {
        self.userId = newUserId
        loadInitialData()
    }

    /// Returns the list of habits that are active on a given date (startDate <= date <= endDate, and matches repeatFrequency/weekday if set)
    func activeHabits(on date: Date) -> [Habit] {
        habits.filter { habit in
            let isAfterStart = calendar.startOfDay(for: date) >= calendar.startOfDay(for: habit.startDate)
            let isBeforeEnd = habit.endDate == nil || calendar.startOfDay(for: date) <= calendar.startOfDay(for: habit.endDate!)
            guard isAfterStart && isBeforeEnd else { return false }
            switch habit.repeatFrequency.lowercased() {
            case "daily":
                return true
            case "weekly":
                // If weekdays is set, check if the date's weekday matches
                if let weekdays = habit.weekdays {
                    let weekday = calendar.component(.weekday, from: date) - 1 // 0=Sun, 6=Sat
                    return weekdays.contains(weekday)
                }
                return true
            case "custom":
                if let weekdays = habit.weekdays {
                    let weekday = calendar.component(.weekday, from: date) - 1
                    return weekdays.contains(weekday)
                }
                return true
            default:
                return true
            }
        }
    }

    /// Returns the number of completed habits for a given date
    func completedHabitsCount(on date: Date) -> Int {
        let active = activeHabits(on: date)
        return active.filter { isHabitCompleted($0, on: date) }.count
    }

    private func dateKey(for date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        return formatter.string(from: utcCalendar.startOfDay(for: date))
    }
} 