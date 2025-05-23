import Foundation
import CoreData

final class PersistenceController {
    static let shared = PersistenceController()

    let container: NSPersistentContainer

    private init(inMemory: Bool = false) {
        container = NSPersistentContainer(name: "TinyDos")
        if inMemory {
            container.persistentStoreDescriptions.first?.url = URL(fileURLWithPath: "/dev/null")
        }
        container.loadPersistentStores { description, error in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        }
        container.viewContext.automaticallyMergesChangesFromParent = true
    }

    // Convenience for preview/testing
    static var preview: PersistenceController = {
        let controller = PersistenceController(inMemory: true)
        // Optionally, seed with sample data here
        return controller
    }()
} 