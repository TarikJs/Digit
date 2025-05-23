import Foundation
import CoreData

protocol ProgressLocalStoreProtocol {
    func fetchProgress() async throws -> [HabitProgress]
    func saveProgress(_ progress: HabitProgress) async throws
    func saveProgressList(_ progressList: [HabitProgress]) async throws
    func deleteProgress(_ progress: HabitProgress) async throws
}

final class ProgressLocalStore: ProgressLocalStoreProtocol {
    private let context: NSManagedObjectContext
    
    init(context: NSManagedObjectContext = PersistenceController.shared.container.viewContext) {
        self.context = context
    }
    
    func fetchProgress() async throws -> [HabitProgress] {
        let request: NSFetchRequest<ProgressEntity> = ProgressEntity.fetchRequest()
        let entities = try context.fetch(request)
        return entities.compactMap { $0.toHabitProgress() }
    }
    
    func saveProgress(_ progress: HabitProgress) async throws {
        let request: NSFetchRequest<ProgressEntity> = ProgressEntity.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", progress.id)
        let results = try context.fetch(request)
        let entity = results.first ?? ProgressEntity(context: context)
        entity.update(from: progress)
        try context.save()
    }
    
    func saveProgressList(_ progressList: [HabitProgress]) async throws {
        for progress in progressList {
            try await saveProgress(progress)
        }
        try context.save()
    }
    
    func deleteProgress(_ progress: HabitProgress) async throws {
        let request: NSFetchRequest<ProgressEntity> = ProgressEntity.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", progress.id)
        let results = try context.fetch(request)
        if let entity = results.first {
            context.delete(entity)
            try context.save()
        }
    }
}

// MARK: - Mapping Extensions
extension ProgressEntity {
    func toHabitProgress() -> HabitProgress? {
        guard let id = id,
              let userId = userId,
              let habitId = habitId,
              let date = date
        else { return nil }
        return HabitProgress(
            id: id,
            userId: userId,
            habitId: habitId,
            date: date,
            progress: Int(progress),
            goal: Int(goal),
            createdAt: createdAt,
            updatedAt: updatedAt
        )
    }
    
    func update(from progress: HabitProgress) {
        self.id = progress.id
        self.userId = progress.userId
        self.habitId = progress.habitId
        self.date = progress.date
        self.progress = Int32(progress.progress)
        self.goal = Int32(progress.goal)
        self.createdAt = progress.createdAt
        self.updatedAt = progress.updatedAt
    }
} 