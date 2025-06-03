//
//  ProgressEntity+CoreDataProperties.swift
//  TinyDos
//
//  Created by Tarik Zukic on 5/22/25.
//
//

import Foundation
import CoreData


extension ProgressEntity {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<ProgressEntity> {
        return NSFetchRequest<ProgressEntity>(entityName: "ProgressEntity")
    }

    @NSManaged public var id: String?
    @NSManaged public var userId: String?
    @NSManaged public var habitId: String?
    @NSManaged public var date: Date?
    @NSManaged public var progress: Int32
    @NSManaged public var goal: Int32
    @NSManaged public var createdAt: Date?
    @NSManaged public var updatedAt: Date?

}

extension ProgressEntity : Identifiable {

}
