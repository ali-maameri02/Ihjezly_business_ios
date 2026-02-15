// Features/Authentication/ViewModels/SignUpViewModel.swift

import Foundation
import Combine

@MainActor
final class SignUpViewModel: ObservableObject {
    @Published var phoneNumber: String = "" // User enters 9 digits (e.g., "912345678")
    @Published var isLoading = false
    @Published var errorMessage: String? = nil
    @Published var isSuccess = false
    
    private let requestOTPUseCase: RequestOTPUseCase
    
    init(requestOTPUseCase: RequestOTPUseCase = RequestOTPUseCase()) {
        self.requestOTPUseCase = requestOTPUseCase
    }
    
    func sendOTP() async {
        guard isValidLibyanPhone(phoneNumber) else {
            errorMessage = "أدخل 9 أرقام ليبية (مثل: 912345678)"
            return
        }
        
        isLoading = true
        errorMessage = nil
        isSuccess = false
        
        do {
            // Send raw 9-digit input — normalization happens in AuthRepository
            try await requestOTPUseCase.execute(phoneNumber: phoneNumber)
            isSuccess = true
        } catch {
            errorMessage = "فشل إرسال الكود. تحقق من الاتصال."
        }
        
        isLoading = false
    }
    
    private func isValidLibyanPhone(_ phone: String) -> Bool {
        let digits = phone.filter { $0.isNumber }
        return digits.count == 9
    }
}
