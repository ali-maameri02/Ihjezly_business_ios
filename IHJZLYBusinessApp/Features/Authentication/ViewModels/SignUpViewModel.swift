// Features/Authentication/ViewModels/SignUpViewModel.swift
import Foundation
import Combine

@MainActor
final class SignUpViewModel: ObservableObject {

    @Published var phoneNumber = ""
    @Published var phoneError: String?
    @Published var errorMessage: String?
    @Published var isLoading = false
    @Published var navigateToOTP = false

    func sendOTPAndProceed() {
        phoneError = nil
        errorMessage = nil

        let phone = phoneNumber.trimmingCharacters(in: .whitespaces)
        guard !phone.isEmpty else {
            phoneError = "رقم الهاتف مطلوب"
            return
        }
        guard phone.count >= 7 else {
            phoneError = "رقم الهاتف غير صحيح"
            return
        }

        isLoading = true
        Task {
            do {
                _ = try await OTPService.shared.sendOTP(phone: phone)
                navigateToOTP = true
            } catch {
                errorMessage = (error as? OTPError)?.errorDescription ?? error.localizedDescription
            }
            isLoading = false
        }
    }
}
