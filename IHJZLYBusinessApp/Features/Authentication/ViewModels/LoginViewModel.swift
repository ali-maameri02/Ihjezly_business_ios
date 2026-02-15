// Features/Authentication/ViewModels/LoginViewModel.swift

import Foundation
import Combine

@MainActor
final class LoginViewModel: ObservableObject {
    // Remove @EnvironmentObject — not allowed here
    
    @Published var phoneDigits: String = ""
    @Published var password: String = ""
    @Published var isLoading = false
    @Published var errorMessage: String? = nil
    @Published var showSuccessAlert = false
    
    private let loginUseCase: LoginUseCase
    private let appState: AppState // ✅ Injected dependency

    init(appState: AppState) { // ✅ Accept AppState in init
        self.appState = appState
        let authRepo = Container.shared.resolve(AuthRepositoryProtocol.self)
        self.loginUseCase = LoginUseCase(authRepo: authRepo)
    }
    
    func login() async {
        let digits = phoneDigits.filter { $0.isNumber }
        guard digits.count == 9 else {
            errorMessage = "أدخل 9 أرقام ليبية صحيحة"
            return
        }
        
        guard !password.isEmpty else {
            errorMessage = "كلمة المرور مطلوبة"
            return
        }
        
        isLoading = true
        errorMessage = nil
        
        do {
            let fullPhoneNumber = "218" + digits
            let accessToken = try await loginUseCase.execute(
                emailOrPhone: fullPhoneNumber,
                password: password
            )
            UserDefaults.standard.set(accessToken, forKey: "auth_token")
            appState.isAuthenticated = true // ✅ Now works
        } catch {
            errorMessage = "فشل تسجيل الدخول. تحقق من بياناتك."
        }
        
        isLoading = false
    }
    
    func reset() {
        phoneDigits = ""
        password = ""
        errorMessage = nil
    }
}
