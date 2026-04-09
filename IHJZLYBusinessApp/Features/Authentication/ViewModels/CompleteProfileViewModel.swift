// Features/Authentication/ViewModels/CompleteProfileViewModel.swift

import Foundation
import Combine

/// Step 3 ViewModel: collects profile info and creates the account via the backend.
/// Role is always BusinessOwner for this app.
@MainActor
final class CompleteProfileViewModel: ObservableObject {

    // MARK: - Verified phone (passed from Step 1)
    let phone: String

    // MARK: - Form fields
    @Published var fullName = ""
    @Published var email = ""
    @Published var password = ""
    @Published var confirmPassword = ""

    // MARK: - Field errors
    @Published var fullNameError: String?
    @Published var emailError: String?
    @Published var passwordError: String?
    @Published var confirmPasswordError: String?

    // MARK: - State
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var isRegistered = false

    private let registerUseCase: RegisterUseCase

    init(phone: String) {
        self.phone = phone
        self.registerUseCase = RegisterUseCase()
    }

    // MARK: - Validation
    @discardableResult
    func validate() -> Bool {
        fullNameError = nil
        emailError = nil
        passwordError = nil
        confirmPasswordError = nil
        var valid = true

        let name = fullName.trimmingCharacters(in: .whitespaces)
        if name.isEmpty {
            fullNameError = "الاسم الكامل مطلوب"
            valid = false
        } else if name.count < 3 {
            fullNameError = "الاسم يجب أن يكون 3 أحرف على الأقل"
            valid = false
        }

        let mail = email.trimmingCharacters(in: .whitespaces)
        if !mail.isEmpty, !mail.contains("@") || !mail.contains(".") {
            emailError = "صيغة البريد الإلكتروني غير صحيحة"
            valid = false
        }

        if password.isEmpty {
            passwordError = "كلمة المرور مطلوبة"
            valid = false
        } else if password.count < 6 {
            passwordError = "كلمة المرور يجب أن تكون 6 أحرف على الأقل"
            valid = false
        }

        if confirmPassword.isEmpty {
            confirmPasswordError = "تأكيد كلمة المرور مطلوب"
            valid = false
        } else if confirmPassword != password {
            confirmPasswordError = "كلمتا المرور غير متطابقتين"
            valid = false
        }

        return valid
    }

    // MARK: - Create account (POST /api/v1/Users/register)
    func createAccount() {
        guard validate() else { return }
        isLoading = true
        errorMessage = nil

        Task {
            do {
                let mail = email.trimmingCharacters(in: .whitespaces)
                // Role is always BusinessOwner in this app
                let token = try await registerUseCase.execute(
                    fullName: fullName.trimmingCharacters(in: .whitespaces),
                    phoneNumber: phone,
                    email: mail.isEmpty ? "user@ihjzly.ly" : mail,
                    password: password,
                    role: .businessOwner
                )
                UserDefaults.standard.set(token, forKey: "auth_token")
                isRegistered = true
            } catch let APIError.badRequest(msg) {
                errorMessage = msg
            } catch {
                errorMessage = "فشل التسجيل. تحقق من البيانات أو حاول لاحقًا."
            }
            isLoading = false
        }
    }
}
