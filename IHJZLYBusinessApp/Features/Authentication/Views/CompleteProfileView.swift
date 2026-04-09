// Features/Authentication/Views/CompleteProfileView.swift
import SwiftUI

struct CompleteProfileView: View {

    @StateObject private var viewModel: CompleteProfileViewModel
    @EnvironmentObject private var appState: AppState

    init(phone: String) {
        _viewModel = StateObject(wrappedValue: CompleteProfileViewModel(phone: phone))
    }

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 0) {

                // ── Hero ──────────────────────────────────────────────────
                VStack(spacing: 8) {
                    ZStack {
                        Circle()
                            .fill(Color.brand.opacity(0.1))
                            .frame(width: 90, height: 90)
                        Image(systemName: "person.text.rectangle.fill")
                            .font(.system(size: 40))
                            .foregroundStyle(Color.brand)
                    }
                    .padding(.top, 36)

                    Text("أكمل بياناتك")
                        .font(.title2).fontWeight(.bold)

                    Text("خطوة أخيرة لإنشاء حسابك التجاري")
                        .font(.subheadline)
                        .foregroundStyle(Color.secondary)
                }
                .padding(.bottom, 28)

                // ── Form card ─────────────────────────────────────────────
                VStack(spacing: 20) {

                    VStack(spacing: 4) {
                        AuthInputField(
                            placeholder: "الاسم الكامل",
                            text: $viewModel.fullName,
                            icon: "person.fill",
                            error: viewModel.fullNameError
                        )
                        phoneReadOnly
                        AuthInputField(
                            placeholder: "البريد الإلكتروني (اختياري)",
                            text: $viewModel.email,
                            icon: "envelope.fill",
                            keyboardType: .emailAddress,
                            error: viewModel.emailError
                        )
                        AuthInputField(
                            placeholder: "كلمة المرور",
                            text: $viewModel.password,
                            icon: "lock.fill",
                            isSecure: true,
                            error: viewModel.passwordError
                        )
                        AuthInputField(
                            placeholder: "تأكيد كلمة المرور",
                            text: $viewModel.confirmPassword,
                            icon: "lock.rotation.fill",
                            isSecure: true,
                            error: viewModel.confirmPasswordError
                        )
                    }

                    passwordHints

                    if let error = viewModel.errorMessage {
                        ErrorBanner(message: error)
                    }

                    AuthButton(
                        title: "إنشاء الحساب",
                        isLoading: viewModel.isLoading,
                        isEnabled: !viewModel.isLoading
                    ) {
                        viewModel.createAccount()
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
        .navigationTitle("إكمال التسجيل")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(viewModel.isLoading)
        .alert("تم إنشاء الحساب بنجاح! 🎉", isPresented: $viewModel.isRegistered) {
            Button("تسجيل الدخول") {
                appState.isAuthenticated = false
            }
        } message: {
            Text("يمكنك الآن تسجيل الدخول باستخدام رقم هاتفك وكلمة المرور.")
        }
    }

    // MARK: - Phone read-only chip
    private var phoneReadOnly: some View {
        HStack(spacing: 12) {
            Image(systemName: "phone.fill")
                .font(.subheadline)
                .foregroundStyle(Color.secondary)
                .frame(width: 20)
            Text(viewModel.phone)
                .font(.body)
                .foregroundStyle(Color.secondary)
            Spacer()
            Image(systemName: "checkmark.circle.fill")
                .foregroundStyle(Color.green)
                .font(.subheadline)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 14)
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.green.opacity(0.4), lineWidth: 1.5)
        )
    }

    // MARK: - Password hints
    private var passwordHints: some View {
        VStack(alignment: .leading, spacing: 4) {
            PasswordHintRow(text: "6 أحرف على الأقل", met: viewModel.password.count >= 6)
            PasswordHintRow(
                text: "حرف كبير واحد على الأقل",
                met: viewModel.password.contains(where: { $0.isUppercase })
            )
            PasswordHintRow(
                text: "كلمتا المرور متطابقتان",
                met: !viewModel.confirmPassword.isEmpty && viewModel.confirmPassword == viewModel.password
            )
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

// MARK: - Password hint row
private struct PasswordHintRow: View {
    let text: String
    let met: Bool
    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: met ? "checkmark.circle.fill" : "circle")
                .font(.caption)
                .foregroundStyle(met ? Color.green : Color.secondary)
            Text(text)
                .font(.caption)
                .foregroundStyle(met ? Color.green : Color.secondary)
        }
    }
}
