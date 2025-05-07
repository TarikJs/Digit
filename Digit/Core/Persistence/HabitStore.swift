//
//  HabitStore.swift
//  Digit
//
//  Handles saving and loading habits using UserDefaults and JSON.
//

import Foundation

final class HabitStore {
    private let storageKey = "habits_data"
    private let userDefaults: UserDefaults
    
    init(userDefaults: UserDefaults = .standard) {
        self.userDefaults = userDefaults
    }
    
    func loadHabits() -> [Habit] {
        guard let data = userDefaults.data(forKey: storageKey) else { return [] }
        do {
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            return try decoder.decode([Habit].self, from: data)
        } catch {
            print("Failed to decode habits: \(error)")
            return []
        }
    }
    
    func saveHabits(_ habits: [Habit]) {
        do {
            let encoder = JSONEncoder()
            encoder.dateEncodingStrategy = .iso8601
            let data = try encoder.encode(habits)
            userDefaults.set(data, forKey: storageKey)
        } catch {
            print("Failed to encode habits: \(error)")
        }
    }
} 