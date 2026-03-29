// Features/Authentication/Views/SignUpView.swift

import SwiftUI
import Combine

struct SignUpView: View {
    @StateObject private var viewModel = SignUpViewModel()
    let onOTPSent: (String) -> Void

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                Text("إنشاء حساب")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                    .padding(.top, 48)

                HStack(spacing: 8) {
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
                .padding(.horizontal, 24)

                if let error = viewModel.errorMessage {
                    Text(error)
                        .foregroundColor(.red)
                        .font(.caption)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 24)
                }

                Button {
                    Task {
                        await viewModel.sendOTP()
                        if viewModel.isSuccess { onOTPSent(viewModel.phoneNumber) }
                    }
                } label: {
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
                    .background(viewModel.isLoading ? Color.gray.opacity(0.4) : .brand)
                    .cornerRadius(12)
                }
                .disabled(viewModel.isLoading || viewModel.phoneNumber.count != 9)
                .padding(.horizontal, 24)
            }
            .padding(.bottom, 40)
        }
        .background(Color.pageBackground.ignoresSafeArea())
    }
}
