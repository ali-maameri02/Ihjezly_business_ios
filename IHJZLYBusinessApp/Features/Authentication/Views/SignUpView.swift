// Features/Authentication/Views/SignUpView.swift

import SwiftUI
import Combine

/// Step 1 of registration: collect phone number and send OTP.
struct SignUpView: View {

    @StateObject private var viewModel = SignUpViewModel()

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {

                // ── Hero ─────────────────────────────────────────────────
                VStack(spacing: 10) {
                    Image("ihjzlyapplogo")
                        .resizable()
                        .frame(width: 80, height: 80)
                        .clipShape(RoundedRectangle(cornerRadius: 18))
                        .shadow(color: .brand.opacity(0.3), radius: 10, x: 0, y: 4)

                    Text("إنشاء حساب تجاري")
                        .font(.title2).fontWeight(.bold)
                        .foregroundColor(.primary)

                    Text("أدخل رقم هاتفك لبدء التسجيل")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .padding(.top, 48)

                // ── Phone input ───────────────────────────────────────────
                VStack(alignment: .leading, spacing: 6) {
                    HStack(spacing: 8) {
                        // Country code badge
                        Text("+218")
                            .font(.headline)
                            .foregroundColor(.secondary)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 14)
                            .background(Color(.systemGray5))
                            .cornerRadius(12)

                        TextField("912345678", text: $viewModel.phoneNumber)
                            .keyboardType(.phonePad)
                            .textInputAutocapitalization(.never)
                            .padding(14)
                            .background(Color(.systemGray6))
                            .cornerRadius(12)
                            .onReceive(Just(viewModel.phoneNumber)) { newValue in
                                let filtered = newValue.filter { $0.isNumber }
                                viewModel.phoneNumber = String(filtered.prefix(9))
                            }
                    }

                    if let error = viewModel.errorMessage {
                        Text(error)
                            .foregroundColor(.red)
                            .font(.caption)
                            .padding(.horizontal, 4)
                    }
                }
                .padding(.horizontal, 24)

                // ── Send OTP button ───────────────────────────────────────
                Button(action: viewModel.sendOTPAndProceed) {
                    Group {
                        if viewModel.isLoading {
                            ProgressView().tint(.white)
                        } else {
                            Text("إرسال كود التحقق").fontWeight(.semibold)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .foregroundColor(.white)
                    .background(
                        viewModel.isLoading || viewModel.phoneNumber.count != 9
                            ? Color.gray.opacity(0.4) : .brand
                    )
                    .cornerRadius(12)
                }
                .disabled(viewModel.isLoading || viewModel.phoneNumber.count != 9)
                .padding(.horizontal, 24)
            }
            .padding(.bottom, 40)
        }
        .background(Color.pageBackground.ignoresSafeArea())
        // Navigate to OTP screen once OTP has been sent
        .navigationDestination(isPresented: $viewModel.navigateToOTP) {
            OTPVerificationView(phone: viewModel.normalizedPhone)
        }
    }
}
