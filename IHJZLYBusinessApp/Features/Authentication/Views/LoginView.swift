// Features/Authentication/Views/LoginView.swift

import SwiftUI
import Combine

struct LoginView: View {
    @StateObject private var viewModel: LoginViewModel // ✅ Declare type only
    let onSignUpTapped: () -> Void
    
    init(appState: AppState, onSignUpTapped: @escaping () -> Void) {
        _viewModel = StateObject(wrappedValue: LoginViewModel(appState: appState))
        self.onSignUpTapped = onSignUpTapped
    }
    
    var body: some View {
        VStack(spacing: 24) {
            // Logo
            Image("ihjzlyapplogo")
                .resizable()
                .frame(width: 80, height: 80)
            
            Text("تسجيل الدخول")
                .font(.title2)
                .fontWeight(.semibold)
                .foregroundColor(.primary)
            
            HStack {
                Image(systemName: "phone.fill")
                    .foregroundColor(.gray)
                TextField("912345678", text: $viewModel.phoneDigits)
                    .keyboardType(.phonePad)
                    .textInputAutocapitalization(.never)
                    .onChange(of: viewModel.phoneDigits) { newValue in
                        let digits = newValue.filter { $0.isNumber }
                        viewModel.phoneDigits = String(digits.prefix(9))
                    }
            }
            .padding()
            .background(Color.gray.opacity(0.1))
            .cornerRadius(8)
            .padding(.horizontal)
            
            PasswordTextField(value: $viewModel.password, placeholder: "كلمة المرور")
                .padding(.horizontal)
            
            if let error = viewModel.errorMessage {
                Text(error)
                    .foregroundColor(.red)
                    .font(.caption)
                    .padding(.horizontal)
            }
            
            Button(action: {
                Task { await viewModel.login() }
            }) {
                Text("تسجيل الدخول")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(viewModel.isLoading ? Color.gray : Color.purple)
                    .cornerRadius(8)
            }
            .disabled(viewModel.isLoading || viewModel.phoneDigits.isEmpty || viewModel.password.isEmpty)
            .padding(.horizontal)
            
            HStack {
                Text("ليس لديك حساب؟")
                    .foregroundColor(.secondary)
                Button("إنشاء حساب") {
                    onSignUpTapped() // ✅ No args
                }
                .foregroundColor(Color.purple)
                .fontWeight(.medium)
            }
            .padding(.top, 16)
        }
        .padding(.top, 40)
        .background(Color.white)
        .ignoresSafeArea()
        .alert("نجاح", isPresented: $viewModel.showSuccessAlert) {
            Button("موافق") { }
        } message: {
            Text("تم تسجيل الدخول بنجاح!")
        }
    }
}

struct PasswordTextField: View {
    @Binding var value: String
    let placeholder: String
    @State private var isSecure = true
    
    var body: some View {
        HStack {
            Image(systemName: "lock.fill")
                .foregroundColor(.gray)
            if isSecure {
                SecureField(placeholder, text: $value)
            } else {
                TextField(placeholder, text: $value)
            }
            Button(action: { isSecure.toggle() }) {
                Image(systemName: isSecure ? "eye.slash.fill" : "eye.fill")
                    .foregroundColor(.gray)
            }
        }
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(8)
    }
}
