import Foundation
import Supabase

protocol MeasurementTypeServiceProtocol {
    func fetchMeasurementTypes(for habit: String, region: String) async throws -> [MeasurementType]
}

final class MeasurementTypeService: MeasurementTypeServiceProtocol {
    private let client: SupabaseClient
    
    init(client: SupabaseClient = SupabaseManager.shared.client) {
        self.client = client
    }
    
    func fetchMeasurementTypes(for habit: String, region: String = "us") async throws -> [MeasurementType] {
        let response = try await client
            .from("measurement_type")
            .select()
            .eq("habit", value: habit)
            .eq("region", value: region)
            .execute()
        let data = response.data
        let decoder = JSONDecoder()
        return try decoder.decode([MeasurementType].self, from: data)
    }
} 