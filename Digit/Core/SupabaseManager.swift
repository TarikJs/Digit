import Foundation
import Supabase

final class SupabaseManager {
    static let shared = SupabaseManager()
    let client: SupabaseClient

    private init() {
        // TODO: Replace with your actual Supabase project URL and anon key
        client = SupabaseClient(
            supabaseURL: URL(string: "https://begpsdnsolfjgxepwqim.supabase.co")!,
            supabaseKey: "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImJlZ3BzZG5zb2xmamd4ZXB3cWltIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDY2Mzk5MzMsImV4cCI6MjA2MjIxNTkzM30.gkdHMGhqOiyhYI0HrurWjKR56R_ElgGmKwkn4vJ4G4g"
        )
    }
} 
