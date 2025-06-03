//
//  HabitEntity+CoreDataProperties.swift
//  TinyDos
//
//  Created by Tarik Zukic on 5/22/25.
//
//

import Foundation
import CoreData


extension HabitEntity {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<HabitEntity> {
        return NSFetchRequest<HabitEntity>(entityName: "HabitEntity")
    }

    @NSManaged public var id: UUID?
    @NSManaged public var userId: UUID?
    @NSManaged public var name: String?
    @NSManaged public var descriptionText: String?
    @NSManaged public var dailyGoal: Int32
    @NSManaged public var icon: String?
    @NSManaged public var startDate: Date?
    @NSManaged public var endDate: Date?
    @NSManaged public var repeatFrequency: String?
    @NSManaged public var weekdays: NSObject?
    @NSManaged public var reminderTime: String?
    @NSManaged public var createdAt: Date?
    @NSManaged public var updatedAt: Date?
    @NSManaged public var unit: String?
    @NSManaged public var tag: String?

}

extension HabitEntity : Identifiable {

}
