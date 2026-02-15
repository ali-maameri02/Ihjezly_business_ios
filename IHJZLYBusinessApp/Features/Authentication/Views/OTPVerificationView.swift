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
            VStack(spacing: 24) {
                Text("أدخل كود التحقق")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)
                
                Text("أرسلنا كودًا مكونًا من 6 أرقام إلى \(phoneNumber)")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
                
                OTPInputView(code: $viewModel.otpCode)
                    .padding(.top, 20)
                
                // Full registration form
                TextField("الاسم الكامل", text: $viewModel.fullName)
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(8)
                    .padding(.horizontal)
                
                TextField("البريد الإلكتروني (اختياري)", text: $viewModel.email)
                    .keyboardType(.emailAddress)
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(8)
                    .padding(.horizontal)
                
                PasswordTextField(value: $viewModel.password, placeholder: "كلمة المرور")
                    .padding(.horizontal)
                
                PasswordTextField(value: $viewModel.confirmPassword, placeholder: "تأكيد كلمة المرور")
                    .padding(.horizontal)
                
                if let error = viewModel.errorMessage {
                    Text(error)
                        .foregroundColor(.red)
                        .font(.caption)
                        .padding(.horizontal)
                }
                
                Button(action: {
                    Task {
                        await viewModel.register()
                        if viewModel.isSuccess {
                            onRegisterSuccess()
                        }
                    }
                }) {
                    Text("إنشاء الحساب")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(viewModel.isLoading ? Color.gray : Color.purple)
                        .cornerRadius(10)
                }
                .disabled(!isFormValid || viewModel.isLoading)
                .padding(.horizontal)
                
                Button("إعادة إرسال الكود") {
                    Task {
                        await viewModel.resendOTP()
                    }
                }
                .foregroundColor(Color.purple)
                .padding(.top, 8)
            }
            .padding(.top, 40)
        }
        .background(Color.white)
        .ignoresSafeArea()
    }
    
    private var isFormValid: Bool {
        viewModel.otpCode.count == 6 &&
        !viewModel.fullName.isEmpty &&
        !viewModel.password.isEmpty &&
        viewModel.password == viewModel.confirmPassword
    }
}
