import Foundation
import CoreData

protocol UserProfileLocalStoreProtocol {
    func fetchProfile() async throws -> UserProfile?
    func saveProfile(_ profile: UserProfile) async throws
    func deleteProfile(_ profile: UserProfile) async throws
}

final class UserProfileLocalStore: UserProfileLocalStoreProtocol {
    private let context: NSManagedObjectContext
    
    init(context: NSManagedObjectContext = PersistenceController.shared.container.viewContext) {
        self.context = context
    }
    
    func fetchProfile() async throws -> UserProfile? {
        let request: NSFetchRequest<UserProfileEntity> = UserProfileEntity.fetchRequest()
        let entities = try context.fetch(request)
        return entities.first?.toUserProfile()
    }
    
    func saveProfile(_ profile: UserProfile) async throws {
        let request: NSFetchRequest<UserProfileEntity> = UserProfileEntity.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", profile.id as CVarArg)
        let results = try context.fetch(request)
        let entity = results.first ?? UserProfileEntity(context: context)
        entity.update(from: profile)
        try context.save()
    }
    
    func deleteProfile(_ profile: UserProfile) async throws {
        let request: NSFetchRequest<UserProfileEntity> = UserProfileEntity.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", profile.id as CVarArg)
        let results = try context.fetch(request)
        if let entity = results.first {
            context.delete(entity)
            try context.save()
        }
    }
}

// MARK: - Mapping Extensions
extension UserProfileEntity {
    func toUserProfile() -> UserProfile? {
        guard let id = id,
              let email = email,
              let firstName = firstName,
              let lastName = lastName
        else { return nil }
        return UserProfile(
            id: id.uuidString,
            email: email,
            firstName: firstName,
            lastName: lastName,
            userName: userName,
            dateOfBirth: dateOfBirth,
            gender: gender ?? "",
            createdAt: createdAt,
            region: region,
            setupComp: setupComp
        )
    }
    
    func update(from profile: UserProfile) {
        self.id = UUID(uuidString: profile.id)
        self.email = profile.email
        self.firstName = profile.firstName
        self.lastName = profile.lastName
        self.userName = profile.userName
        self.dateOfBirth = profile.dateOfBirth
        self.gender = profile.gender
        self.createdAt = profile.createdAt
        self.region = profile.region
        self.setupComp = profile.setupComp
    }
} 