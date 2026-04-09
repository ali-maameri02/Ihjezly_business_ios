// Features/Authentication/ViewModels/OTPViewModel.swift

import Foundation
import Combine

enum OTPStep: Equatable {
    case sending    // auto-sending OTP on screen appear
    case enterCode  // OTP sent, waiting for user input
    case verified   // OTP confirmed — navigate to Step 3
}

/// Step 2 ViewModel: receives the verified phone from Step 1,
/// auto-sends OTP on appear, verifies the entered code.
@MainActor
final class OTPViewModel: ObservableObject {

    // MARK: - State
    @Published var otpCode: String = ""
    @Published var step: OTPStep = .sending

    @Published var isSending = false
    @Published var isVerifying = false
    @Published var errorMessage: String?

    /// Countdown before the resend button becomes active (seconds)
    @Published var resendCountdown: Int = 0

    // MARK: - Private
    let phone: String   // full international number e.g. "218912345678"
    private var otpResponse: OTPResponse?
    private var countdownTask: Task<Void, Never>?

    var canResend: Bool { resendCountdown == 0 && !isSending }

    // MARK: - Init
    init(phone: String) {
        self.phone = phone
    }

    // MARK: - Send OTP (called on .onAppear)
    func sendOTP() {
        guard !isSending else { return }
        errorMessage = nil
        isSending = true

        Task {
            do {
                let response = try await OTPService.shared.sendOTP(phone: phone)
                otpResponse = response
                step = .enterCode
                startCountdown()
            } catch {
                errorMessage = (error as? OTPError)?.errorDescription
                    ?? "فشل إرسال الكود. تحقق من الاتصال."
                // Stay on .sending so the UI shows error + retry
            }
            isSending = false
        }
    }

    // MARK: - Verify OTP
    func verifyOTP() {
        guard let response = otpResponse else {
            errorMessage = "يرجى إرسال رمز التحقق أولاً"
            return
        }
        guard !isVerifying else { return }
        errorMessage = nil
        isVerifying = true

        Task {
            do {
                try OTPService.shared.verifyOTP(entered: otpCode, expected: response)
                step = .verified
            } catch {
                errorMessage = (error as? OTPError)?.errorDescription ?? "رمز التحقق غير صحيح"
                otpCode = "" // clear so user can retry
            }
            isVerifying = false
        }
    }

    // MARK: - Resend OTP
    func resendOTP() {
        guard canResend else { return }
        otpCode = ""
        errorMessage = nil
        isSending = true

        Task {
            do {
                let response = try await OTPService.shared.resendOTP(phone: phone)
                otpResponse = response
                startCountdown()
            } catch {
                errorMessage = (error as? OTPError)?.errorDescription ?? "فشل إعادة الإرسال"
            }
            isSending = false
        }
    }

    // MARK: - Countdown
    private func startCountdown() {
        resendCountdown = 60
        countdownTask?.cancel()
        countdownTask = Task { [weak self] in
            guard let self else { return }
            while self.resendCountdown > 0 {
                try? await Task.sleep(nanoseconds: 1_000_000_000)
                guard !Task.isCancelled else { return }
                self.resendCountdown -= 1
            }
        }
    }
}
