import SwiftUI
import Combine

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
        loadHabitsAndProgressForSelectedDate()
    }
    
    // Returns the progress for a given habit on the selected date
    func progress(for habit: Habit) -> Int {
        habitProgress[habit.id]?.progress ?? 0
    }
    
    func goal(for habit: Habit) -> Int {
        habitProgress[habit.id]?.goal ?? habit.dailyGoal
    }
    
    func incrementProgress(for habit: Habit) {
        Task {
            var progress = habitProgress[habit.id]?.progress ?? 0
            let goal = habitProgress[habit.id]?.goal ?? habit.dailyGoal
            if progress < goal {
                progress += 1
                await upsertProgress(for: habit, progress: progress, goal: goal)
                if progress == goal {
                    triggerConfetti(for: habit)
                    onHabitCompleted?()
                }
            }
        }
    }
    
    func decrementProgress(for habit: Habit) {
        Task {
            var progress = habitProgress[habit.id]?.progress ?? 0
            let goal = habitProgress[habit.id]?.goal ?? habit.dailyGoal
            if progress > 0 {
                progress -= 1
                await upsertProgress(for: habit, progress: progress, goal: goal)
            }
        }
    }
    
    // MARK: - Data Loading
    private func loadInitialData() {
        Task {
            await loadHabitsAndProgressForSelectedDate()
        }
    }
    
    private func setupDateObserver() {
        // Setup any observers if needed
    }
    
    private func loadHabitsAndProgressForSelectedDate() {
        Task { @MainActor in
            self.isLoading = true
            self.errorMessage = nil
        }
        Task {
            do {
                let fetchedHabits = try await habitService.fetchHabits()
                await MainActor.run {
                    self.habits = fetchedHabits
                }
                // Fetch progress for all habits for the selected date
                var progressDict: [UUID: HabitProgress] = [:]
                for habit in fetchedHabits {
                    if let progress = try? await progressService.fetchProgress(userId: userId, habitId: habit.id, date: selectedDate) {
                        progressDict[habit.id] = progress
                    }
                }
                await MainActor.run {
                    self.habitProgress = progressDict
                    self.isLoading = false
                }
            } catch {
                await MainActor.run {
                    self.errorMessage = "Failed to load habits or progress: \(error.localizedDescription)"
                    self.isLoading = false
                }
            }
        }
    }
    
    private func upsertProgress(for habit: Habit, progress: Int, goal: Int) async {
        let progressId = habitProgress[habit.id]?.id ?? UUID()
        let now = Date()
        let progressRow = HabitProgress(
            id: progressId,
            userId: userId,
            habitId: habit.id,
            date: selectedDate,
            progress: progress,
            goal: goal,
            createdAt: habitProgress[habit.id]?.createdAt ?? now,
            updatedAt: now
        )
        do {
            try await progressService.upsertProgress(progress: progressRow)
            await MainActor.run {
                self.habitProgress[habit.id] = progressRow
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
        if let progress = habitHistory[habit.id]?[date] {
            return progress.progress >= progress.goal
        }
        return false
    }
    
    // MARK: - User ID Update
    public func updateUserId(_ newUserId: UUID) {
        self.userId = newUserId
        loadInitialData()
    }
} 