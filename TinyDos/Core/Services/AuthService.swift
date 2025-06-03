import Foundation
import Supabase

final class AuthService: AuthServiceProtocol {
    private let client: SupabaseClient
    
    init(client: SupabaseClient = SupabaseManager.shared.client) {
        self.client = client
    }
    
    func signOut() async throws {
        try await client.auth.signOut()
    }
} 