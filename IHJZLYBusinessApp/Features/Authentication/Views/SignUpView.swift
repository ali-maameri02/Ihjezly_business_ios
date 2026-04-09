// Features/Authentication/Views/SignUpView.swift
import SwiftUI
import Combine

struct SignUpView: View {

    @StateObject private var viewModel = SignUpViewModel()
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 0) {

                // ── Hero ──────────────────────────────────────────────────
                VStack(spacing: 8) {
                    ZStack {
                        Circle()
                            .fill(Color.brand.opacity(0.1))
                            .frame(width: 90, height: 90)
                        Image(systemName: "person.badge.plus.fill")
                            .font(.system(size: 40))
                            .foregroundStyle(Color.brand)
                    }
                    .padding(.top, 36)

                    Text("إنشاء حساب تجاري")
                        .font(.title2).fontWeight(.bold)
                        .foregroundStyle(Color.primary)

                    Text("أدخل رقم هاتفك لبدء التسجيل")
                        .font(.subheadline)
                        .foregroundStyle(Color.secondary)
                }
                .padding(.bottom, 32)

                // ── Form card ─────────────────────────────────────────────
                VStack(spacing: 20) {

                    AuthInputField(
                        placeholder: "رقم الهاتف (مثال: 218910024433)",
                        text: $viewModel.phoneNumber,
                        icon: "phone.fill",
                        keyboardType: .phonePad,
                        error: viewModel.phoneError
                    )

                    if let error = viewModel.errorMessage {
                        ErrorBanner(message: error)
                    }

                    AuthButton(
                        title: "التالي",
                        isLoading: viewModel.isLoading,
                        isEnabled: !viewModel.phoneNumber.trimmingCharacters(in: .whitespaces).isEmpty
                    ) {
                        viewModel.sendOTPAndProceed()
                    }

                    Button(action: { dismiss() }) {
                        HStack(spacing: 4) {
                            Text("لديك حساب بالفعل؟")
                                .font(.subheadline)
                                .foregroundStyle(Color.secondary)
                            Text("تسجيل الدخول")
                                .font(.subheadline).fontWeight(.semibold)
                                .foregroundStyle(Color.brand)
                        }
                    }
                }
                .padding(24)
                .background(Color(.systemBackground))
                .clipShape(RoundedRectangle(cornerRadius: 20))
                .shadow(color: .black.opacity(0.07), radius: 12, y: 4)
                .padding(.horizontal, 20)
                .padding(.bottom, 32)
            }
        }
        .background(Color(.secondarySystemBackground).ignoresSafeArea())
        .navigationTitle("إنشاء حساب")
        .navigationBarTitleDisplayMode(.inline)
        .navigationDestination(isPresented: $viewModel.navigateToOTP) {
            OTPVerificationView(phone: viewModel.phoneNumber) {
                CompleteProfileView(phone: viewModel.phoneNumber)
            }
        }
    }
}
