//
//  AwardEntity+CoreDataProperties.swift
//  TinyDos
//
//  Created by Tarik Zukic on 5/22/25.
//
//

import Foundation
import CoreData


extension AwardEntity {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<AwardEntity> {
        return NSFetchRequest<AwardEntity>(entityName: "AwardEntity")
    }

    @NSManaged public var id: UUID?
    @NSManaged public var icon: String?
    @NSManaged public var title: String?
    @NSManaged public var color: String?
    @NSManaged public var bgColor: String?
    @NSManaged public var isCompleted: Bool

}

extension AwardEntity : Identifiable {

}
