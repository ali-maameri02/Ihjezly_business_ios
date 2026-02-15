// Features/Profile/ViewModels/UserProfileViewModel.swift

import Foundation
import Combine

@MainActor
final class UserProfileViewModel: ObservableObject {
    @Published var currentUser: User?
    @Published var isLoading = false
    @Published var errorMessage: String? // ✅ Renamed from 'error' to avoid conflict
    
    private let getCurrentUserUseCase: GetCurrentUserUseCase
    
    init() {
        let client = APIClient(baseURLString: "http://31.220.56.155:5050")
        let repo = AuthRepository(apiClient: client)
        self.getCurrentUserUseCase = GetCurrentUserUseCase(authRepo: repo)
        Task { await loadUser() }
    }
    
    func loadUser() async {
        isLoading = true
        errorMessage = nil // ✅ Use correct property name
        do {
            currentUser = try await getCurrentUserUseCase.execute()
        } catch {
            errorMessage = "فشل تحميل بيانات المستخدم" // ✅ Assign to errorMessage
        }
        isLoading = false
    }
}
