// Features/Authentication/Views/OTPVerificationView.swift

import SwiftUI

struct OTPVerificationView: View {
    let phoneNumber: String
    let onRegisterSuccess: () -> Void
    @StateObject var viewModel: OTPViewModel

    init(phoneNumber: String, onRegisterSuccess: @escaping () -> Void) {
        self.phoneNumber = phoneNumber
        self.onRegisterSuccess = onRegisterSuccess
        _viewModel = StateObject(wrappedValue: OTPViewModel(phoneNumber: phoneNumber))
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                VStack(spacing: 8) {
                    Text("أدخل كود التحقق")
                        .font(.title2).fontWeight(.bold).foregroundColor(.primary)

                    Text("أرسلنا كودًا مكونًا من 6 أرقام إلى \(phoneNumber)")
                        .font(.subheadline).foregroundColor(.secondary)
                        .multilineTextAlignment(.center).padding(.horizontal, 32)
                }
                .padding(.top, 40)

                OTPInputView(code: $viewModel.otpCode)
                    .padding(.horizontal, 24)

                VStack(spacing: 14) {
                    AuthField(icon: "person.fill", placeholder: "الاسم الكامل", text: $viewModel.fullName)

                    AuthField(icon: "envelope.fill", placeholder: "البريد الإلكتروني (اختياري)",
                               text: $viewModel.email, keyboard: .emailAddress)

                    PasswordTextField(value: $viewModel.password, placeholder: "كلمة المرور")

                    PasswordTextField(value: $viewModel.confirmPassword, placeholder: "تأكيد كلمة المرور")
                }
                .padding(.horizontal, 24)

                if let error = viewModel.errorMessage {
                    Text(error)
                        .foregroundColor(.red).font(.caption)
                        .multilineTextAlignment(.center).padding(.horizontal, 24)
                }

                Button {
                    Task {
                        await viewModel.register()
                        if viewModel.isSuccess { onRegisterSuccess() }
                    }
                } label: {
                    Group {
                        if viewModel.isLoading {
                            ProgressView().tint(.white)
                        } else {
                            Text("إنشاء الحساب").fontWeight(.semibold)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .foregroundColor(.white)
                    .background(!isFormValid || viewModel.isLoading ? Color.gray.opacity(0.4) : .brand)
                    .cornerRadius(12)
                }
                .disabled(!isFormValid || viewModel.isLoading)
                .padding(.horizontal, 24)

                Button("إعادة إرسال الكود") {
                    Task { await viewModel.resendOTP() }
                }
                .font(.subheadline)
                .foregroundColor(.brand)
                .padding(.bottom, 40)
            }
        }
        .background(Color.pageBackground.ignoresSafeArea())
    }

    private var isFormValid: Bool {
        viewModel.otpCode.count == 6 &&
        !viewModel.fullName.isEmpty &&
        !viewModel.password.isEmpty &&
        viewModel.password == viewModel.confirmPassword
    }
}
