// Shared/CommonUI.swift

import SwiftUI
// MARK: - Next Button (for Steps 1–6)
struct NextButton: View {
    let action: () -> Void
    let isDisabled: Bool
    
    var body: some View {
        Button(action: action) {
            Text("التالي")
                .font(.headline)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding()
        }
        .disabled(isDisabled)
        .foregroundColor(.white)
        .background(Color(hex: "#88417A"))
        .cornerRadius(12)
        .padding(.horizontal, 12)
        .padding(.bottom, 24)
    }
}

// MARK: - Finish Button (for Step 7)
struct FinishButton: View {
    let action: () -> Void
    let isDisabled: Bool
    
    var body: some View {
        Button(action: action) {
            Text("انهاء")
                .font(.headline)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding()
        }
        .disabled(isDisabled)
        .foregroundColor(.white)
        .background(Color(hex: "#88417A"))
        .cornerRadius(12)
        .padding(.horizontal, 12)
        .padding(.bottom, 24)
    }
}

// MARK: - Back Button
struct BackButton: View {
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text("←")
                .font(.title2)
                .foregroundColor(Color(hex: "#88417A"))
        }
    }
}


// MARK: - Image Preview
struct ImagePreview: View {
    let url: String
    let isSelected: Bool
    let onSelect: () -> Void
    let onDelete: () -> Void

    var body: some View {
        Button(action: onSelect) {
            ZStack {
                // Handle base64 or URL
                if url.hasPrefix("data:image") {
                    if let base64String = extractBase64(from: url),
                       let data = Data(base64Encoded: base64String),
                       let uiImage = UIImage(data: data) {
                        Image(uiImage: uiImage)
                            .resizable()
                            .scaledToFill()
                            .frame(width: 100, height: 100)
                            .clipped()
                            .cornerRadius(8)
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(isSelected ? Color(red: 136/255, green: 65/255, blue: 122/255) : Color.gray.opacity(0.3), lineWidth: 2)
                            )
                    } else {
                        placeholderImage()
                    }
                } else {
                    placeholderImage()
                }
                
                // Checkmark for main image
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 20))
                        .foregroundColor(Color(hex: "#88417A"))
                        .offset(x: 35, y: -35)
                }
                
                // Delete button
                Button(action: onDelete) {
                    Image(systemName: "x.circle.fill")
                        .font(.system(size: 16))
                        .foregroundColor(Color.red)
                        .offset(x: 35, y: -35)
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private func placeholderImage() -> some View {
        Rectangle()
            .fill(Color.gray.opacity(0.1))
            .frame(width: 100, height: 100)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(isSelected ? Color(red: 136/255, green: 65/255, blue: 122/255) : Color.gray.opacity(0.3), lineWidth: 2)
            )
    }
    
    private func extractBase64(from dataURL: String) -> String? {
        let components = dataURL.components(separatedBy: ",")
        return components.count > 1 ? components[1] : nil
    }
}
