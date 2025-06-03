//
//  UserProfileEntity+CoreDataProperties.swift
//  TinyDos
//
//  Created by Tarik Zukic on 5/22/25.
//
//

import Foundation
import CoreData


extension UserProfileEntity {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<UserProfileEntity> {
        return NSFetchRequest<UserProfileEntity>(entityName: "UserProfileEntity")
    }

    @NSManaged public var id: UUID?
    @NSManaged public var email: String?
    @NSManaged public var firstName: String?
    @NSManaged public var lastName: String?
    @NSManaged public var userName: String?
    @NSManaged public var dateOfBirth: Date?
    @NSManaged public var gender: String?
    @NSManaged public var createdAt: Date?
    @NSManaged public var region: String?
    @NSManaged public var setupComp: String?

}

extension UserProfileEntity : Identifiable {

}
