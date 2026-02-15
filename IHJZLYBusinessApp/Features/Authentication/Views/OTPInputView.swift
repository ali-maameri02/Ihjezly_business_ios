// Features/Authentication/Components/OTPInputView.swift

import SwiftUI
import Combine

struct OTPInputView: View {
    @Binding var code: String
    @State private var fields: [String] = Array(repeating: "", count: 6)
    
    var body: some View {
        HStack(spacing: 12) {
            ForEach(0..<6, id: \.self) { index in
                ZStack {
                    if fields[index].isEmpty {
                        Rectangle()
                            .fill(Color.gray.opacity(0.2))
                            .frame(width: 50, height: 60)
                            .cornerRadius(8)
                    }
                    Text(fields[index])
                        .font(.title2)
                        .fontWeight(.bold)
                }
                .frame(width: 50, height: 60)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.gray.opacity(0.5), lineWidth: 1)
                )
            }
        }
        .onReceive(Just(code.prefix(6))) { newCode in
            let newFields = Array(newCode).map { String($0) }
            fields = newFields + Array(repeating: "", count: 6 - newFields.count)
        }
    }
}
