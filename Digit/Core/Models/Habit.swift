//
//  Habit.swift
//  Digit
//
//  Model representing a user habit for the Habit Builder App.
//

import Foundation
import SwiftUI

public struct Habit: Identifiable, Codable, Equatable, Hashable {
    public enum Frequency: String, Codable, CaseIterable, Equatable {
        case daily
        case weekly
        case custom // For specific days of the week
    }
    
    public let id: UUID
    public var name: String
    public var color: ColorCodable
    public var iconName: String
    public var frequency: Frequency
    public var customDays: [Int]? // 1 = Sunday, 7 = Saturday (if custom)
    public var reminderTime: DateComponents?
    public var completions: [Date] // Dates when the habit was completed
    public var dailyGoal: Int // Number of times to complete per day
    public var currentProgress: Int // Current progress for today
    public var lastProgressDate: Date? // Date when progress was last updated
    
    public init(id: UUID = UUID(),
         name: String,
         color: Color = .accentColor,
         iconName: String = "star.fill",
         frequency: Frequency = .daily,
         customDays: [Int]? = nil,
         reminderTime: DateComponents? = nil,
         completions: [Date] = [],
         dailyGoal: Int = 1,
         currentProgress: Int = 0,
         lastProgressDate: Date? = nil) {
        self.id = id
        self.name = name
        self.color = ColorCodable(color)
        self.iconName = iconName
        self.frequency = frequency
        self.customDays = customDays
        self.reminderTime = reminderTime
        self.completions = completions
        self.dailyGoal = dailyGoal
        self.currentProgress = currentProgress
        self.lastProgressDate = lastProgressDate
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
        hasher.combine(name)
        hasher.combine(color)
        hasher.combine(iconName)
        hasher.combine(frequency)
        hasher.combine(customDays)
        hasher.combine(reminderTime?.hour)
        hasher.combine(reminderTime?.minute)
        hasher.combine(completions)
        hasher.combine(dailyGoal)
        hasher.combine(currentProgress)
        hasher.combine(lastProgressDate)
    }
    
    // MARK: - Helper Methods
    
    public var isCompletedToday: Bool {
        currentProgress >= dailyGoal
    }
    
    public mutating func resetProgressIfNeeded() {
        let calendar = Calendar.current
        if let lastDate = lastProgressDate,
           !calendar.isDate(lastDate, inSameDayAs: Date()) {
            currentProgress = 0
            lastProgressDate = Date()
        } else if lastProgressDate == nil {
            lastProgressDate = Date()
        }
    }
    
    public mutating func incrementProgress() {
        resetProgressIfNeeded()
        currentProgress += 1
        lastProgressDate = Date()
        
        if isCompletedToday && !completions.contains(where: { Calendar.current.isDate($0, inSameDayAs: Date()) }) {
            completions.append(Date())
        }
    }
    
    public mutating func decrementProgress() {
        resetProgressIfNeeded()
        currentProgress = max(0, currentProgress - 1)
        lastProgressDate = Date()
        
        if !isCompletedToday {
            completions.removeAll(where: { Calendar.current.isDate($0, inSameDayAs: Date()) })
        }
    }
}

// MARK: - Codable Color Wrapper

public struct ColorCodable: Codable, Equatable, Hashable {
    public let color: Color
    
    public init(_ color: Color) {
        self.color = color
    }
    
    enum CodingKeys: String, CodingKey {
        case red, green, blue, alpha
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        var red: CGFloat = 0, green: CGFloat = 0, blue: CGFloat = 0, alpha: CGFloat = 0
        UIColor(color).getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        try container.encode(Double(red), forKey: .red)
        try container.encode(Double(green), forKey: .green)
        try container.encode(Double(blue), forKey: .blue)
        try container.encode(Double(alpha), forKey: .alpha)
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let red = try container.decode(Double.self, forKey: .red)
        let green = try container.decode(Double.self, forKey: .green)
        let blue = try container.decode(Double.self, forKey: .blue)
        let alpha = try container.decode(Double.self, forKey: .alpha)
        self.color = Color(.sRGB, red: red, green: green, blue: blue, opacity: alpha)
    }
    
    public func hash(into hasher: inout Hasher) {
        var red: CGFloat = 0, green: CGFloat = 0, blue: CGFloat = 0, alpha: CGFloat = 0
        UIColor(color).getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        hasher.combine(red)
        hasher.combine(green)
        hasher.combine(blue)
        hasher.combine(alpha)
    }
} 