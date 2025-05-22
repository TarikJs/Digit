import Foundation

/// Represents the preferred time of day for performing a habit
enum PreferredHabitTime: String, Codable, CaseIterable {
    /// Morning time slot (6AM - 12PM)
    case morning = "Morning (6AM - 12PM)"
    /// Afternoon time slot (12PM - 5PM)
    case afternoon = "Afternoon (12PM - 5PM)"
    /// Evening time slot (5PM - 9PM)
    case evening = "Evening (5PM - 9PM)"
    /// Night time slot (9PM - 12AM)
    case night = "Night (9PM - 12AM)"
    /// Flexible timing with no specific preference
    case flexible = "I'm flexible"
    
    /// Returns the start hour (in 24-hour format) for this time slot
    var startHour: Int {
        switch self {
        case .morning: return 6
        case .afternoon: return 12
        case .evening: return 17
        case .night: return 21
        case .flexible: return 0
        }
    }
    
    /// Returns the end hour (in 24-hour format) for this time slot
    var endHour: Int {
        switch self {
        case .morning: return 12
        case .afternoon: return 17
        case .evening: return 21
        case .night: return 24
        case .flexible: return 24
        }
    }
    
    /// Returns true if the current time falls within this time slot
    var isCurrentTimeSlot: Bool {
        guard self != .flexible else { return true }
        let calendar = Calendar.current
        let now = Date()
        let hour = calendar.component(.hour, from: now)
        return hour >= startHour && hour < endHour
    }
    
    /// Returns a user-friendly description of the time slot
    var description: String {
        self.rawValue
    }
    
    /// Returns an SF Symbol name representing this time slot
    var systemImage: String {
        switch self {
        case .morning: return "sunrise.fill"
        case .afternoon: return "sun.max.fill"
        case .evening: return "sunset.fill"
        case .night: return "moon.stars.fill"
        case .flexible: return "clock.fill"
        }
    }
} 