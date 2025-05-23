import Foundation
import CoreData
import SwiftUI

protocol AwardLocalStoreProtocol {
    func fetchAwards() async throws -> [Award]
    func saveAwards(_ awards: [Award]) async throws
    func saveAward(_ award: Award) async throws
    func deleteAward(_ award: Award) async throws
}

final class AwardLocalStore: AwardLocalStoreProtocol {
    private let context: NSManagedObjectContext
    
    init(context: NSManagedObjectContext = PersistenceController.shared.container.viewContext) {
        self.context = context
    }
    
    func fetchAwards() async throws -> [Award] {
        let request: NSFetchRequest<AwardEntity> = AwardEntity.fetchRequest()
        let entities = try context.fetch(request)
        return entities.compactMap { $0.toAward() }
    }
    
    func saveAwards(_ awards: [Award]) async throws {
        for award in awards {
            try await saveAward(award)
        }
        try context.save()
    }
    
    func saveAward(_ award: Award) async throws {
        let request: NSFetchRequest<AwardEntity> = AwardEntity.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", award.id as CVarArg)
        let results = try context.fetch(request)
        let entity = results.first ?? AwardEntity(context: context)
        entity.update(from: award)
        try context.save()
    }
    
    func deleteAward(_ award: Award) async throws {
        let request: NSFetchRequest<AwardEntity> = AwardEntity.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", award.id as CVarArg)
        let results = try context.fetch(request)
        if let entity = results.first {
            context.delete(entity)
            try context.save()
        }
    }
}

// MARK: - Mapping Extensions
extension AwardEntity {
    func toAward() -> Award? {
        guard let id = id, let icon = icon, let title = title, let colorHex = color, let bgColorHex = bgColor else { return nil }
        return Award(
            icon: icon,
            title: title,
            color: Color(hex: colorHex),
            bgColor: Color(hex: bgColorHex)
        )
    }
    
    func update(from award: Award) {
        self.id = award.id
        self.icon = award.icon
        self.title = award.title
        self.color = award.color.toHex()
        self.bgColor = award.bgColor.toHex()
    }
}

// MARK: - Color <-> Hex Helpers
extension Color {
    func toHex() -> String {
        let uiColor = UIColor(self)
        var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
        uiColor.getRed(&r, green: &g, blue: &b, alpha: &a)
        let rgb = (Int(r * 255) << 16) | (Int(g * 255) << 8) | Int(b * 255)
        return String(format: "%06X", rgb)
    }
} 