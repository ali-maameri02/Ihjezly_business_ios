// Features/Authentication/Views/OTPVerificationView.swift

import SwiftUI

/// Step 2 of registration: OTP verification.
/// Receives the full international phone from Step 1,
/// auto-sends OTP on appear, navigates to Step 3 on success.
struct OTPVerificationView: View {

    let phone: String

    @StateObject private var viewModel: OTPViewModel
    @FocusState  private var otpFocused: Bool

    init(phone: String) {
        self.phone = phone
        _viewModel = StateObject(wrappedValue: OTPViewModel(phone: phone))
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {

                // ── Header ────────────────────────────────────────────────
                VStack(spacing: 8) {
                    ZStack {
                        Circle()
                            .fill(Color.brand.opacity(0.1))
                            .frame(width: 80, height: 80)
                        Image(systemName: headerIcon)
                            .font(.system(size: 34))
                            .foregroundColor(.brand)
                            .id(viewModel.step)
                    }
                    .animation(.spring(response: 0.4, dampingFraction: 0.7), value: viewModel.step)

                    Text(headerTitle)
                        .font(.title2).fontWeight(.bold)
                        .foregroundColor(.primary)

                    Text(headerSubtitle)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 32)
                }
                .padding(.top, 40)

                // ── Phone chip ────────────────────────────────────────────
                HStack(spacing: 8) {
                    Image(systemName: "phone.fill")
                        .foregroundColor(.brand)
                        .font(.subheadline)
                    Text(phone)
                        .font(.subheadline).fontWeight(.medium)
                    Spacer()
                }
                .padding(.horizontal, 14)
                .padding(.vertical, 12)
                .background(Color.brand.opacity(0.08))
                .cornerRadius(12)
                .padding(.horizontal, 24)

                // ── Content by step ───────────────────────────────────────
                switch viewModel.step {
                case .sending:
                    sendingIndicator
                case .enterCode:
                    otpSection
                case .verified:
                    successSection
                }

                // ── Error banner ──────────────────────────────────────────
                if let error = viewModel.errorMessage {
                    Text(error)
                        .foregroundColor(.red)
                        .font(.caption)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 24)
                        .transition(.opacity.combined(with: .move(edge: .top)))
                }
            }
            .padding(.bottom, 40)
        }
        .background(Color.pageBackground.ignoresSafeArea())
        .animation(.easeInOut(duration: 0.25), value: viewModel.step)
        .animation(.easeInOut(duration: 0.2), value: viewModel.errorMessage)
        .onAppear { viewModel.sendOTP() }
        // Navigate to Step 3 when OTP is verified
        .navigationDestination(isPresented: Binding(
            get: { viewModel.step == .verified },
            set: { _ in }
        )) {
            CompleteProfileView(phone: phone)
        }
    }

    // MARK: - Sending indicator
    private var sendingIndicator: some View {
        HStack(spacing: 10) {
            ProgressView()
            Text("جارٍ إرسال رمز التحقق...")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .padding(.vertical, 8)
    }

    // MARK: - OTP entry section
    private var otpSection: some View {
        VStack(spacing: 20) {
            // 6-box digit display
            otpInputField

            // Verify button
            Button(action: viewModel.verifyOTP) {
                Group {
                    if viewModel.isVerifying {
                        ProgressView().tint(.white)
                    } else {
                        Text("تأكيد").fontWeight(.semibold)
                    }
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .foregroundColor(.white)
                .background(
                    viewModel.otpCode.count == 6 && !viewModel.isVerifying
                        ? Color.brand : Color.gray.opacity(0.4)
                )
                .cornerRadius(12)
            }
            .disabled(viewModel.otpCode.count != 6 || viewModel.isVerifying)
            .padding(.horizontal, 24)

            // Resend button with countdown
            resendButton
        }
    }

    // MARK: - 6-box OTP input
    private var otpInputField: some View {
        VStack(spacing: 8) {
            HStack(spacing: 10) {
                ForEach(0..<6, id: \.self) { index in
                    OTPDigitBox(
                        digit: digit(at: index),
                        isFocused: otpFocused && viewModel.otpCode.count == index
                    )
                }
            }
            // Invisible TextField captures keyboard input
            .overlay(
                TextField("", text: $viewModel.otpCode)
                    .keyboardType(.numberPad)
                    .focused($otpFocused)
                    .opacity(0.01)
                    .onChange(of: viewModel.otpCode) { _, new in
                        viewModel.otpCode = String(new.filter(\.isNumber).prefix(6))
                        if viewModel.otpCode.count == 6 { viewModel.verifyOTP() }
                    }
            )
            .onTapGesture { otpFocused = true }
            .onAppear {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { otpFocused = true }
            }

            Text("أدخل الرمز المكون من 6 أرقام")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding(.horizontal, 24)
    }

    // MARK: - Resend button
    private var resendButton: some View {
        Group {
            if viewModel.resendCountdown > 0 {
                HStack(spacing: 4) {
                    Text("إعادة الإرسال بعد")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    Text("\(viewModel.resendCountdown)s")
                        .font(.subheadline).fontWeight(.bold)
                        .foregroundColor(.brand)
                        .monospacedDigit()
                        .contentTransition(.numericText())
                }
            } else {
                Button(action: viewModel.resendOTP) {
                    HStack(spacing: 6) {
                        if viewModel.isSending {
                            ProgressView().scaleEffect(0.8)
                        } else {
                            Image(systemName: "arrow.clockwise").font(.subheadline)
                        }
                        Text("إعادة إرسال الكود")
                            .font(.subheadline).fontWeight(.semibold)
                    }
                    .foregroundColor(.brand)
                }
                .disabled(viewModel.isSending)
            }
        }
        .animation(.easeInOut(duration: 0.2), value: viewModel.resendCountdown)
    }

    // MARK: - Success flash
    private var successSection: some View {
        VStack(spacing: 12) {
            Image(systemName: "checkmark.seal.fill")
                .font(.system(size: 52))
                .foregroundColor(.green)
            Text("تم التحقق بنجاح ✓")
                .font(.headline)
                .foregroundColor(.green)
            Text("جارٍ الانتقال...")
                .font(.subheadline)
                .foregroundColor(.secondary)
            ProgressView().tint(.brand)
        }
        .padding(.vertical, 8)
    }

    // MARK: - Helpers
    private func digit(at index: Int) -> String {
        guard index < viewModel.otpCode.count else { return "" }
        let i = viewModel.otpCode.index(viewModel.otpCode.startIndex, offsetBy: index)
        return String(viewModel.otpCode[i])
    }

    private var headerIcon: String {
        viewModel.step == .verified ? "checkmark.seal.fill" : "lock.shield.fill"
    }

    private var headerTitle: String {
        switch viewModel.step {
        case .sending:   return "جارٍ الإرسال..."
        case .enterCode: return "أدخل كود التحقق"
        case .verified:  return "تم التحقق!"
        }
    }

    private var headerSubtitle: String {
        switch viewModel.step {
        case .sending:   return "يتم إرسال رمز التحقق إلى \(phone)"
        case .enterCode: return "أرسلنا كودًا مكونًا من 6 أرقام إلى\n\(phone)"
        case .verified:  return "رقم هاتفك مؤكد"
        }
    }
}

// MARK: - Single OTP digit box
private struct OTPDigitBox: View {
    let digit: String
    let isFocused: Bool

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 10)
                .fill(Color(.systemGray6))
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(
                            isFocused
                                ? Color.brand
                                : digit.isEmpty
                                    ? Color.gray.opacity(0.3)
                                    : Color.brand.opacity(0.5),
                            lineWidth: isFocused ? 2 : 1
                        )
                )
            Text(digit)
                .font(.title2).fontWeight(.bold)
                .foregroundColor(.primary)
        }
        .frame(width: 46, height: 54)
        .animation(.easeInOut(duration: 0.15), value: isFocused)
    }
}
