import Foundation
import CoreData

protocol HabitLocalStoreProtocol {
    func fetchHabits() async throws -> [Habit]
    func saveHabits(_ habits: [Habit]) async throws
    func saveHabit(_ habit: Habit) async throws
    func deleteHabit(_ habit: Habit) async throws
}

final class HabitLocalStore: HabitLocalStoreProtocol {
    private let context: NSManagedObjectContext
    
    init(context: NSManagedObjectContext = PersistenceController.shared.container.viewContext) {
        self.context = context
    }
    
    func fetchHabits() async throws -> [Habit] {
        let request: NSFetchRequest<HabitEntity> = HabitEntity.fetchRequest()
        let entities = try context.fetch(request)
        return entities.compactMap { $0.toHabit() }
    }
    
    func saveHabits(_ habits: [Habit]) async throws {
        for habit in habits {
            try await saveHabit(habit)
        }
        try context.save()
    }
    
    func saveHabit(_ habit: Habit) async throws {
        let request: NSFetchRequest<HabitEntity> = HabitEntity.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", habit.id as CVarArg)
        let results = try context.fetch(request)
        let entity = results.first ?? HabitEntity(context: context)
        entity.update(from: habit)
        try context.save()
    }
    
    func deleteHabit(_ habit: Habit) async throws {
        let request: NSFetchRequest<HabitEntity> = HabitEntity.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", habit.id as CVarArg)
        let results = try context.fetch(request)
        if let entity = results.first {
            context.delete(entity)
            try context.save()
        }
    }
}

// MARK: - Mapping Extensions
extension HabitEntity {
    func toHabit() -> Habit? {
        guard let id = id,
              let userId = userId,
              let name = name,
              let dailyGoal = dailyGoal as Int32?,
              let icon = icon,
              let startDate = startDate,
              let repeatFrequency = repeatFrequency,
              let createdAt = createdAt,
              let updatedAt = updatedAt
        else { return nil }
        let weekdaysArray = weekdays as? [Int]
        return Habit(
            id: id,
            userId: userId,
            name: name,
            description: descriptionText,
            dailyGoal: Int(dailyGoal),
            icon: icon,
            startDate: startDate,
            endDate: endDate,
            repeatFrequency: repeatFrequency,
            weekdays: weekdaysArray,
            reminderTime: reminderTime,
            createdAt: createdAt,
            updatedAt: updatedAt,
            unit: unit,
            tag: self.tag
        )
    }
    
    func update(from habit: Habit) {
        self.id = habit.id
        self.userId = habit.userId
        self.name = habit.name
        self.descriptionText = habit.description
        self.dailyGoal = Int32(habit.dailyGoal)
        self.icon = habit.icon
        self.startDate = habit.startDate
        self.endDate = habit.endDate
        self.repeatFrequency = habit.repeatFrequency
        self.weekdays = habit.weekdays as NSObject?
        self.reminderTime = habit.reminderTime
        self.createdAt = habit.createdAt
        self.updatedAt = habit.updatedAt
        self.unit = habit.unit
        self.tag = habit.tag
    }
} 