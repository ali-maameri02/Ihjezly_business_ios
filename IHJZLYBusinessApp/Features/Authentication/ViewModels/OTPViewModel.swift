// Features/Authentication/ViewModels/OTPViewModel.swift

import Foundation
import Combine

@MainActor
final class OTPViewModel: ObservableObject {
    let phoneNumber: String // This is the 9-digit input from user
    @Published var otpCode: String = ""
    @Published var fullName: String = ""
    @Published var email: String = ""
    @Published var password: String = ""
    @Published var confirmPassword: String = ""
    @Published var isLoading = false
    @Published var errorMessage: String? = nil
    @Published var isSuccess = false
    
    private let registerUseCase: RegisterUseCase
    private let requestOTPUseCase: RequestOTPUseCase
    
    init(phoneNumber: String) {
        self.phoneNumber = phoneNumber // e.g., "912345678"
        self.registerUseCase = RegisterUseCase()
        self.requestOTPUseCase = RequestOTPUseCase()
    }
    
    func register() async {
        guard otpCode.count == 6 else { return }
        guard !fullName.isEmpty else {
            errorMessage = "الاسم الكامل مطلوب"
            return
        }
        guard password == confirmPassword else {
            errorMessage = "كلمتا المرور غير متطابقتين"
            return
        }
        guard !password.isEmpty && password.count >= 6 else {
            errorMessage = "كلمة المرور يجب أن تحتوي على 6 أحرف على الأقل"
            return
        }
        
        isLoading = true
        errorMessage = nil
        isSuccess = false
        
        do {
            let token = try await registerUseCase.execute(
                fullName: fullName,
                phoneNumber: phoneNumber, // 9-digit → normalized in AuthRepository
                email: email.isEmpty ? "user@ihjzly.ly" : email,
                password: password,
                role: .client
            )
            UserDefaults.standard.set(token, forKey: "auth_token")
            isSuccess = true
        } catch {
            errorMessage = "فشل التسجيل. تحقق من البيانات أو حاول لاحقًا."
        }
        
        isLoading = false
    }
    
    func resendOTP() async {
        isLoading = true
        do {
            try await requestOTPUseCase.execute(phoneNumber: phoneNumber)
            errorMessage = "✓ تم إرسال كود جديد"
        } catch {
            errorMessage = "فشل إعادة الإرسال"
        }
        isLoading = false
    }
}
