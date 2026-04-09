// Features/Authentication/ViewModels/SignUpViewModel.swift

import Foundation
import Combine

/// Step 1 ViewModel: collects phone number and dispatches OTP via Resala API.
@MainActor
final class SignUpViewModel: ObservableObject {

    // MARK: - Input
    /// User enters 9 local digits (e.g. "912345678") — normalized to "218XXXXXXXXX" before sending
    @Published var phoneNumber: String = ""

    // MARK: - State
    @Published var isLoading = false
    @Published var errorMessage: String?

    /// Set to true after OTP is successfully sent — triggers navigation to Step 2
    @Published var navigateToOTP = false

    // MARK: - Computed
    /// The full international number sent to the OTP API
    var normalizedPhone: String {
        let digits = phoneNumber.filter { $0.isNumber }
        return digits.hasPrefix("218") && digits.count == 12
            ? digits
            : "218" + String(digits.suffix(9))
    }

    // MARK: - Send OTP
    /// Validates the phone, calls OTPService, then sets navigateToOTP = true on success.
    func sendOTPAndProceed() {
        errorMessage = nil

        let digits = phoneNumber.filter { $0.isNumber }
        guard digits.count == 9 else {
            errorMessage = "أدخل 9 أرقام ليبية (مثل: 912345678)"
            return
        }

        isLoading = true
        Task {
            do {
                _ = try await OTPService.shared.sendOTP(phone: normalizedPhone)
                navigateToOTP = true
            } catch {
                errorMessage = (error as? OTPError)?.errorDescription
                    ?? "فشل إرسال الكود. تحقق من الاتصال."
            }
            isLoading = false
        }
    }
}
