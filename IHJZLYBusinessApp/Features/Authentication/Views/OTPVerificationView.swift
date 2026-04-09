// Features/Authentication/Views/OTPVerificationView.swift
import SwiftUI

struct OTPVerificationView<Destination: View>: View {

    let phone: String
    @ViewBuilder let destination: () -> Destination

    @StateObject private var viewModel: OTPViewModel
    @FocusState  private var otpFocused: Bool

    init(phone: String, @ViewBuilder destination: @escaping () -> Destination) {
        self.phone = phone
        self.destination = destination
        _viewModel = StateObject(wrappedValue: OTPViewModel(phone: phone))
    }

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 0) {
                header
                    .padding(.top, 40)
                    .padding(.bottom, 32)

                VStack(spacing: 20) {
                    phoneChip

                    switch viewModel.step {
                    case .sending:
                        sendingIndicator
                    case .enterCode:
                        otpInputField
                        verifyButton
                        resendButton
                    case .verified:
                        successSection
                    }

                    if let error = viewModel.errorMessage {
                        ErrorBanner(message: error)
                            .transition(.opacity.combined(with: .move(edge: .top)))
                    }
                }
                .padding(24)
                .background(Color(.systemBackground))
                .clipShape(RoundedRectangle(cornerRadius: 20))
                .shadow(color: .black.opacity(0.07), radius: 12, y: 4)
                .padding(.horizontal, 20)
                .animation(.easeInOut(duration: 0.25), value: viewModel.step)
                .animation(.easeInOut(duration: 0.2), value: viewModel.errorMessage)

                Spacer(minLength: 32)
            }
        }
        .background(Color(.secondarySystemBackground).ignoresSafeArea())
        .navigationTitle("التحقق من الهاتف")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear { viewModel.sendOTP() }
        .navigationDestination(isPresented: Binding(
            get: { viewModel.step == .verified },
            set: { _ in }
        )) {
            destination()
        }
    }

    // MARK: - Header
    private var header: some View {
        VStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(Color.brand.opacity(0.1))
                    .frame(width: 88, height: 88)
                Image(systemName: headerIcon)
                    .font(.system(size: 38))
                    .foregroundStyle(Color.brand)
                    .id(viewModel.step)
            }
            .animation(.spring(response: 0.4, dampingFraction: 0.7), value: viewModel.step)

            Text(headerTitle)
                .font(.title3).fontWeight(.bold)

            Text(headerSubtitle)
                .font(.subheadline)
                .foregroundStyle(Color.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 24)
        }
    }

    // MARK: - Phone chip
    private var phoneChip: some View {
        HStack(spacing: 10) {
            Image(systemName: "phone.fill")
                .foregroundStyle(Color.brand)
                .font(.subheadline)
            Text(phone)
                .font(.subheadline).fontWeight(.medium)
            Spacer()
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
        .background(Color.brand.opacity(0.08))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    // MARK: - Sending indicator
    private var sendingIndicator: some View {
        HStack(spacing: 10) {
            ProgressView()
            Text("جارٍ إرسال رمز التحقق...")
                .font(.subheadline)
                .foregroundStyle(Color.secondary)
        }
        .padding(.vertical, 8)
    }

    // MARK: - 6-box OTP input
    private var otpInputField: some View {
        VStack(spacing: 10) {
            HStack(spacing: 10) {
                ForEach(0..<6, id: \.self) { index in
                    OTPDigitBox(
                        digit: digit(at: index),
                        isFocused: otpFocused && viewModel.otpCode.count == index
                    )
                }
            }
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
                .foregroundStyle(Color.secondary)
        }
    }

    // MARK: - Verify button
    private var verifyButton: some View {
        AuthButton(
            title: "تأكيد",
            isLoading: viewModel.isVerifying,
            isEnabled: viewModel.otpCode.count == 6 && !viewModel.isVerifying
        ) {
            viewModel.verifyOTP()
        }
    }

    // MARK: - Resend button
    private var resendButton: some View {
        Group {
            if viewModel.resendCountdown > 0 {
                HStack(spacing: 4) {
                    Text("إعادة الإرسال بعد")
                        .font(.subheadline)
                        .foregroundStyle(Color.secondary)
                    Text("\(viewModel.resendCountdown)s")
                        .font(.subheadline).fontWeight(.bold)
                        .foregroundStyle(Color.brand)
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
                        Text("إعادة إرسال الرمز")
                            .font(.subheadline).fontWeight(.semibold)
                    }
                    .foregroundStyle(Color.brand)
                }
                .disabled(viewModel.isSending)
            }
        }
        .animation(.easeInOut(duration: 0.2), value: viewModel.resendCountdown)
    }

    // MARK: - Success flash
    private var successSection: some View {
        VStack(spacing: 14) {
            Image(systemName: "checkmark.seal.fill")
                .font(.system(size: 56))
                .foregroundStyle(Color.green)
            Text("تم التحقق بنجاح ✓")
                .font(.headline)
                .foregroundStyle(Color.green)
            Text("جارٍ الانتقال...")
                .font(.subheadline)
                .foregroundStyle(Color.secondary)
            ProgressView().tint(Color.brand)
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
        case .enterCode: return "أدخل رمز التحقق"
        case .verified:  return "تم التحقق!"
        }
    }

    private var headerSubtitle: String {
        switch viewModel.step {
        case .sending:   return "يتم إرسال رمز التحقق إلى \(phone)"
        case .enterCode: return "تم إرسال رمز مكون من 6 أرقام إلى\n\(phone)"
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
                .fill(Color(.secondarySystemBackground))
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(
                            isFocused
                                ? Color.brand
                                : digit.isEmpty
                                    ? Color.secondary.opacity(0.2)
                                    : Color.brand.opacity(0.5),
                            lineWidth: isFocused ? 2 : 1
                        )
                )
            Text(digit)
                .font(.title2).fontWeight(.bold)
        }
        .frame(width: 46, height: 54)
        .animation(.easeInOut(duration: 0.15), value: isFocused)
    }
}
