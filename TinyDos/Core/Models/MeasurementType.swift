import Foundation

struct MeasurementType: Identifiable, Codable, Equatable {
    let id: Int
    let habit: String
    let unit: String
    let measurementType: String
    let region: String

    enum CodingKeys: String, CodingKey {
        case id
        case habit
        case unit
        case measurementType = "measurement_type"
        case region
    }
} 