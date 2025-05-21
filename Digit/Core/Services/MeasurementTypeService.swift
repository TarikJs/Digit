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
    
    /// Fetches measurement types for a given habit input, with improved matching and scoring
    /// - Parameters:
    ///   - habitInput: The user's input string
    ///   - region: The region code (default: "us")
    /// - Returns: Array of matching measurement types, sorted by relevance
    func fetchMeasurementTypes(for habitInput: String, region: String = "us") async throws -> [MeasurementType] {
        // Enhanced stop words list
        let stopWords: Set<String> = [
            "the", "a", "an", "and", "or", "but", "nor", "for", "yet", "so",
            "in", "on", "at", "to", "of", "with", "by", "as", "be", "from",
            "is", "it", "its", "this", "that", "these", "those", "am", "are",
            "was", "were", "has", "have", "had", "do", "does", "did", "will",
            "would", "shall", "should", "may", "might", "must", "can", "could"
        ]
        
        // Clean and tokenize input
        let words = habitInput
            .lowercased()
            .components(separatedBy: CharacterSet.alphanumerics.inverted)
            .filter { !$0.isEmpty && !stopWords.contains($0) }
            .map { $0.trimmingCharacters(in: .whitespaces) }
        
        guard !words.isEmpty else { return [] }
        
        // Build query with improved matching logic
        var query = client.from("measurement_type")
            .select()
            .eq("region", value: region)
        
        // Create a complex OR filter that checks both exact and partial matches
        var matchFilters = words.flatMap { word -> [String] in
            [
                // Exact match with the full habit name (case-insensitive)
                "habit.ilike.\(habitInput.lowercased())",
                // Match any word exactly (case-insensitive)
                "habit.ilike.% \(word) %",
                // Match at the start (case-insensitive)
                "habit.ilike.\(word)%",
                // Match at the end (case-insensitive)
                "habit.ilike.% \(word)",
                // Match anywhere (case-insensitive)
                "habit.ilike.%\(word)%"
            ]
        }
        
        // Add aliases check (case-insensitive)
        matchFilters.append("aliases.ilike.X")
        
        // Combine all filters with OR
        let orFilter = matchFilters.joined(separator: ",")
        query = query.or(orFilter)
        
        print("[DEBUG] Generated query filters:", orFilter)
        
        // Execute query and decode results
        let response = try await query.execute()
        let data = response.data
        let decoder = JSONDecoder()
        var results = try decoder.decode([MeasurementType].self, from: data)
        
        // Score and sort results
        results.sort { type1, type2 in
            let score1 = calculateMatchScore(type1, words: words)
            let score2 = calculateMatchScore(type2, words: words)
            return score1 > score2
        }
        
        return results
    }
    
    /// Calculates a relevance score for a measurement type based on how well it matches the input words
    /// - Parameters:
    ///   - type: The measurement type to score
    ///   - words: The input words to match against
    /// - Returns: A score where higher means better match
    private func calculateMatchScore(_ type: MeasurementType, words: [String]) -> Int {
        var score = 0
        let habitWords = type.habit.lowercased().components(separatedBy: .whitespaces)
        
        for word in words {
            // Exact match with habit (case-insensitive)
            if type.habit.lowercased() == word {
                score += 100
            }
            // Word appears as a whole word (case-insensitive)
            else if habitWords.contains(word.lowercased()) {
                score += 75
            }
            // Word appears at start (case-insensitive)
            else if type.habit.lowercased().hasPrefix(word.lowercased()) {
                score += 50
            }
            // Word appears anywhere (case-insensitive)
            else if type.habit.lowercased().contains(word.lowercased()) {
                score += 25
            }
        }
        
        return score
    }
} 