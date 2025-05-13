import SwiftUI
import Combine

final class HomeViewModel: ObservableObject {
    // MARK: - Published Properties
    @Published var selectedDate = Date()
    @Published var waterProgress = 0
    @Published var waterGoal = 10
    @Published var bookProgress = 0
    @Published var bookGoal = 30
    @Published var habits: [DailyHabit] = []
    @Published var userName: String = "Name Surname"
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    // MARK: - Private Properties
    private var cancellables = Set<AnyCancellable>()
    private let calendar = Calendar.current
    
    // MARK: - Initialization
    init() {
        loadInitialData()
        setupDateObserver()
    }
    
    // MARK: - Public Methods
    func selectDate(_ date: Date) {
        selectedDate = calendar.startOfDay(for: date)
        loadHabitsForSelectedDate()
    }
    
    func incrementWater() {
        waterProgress = min(waterProgress + 1, waterGoal)
        saveProgress()
    }
    
    func incrementBookPages() {
        bookProgress = min(bookProgress + 1, bookGoal)
        saveProgress()
    }
    
    func toggleHabit(_ habitId: String) {
        if let index = habits.firstIndex(where: { $0.id == habitId }) {
            habits[index].isCompleted.toggle()
            saveHabits()
        }
    }
    
    func incrementHabit(_ habitId: String) {
        if let index = habits.firstIndex(where: { $0.id == habitId }) {
            if habits[index].progress < habits[index].goal {
                habits[index].progress += 1
                saveHabits()
            }
        }
    }
    
    func decrementHabit(_ habitId: String) {
        if let index = habits.firstIndex(where: { $0.id == habitId }) {
            if habits[index].progress > 0 {
                habits[index].progress -= 1
                saveHabits()
            }
        }
    }
    
    // MARK: - Private Methods
    private func loadInitialData() {
        isLoading = true
        
        // Load user data
        loadUserProfile()
        
        // Load habits for today
        loadHabitsForSelectedDate()
        
        // Load progress
        loadProgress()
        
        isLoading = false
    }
    
    private func setupDateObserver() {
        // Observe date changes to reload data
        $selectedDate
            .dropFirst()
            .debounce(for: .milliseconds(300), scheduler: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.loadHabitsForSelectedDate()
            }
            .store(in: &cancellables)
    }
    
    private func loadUserProfile() {
        // TODO: Load from UserDefaults or API
        // For now using mock data
        userName = UserDefaults.standard.string(forKey: "userName") ?? "Name Surname"
    }
    
    private func loadHabitsForSelectedDate() {
        // TODO: Load from persistence or API
        // For now using mock data
        habits = [
            DailyHabit(id: "1", title: "Wake up at 9:00", icon: "bed.double.fill", color: .digitHabitPurple, progress: 0, goal: 1),
            DailyHabit(id: "2", title: "Work out", icon: "figure.walk", color: .digitHabitGreen, progress: 2, goal: 5),
            DailyHabit(id: "3", title: "Meditation 30 min", icon: "brain.head.profile", color: .digitHabitPurple, progress: 1, goal: 7),
            DailyHabit(id: "4", title: "No cigarettes", icon: "nosign", color: .digitHabitGreen, progress: 0, goal: 1)
        ]
    }
    
    private func loadProgress() {
        // TODO: Load from persistence or API
        // For now using mock data
        let defaults = UserDefaults.standard
        waterProgress = defaults.integer(forKey: "waterProgress_\(dateKey)")
        bookProgress = defaults.integer(forKey: "bookProgress_\(dateKey)")
    }
    
    private func saveProgress() {
        let defaults = UserDefaults.standard
        defaults.set(waterProgress, forKey: "waterProgress_\(dateKey)")
        defaults.set(bookProgress, forKey: "bookProgress_\(dateKey)")
    }
    
    private func saveHabits() {
        // TODO: Implement persistence
        // For now just print
        print("Saving habits state: \(habits)")
    }
    
    private var dateKey: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: selectedDate)
    }
}

// MARK: - Models
struct DailyHabit: Identifiable {
    let id: String
    let title: String
    let icon: String
    let color: Color
    var isCompleted: Bool = false
    var progress: Int
    var goal: Int
} 