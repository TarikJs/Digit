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
    @Published var habitHistory: [UUID: [Date: HabitProgress]] = [:] // habitId -> (date -> progress)
    
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
    
    // Helper to create a unique key for a habit/date pair
    private func progressKey(for habit: Habit, date: Date) -> String {
        "\(habit.id.uuidString)-\(calendar.startOfDay(for: date).timeIntervalSince1970)"
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
        habitHistory[habit.id]?[calendar.startOfDay(for: date)]?.progress ?? 0
    }

    // Returns the goal for a given habit on a specific date
    func goal(for habit: Habit, on date: Date) -> Int {
        habitHistory[habit.id]?[calendar.startOfDay(for: date)]?.goal ?? habit.dailyGoal
    }

    // Increment progress for a habit on a specific date (now with race protection)
    func incrementProgress(for habit: Habit, on date: Date) {
        let key = progressKey(for: habit, date: date)
        guard !updatingProgressKeys.contains(key) else { return }
        updatingProgressKeys.insert(key)
        Task {
            let day = calendar.startOfDay(for: date)
            var progress = habitHistory[habit.id]?[day]?.progress ?? 0
            let goal = habitHistory[habit.id]?[day]?.goal ?? habit.dailyGoal
            if progress < goal {
                progress += 1
                await upsertProgress(for: habit, progress: progress, goal: goal, date: day)
                if progress == goal {
                    triggerConfetti(for: habit)
                    onHabitCompleted?()
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
            let day = calendar.startOfDay(for: date)
            var progress = habitHistory[habit.id]?[day]?.progress ?? 0
            let goal = habitHistory[habit.id]?[day]?.goal ?? habit.dailyGoal
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
            // Fetch progress for all habits for the visible calendar range (-3...+3 days from today)
            let today = calendar.startOfDay(for: Date())
            let visibleDates = (-3...3).map { calendar.date(byAdding: .day, value: $0, to: today)! }
            var mergedHabitHistory = self.habitHistory // Start with current history
            for habit in fetchedHabits {
                var dateDict = mergedHabitHistory[habit.id] ?? [:]
                for date in visibleDates {
                    let key = progressKey(for: habit, date: date)
                    if let fetched = try? await progressService.fetchProgress(userId: userId, habitId: habit.id, date: date) {
                        if let local = dateDict[date], dirtyProgressKeys.contains(key) {
                            // If local is dirty, only overwrite if backend matches local
                            if local.progress == fetched.progress && local.goal == fetched.goal {
                                dirtyProgressKeys.remove(key)
                                dateDict[date] = fetched
                            }
                            // else: keep local dirty value
                        } else {
                            dateDict[date] = fetched
                        }
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
        let progressId = habitHistory[habit.id]?[date]?.id ?? UUID()
        let now = Date()
        let progressRow = HabitProgress(
            id: progressId,
            userId: userId,
            habitId: habit.id,
            date: date,
            progress: progress,
            goal: goal,
            createdAt: habitHistory[habit.id]?[date]?.createdAt ?? now,
            updatedAt: now
        )
        let key = progressKey(for: habit, date: date)
        dirtyProgressKeys.insert(key)
        do {
            try await progressService.upsertProgress(progress: progressRow)
            await MainActor.run {
                // Update both habitProgress and habitHistory for the date
                self.habitProgress[habit.id] = progressRow
                if self.habitHistory[habit.id] == nil {
                    self.habitHistory[habit.id] = [:]
                }
                self.habitHistory[habit.id]?[date] = progressRow
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
            var dateDict: [Date: HabitProgress] = [:]
            for progress in progressList {
                dateDict[progress.date] = progress
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
        let day = calendar.startOfDay(for: date)
        if let progress = habitHistory[habit.id]?[day] {
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
} 