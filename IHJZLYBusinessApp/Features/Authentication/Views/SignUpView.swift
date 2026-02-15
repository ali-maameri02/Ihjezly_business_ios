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
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)
                
                HStack(spacing: 8) {
                    Text("+218")
                        .font(.headline)
                        .foregroundColor(.gray)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 12)
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(8)
                    
                    TextField("912345678", text: $viewModel.phoneNumber)
                        .keyboardType(.phonePad)
                        .textInputAutocapitalization(.never)
                        .onReceive(Just(viewModel.phoneNumber)) { newValue in
                            let filtered = newValue.filter { $0.isNumber }
                            viewModel.phoneNumber = String(filtered.prefix(9))
                        }
                }
                .padding()
                .background(Color.gray.opacity(0.1))
                .cornerRadius(8)
                .padding(.horizontal)
                
                if let error = viewModel.errorMessage {
                    Text(error)
                        .foregroundColor(.red)
                        .font(.caption)
                        .padding(.horizontal)
                }
                
                Button(action: {
                    Task {
                        await viewModel.sendOTP()
                        if viewModel.isSuccess {
                            onOTPSent(viewModel.phoneNumber) // 9-digit only
                        }
                    }
                }) {
                    Text("إرسال كود التحقق")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(viewModel.isLoading ? Color.gray : Color.purple)
                        .cornerRadius(10)
                }
                .disabled(viewModel.isLoading || viewModel.phoneNumber.count != 9)
                .padding(.horizontal)
            }
            .padding(.top, 60)
        }
        .background(Color.white)
        .ignoresSafeArea()
    }
}
