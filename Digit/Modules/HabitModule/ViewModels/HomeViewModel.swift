import SwiftUI
import Combine

final class HomeViewModel: ObservableObject {
    // MARK: - Published Properties
    @Published var selectedDate = Date()
    @Published var waterProgress = 0
    @Published var waterGoal = 10
    @Published var bookProgress = 0
    @Published var bookGoal = 30
    @Published var habits: [Habit] = []
    @Published var userName: String = "Name Surname"
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    // MARK: - Private Properties
    private var cancellables = Set<AnyCancellable>()
    private let calendar = Calendar.current
    private let habitService: HabitServiceProtocol
    
    // MARK: - Initialization
    init(habitService: HabitServiceProtocol, /* other params if any */) {
        self.habitService = habitService
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
    
    // MARK: - Data Loading
    private func loadInitialData() {
        // Load initial data if needed
        loadProgress()
        Task {
            await loadHabitsFromBackend()
        }
    }
    
    private func setupDateObserver() {
        // Setup any observers if needed
    }
    
    private func loadHabitsForSelectedDate() {
        isLoading = true
        errorMessage = nil
        Task {
            do {
                let fetchedHabits = try await habitService.fetchHabits()
                await MainActor.run {
                    self.habits = fetchedHabits
                    self.isLoading = false
                }
            } catch {
                await MainActor.run {
                    self.errorMessage = "Failed to load habits: \(error.localizedDescription)"
                    self.isLoading = false
                }
            }
        }
    }
    
    private func loadProgress() {
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
    
    private func loadHabitsFromBackend() async {
        isLoading = true
        errorMessage = nil
        do {
            let fetchedHabits = try await habitService.fetchHabits()
            await MainActor.run {
                self.habits = fetchedHabits
                self.isLoading = false
            }
        } catch {
            await MainActor.run {
                self.errorMessage = "Failed to load habits: \(error.localizedDescription)"
                self.isLoading = false
            }
        }
    }
} 