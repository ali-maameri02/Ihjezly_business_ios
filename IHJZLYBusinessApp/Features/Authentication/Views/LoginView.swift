// Features/Authentication/Views/LoginView.swiftttt

import SwiftUI
import Combine

struct LoginView: View {
    @StateObject private var viewModel: LoginViewModel
    @State private var showSignUp = false

    init(appState: AppState) {
        _viewModel = StateObject(wrappedValue: LoginViewModel(appState: appState))
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Logo
                VStack(spacing: 12) {
                    Image("ihjzlyapplogo")
                        .resizable()
                        .frame(width: 90, height: 90)
                        .clipShape(RoundedRectangle(cornerRadius: 20))
                        .shadow(color: .brand.opacity(0.3), radius: 10, x: 0, y: 4)

                    Text("تسجيل الدخول")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                }
                .padding(.top, 48)

                VStack(spacing: 16) {
                    AuthField(icon: "person.fill", placeholder: "رقم الهاتف أو البريد الإلكتروني",
                               text: $viewModel.phoneDigits, keyboard: .emailAddress)

                    PasswordTextField(value: $viewModel.password, placeholder: "كلمة المرور")
                }
                .padding(.horizontal, 24)

                if let error = viewModel.errorMessage {
                    Text(error)
                        .foregroundColor(.red)
                        .font(.caption)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 24)
                }

                Button {
                    Task { await viewModel.login() }
                } label: {
                    Group {
                        if viewModel.isLoading {
                            ProgressView().tint(.white)
                        } else {
                            Text("تسجيل الدخول").fontWeight(.semibold)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .foregroundColor(.white)
                    .background(viewModel.isLoading ? Color.gray.opacity(0.4) : .brand)
                    .cornerRadius(12)
                }
                .disabled(viewModel.isLoading || viewModel.phoneDigits.isEmpty || viewModel.password.isEmpty)
                .padding(.horizontal, 24)

                // ── Divider ───────────────────────────────────────────────
                HStack(spacing: 12) {
                    Rectangle().fill(Color.secondary.opacity(0.3)).frame(height: 1)
                    Text("أو").font(.caption).foregroundColor(.secondary)
                    Rectangle().fill(Color.secondary.opacity(0.3)).frame(height: 1)
                }
                .padding(.horizontal, 24)

                // ── Register button ───────────────────────────────────────
                NavigationLink(destination: SignUpView()) {
                    HStack(spacing: 8) {
                        Image(systemName: "person.badge.plus")
                        Text("إنشاء حساب جديد").fontWeight(.semibold)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .foregroundColor(.brand)
                    .background(Color.brand.opacity(0.1))
                    .cornerRadius(12)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.brand.opacity(0.4), lineWidth: 1.5)
                    )
                }
                .padding(.horizontal, 24)
            }
            .padding(.bottom, 40)
        }
        .background(Color.pageBackground.ignoresSafeArea())
        .alert("نجاح", isPresented: $viewModel.showSuccessAlert) {
            Button("موافق") {}
        } message: {
            Text("تم تسجيل الدخول بنجاح!")
        }
    }
}

// MARK: - Shared auth field
struct AuthField: View {
    let icon: String
    let placeholder: String
    @Binding var text: String
    var keyboard: UIKeyboardType = .default

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundColor(.secondary)
                .frame(width: 20)
            TextField(placeholder, text: $text)
                .keyboardType(keyboard)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()
        }
        .padding(14)
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

struct PasswordTextField: View {
    @Binding var value: String
    let placeholder: String
    @State private var isSecure = true

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "lock.fill")
                .foregroundColor(.secondary)
                .frame(width: 20)
            Group {
                if isSecure {
                    SecureField(placeholder, text: $value)
                } else {
                    TextField(placeholder, text: $value)
                }
            }
            Button { isSecure.toggle() } label: {
                Image(systemName: isSecure ? "eye.slash" : "eye")
                    .foregroundColor(.secondary)
            }
        }
        .padding(14)
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}
