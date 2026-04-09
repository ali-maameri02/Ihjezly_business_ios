// Features/Authentication/Views/RegistrationSuccessView.swift

import SwiftUI

/// Final screen of the registration flow.
/// Shown after the backend confirms account creation.
/// Does NOT navigate to home automatically — user taps "تسجيل الدخول" to proceed.
struct RegistrationSuccessView: View {

    let name: String
    /// Called when the user taps "تسجيل الدخول" — resets the NavigationPath to root.
    let onGoToLogin: () -> Void

    var body: some View {
        VStack(spacing: 32) {
            Spacer()

            // ── Success icon ──────────────────────────────────────────────
            ZStack {
                Circle()
                    .fill(Color.green.opacity(0.12))
                    .frame(width: 120, height: 120)
                Image(systemName: "checkmark.seal.fill")
                    .font(.system(size: 60))
                    .foregroundColor(.green)
            }

            // ── Message ───────────────────────────────────────────────────
            VStack(spacing: 10) {
                Text("تم إنشاء الحساب بنجاح!")
                    .font(.title2).fontWeight(.bold)

                Text("مرحباً \(name.isEmpty ? "بك" : name) 👋")
                    .font(.headline)
                    .foregroundColor(.secondary)

                Text("حسابك التجاري جاهز الآن.\nسجّل دخولك للبدء في استخدام التطبيق.")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
            }

            Spacer()

            // ── Go to login button ────────────────────────────────────────
            Button(action: onGoToLogin) {
                Text("تسجيل الدخول")
                    .fontWeight(.semibold)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .foregroundColor(.white)
                    .background(Color.brand)
                    .cornerRadius(12)
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 48)
        }
        .background(Color.pageBackground.ignoresSafeArea())
        .navigationTitle("")
        .navigationBarBackButtonHidden(true)
        .toolbar(.hidden, for: .navigationBar)
    }
}

// Keep the Notification.Name extension so AuthFlowView's onReceive doesn't break
// (it's now unused but harmless)
extension Notification.Name {
    static let resetToLogin = Notification.Name("resetToLogin")
}
