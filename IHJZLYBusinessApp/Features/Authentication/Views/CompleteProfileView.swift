// Features/Authentication/Views/CompleteProfileView.swift

import SwiftUI

/// Step 3 of registration: collect profile info and create the account.
struct CompleteProfileView: View {

    @StateObject private var viewModel: CompleteProfileViewModel
    @EnvironmentObject private var appState: AppState

    init(phone: String) {
        _viewModel = StateObject(wrappedValue: CompleteProfileViewModel(phone: phone))
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {

                // ── Hero ─────────────────────────────────────────────────
                VStack(spacing: 8) {
                    ZStack {
                        Circle()
                            .fill(Color.brand.opacity(0.1))
                            .frame(width: 80, height: 80)
                        Image(systemName: "person.text.rectangle.fill")
                            .font(.system(size: 34))
                            .foregroundColor(.brand)
                    }
                    .padding(.top, 40)

                    Text("أكمل بياناتك")
                        .font(.title2).fontWeight(.bold)
                        .foregroundColor(.primary)

                    Text("خطوة أخيرة لإنشاء حسابك التجاري")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }

                // ── Phone read-only chip ──────────────────────────────────
                HStack(spacing: 10) {
                    Image(systemName: "phone.fill")
                        .foregroundColor(.secondary)
                        .frame(width: 20)
                    Text(viewModel.phone)
                        .font(.body)
                        .foregroundColor(.secondary)
                    Spacer()
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.green)
                }
                .padding(14)
                .background(Color(.systemGray6))
                .cornerRadius(12)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.green.opacity(0.4), lineWidth: 1.5)
                )
                .padding(.horizontal, 24)

                // ── Form fields ───────────────────────────────────────────
                VStack(spacing: 4) {
                    fieldWithError(
                        content: AuthField(
                            icon: "person.fill",
                            placeholder: "الاسم الكامل",
                            text: $viewModel.fullName
                        ),
                        error: viewModel.fullNameError
                    )

                    fieldWithError(
                        content: AuthField(
                            icon: "envelope.fill",
                            placeholder: "البريد الإلكتروني (اختياري)",
                            text: $viewModel.email,
                            keyboard: .emailAddress
                        ),
                        error: viewModel.emailError
                    )

                    fieldWithError(
                        content: PasswordTextField(
                            value: $viewModel.password,
                            placeholder: "كلمة المرور"
                        ),
                        error: viewModel.passwordError
                    )

                    fieldWithError(
                        content: PasswordTextField(
                            value: $viewModel.confirmPassword,
                            placeholder: "تأكيد كلمة المرور"
                        ),
                        error: viewModel.confirmPasswordError
                    )
                }
                .padding(.horizontal, 24)

                // ── Password hints ────────────────────────────────────────
                VStack(alignment: .leading, spacing: 4) {
                    PasswordHintRow(text: "6 أحرف على الأقل",
                                    met: viewModel.password.count >= 6)
                    PasswordHintRow(text: "كلمتا المرور متطابقتان",
                                    met: !viewModel.confirmPassword.isEmpty &&
                                         viewModel.confirmPassword == viewModel.password)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 28)

                // ── Error banner ──────────────────────────────────────────
                if let error = viewModel.errorMessage {
                    Text(error)
                        .foregroundColor(.red)
                        .font(.caption)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 24)
                }

                // ── Create account button ─────────────────────────────────
                Button(action: viewModel.createAccount) {
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
                    .background(viewModel.isLoading ? Color.gray.opacity(0.4) : .brand)
                    .cornerRadius(12)
                }
                .disabled(viewModel.isLoading)
                .padding(.horizontal, 24)
                .padding(.bottom, 40)
            }
        }
        .background(Color.pageBackground.ignoresSafeArea())
        .navigationTitle("إكمال التسجيل")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(viewModel.isLoading)
        // Success: set isAuthenticated → app root switches to MainTabView
        .onChange(of: viewModel.isRegistered) { _, registered in
            if registered { appState.isAuthenticated = true }
        }
    }

    // MARK: - Field + inline error helper
    @ViewBuilder
    private func fieldWithError<Content: View>(content: Content, error: String?) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            content
            if let error {
                Text(error)
                    .font(.caption)
                    .foregroundColor(.red)
                    .padding(.horizontal, 4)
                    .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
        .animation(.easeInOut(duration: 0.2), value: error)
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
                .foregroundColor(met ? .green : .secondary)
            Text(text)
                .font(.caption)
                .foregroundColor(met ? .green : .secondary)
        }
    }
}
