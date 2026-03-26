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
        let input = phoneDigits.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !input.isEmpty else {
            errorMessage = "رقم الهاتف أو البريد الإلكتروني مطلوب"
            return
        }
        guard !password.isEmpty else {
            errorMessage = "كلمة المرور مطلوبة"
            return
        }

        isLoading = true
        errorMessage = nil

        // If input is a phone (all digits), normalize to 218XXXXXXXXX
        let emailOrPhone: String
        let digits = input.filter { $0.isNumber }
        if !input.contains("@") && digits.count >= 9 {
            if digits.hasPrefix("218") && digits.count == 12 {
                emailOrPhone = digits
            } else {
                emailOrPhone = "218" + String(digits.suffix(9))
            }
        } else {
            emailOrPhone = input
        }

        do {
            let accessToken = try await loginUseCase.execute(
                emailOrPhone: emailOrPhone,
                password: password
            )
            UserDefaults.standard.set(accessToken, forKey: "auth_token")
            appState.isAuthenticated = true
        } catch let APIError.badRequest(msg) {
            errorMessage = msg
        } catch {
            errorMessage = "فشل الاتصال بالخادم: \(error.localizedDescription)"
        }

        isLoading = false
    }
    
    func reset() {
        phoneDigits = ""
        password = ""
        errorMessage = nil
    }
}
