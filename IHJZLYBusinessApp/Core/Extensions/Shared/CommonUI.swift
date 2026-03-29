// Shared/CommonUI.swift

import SwiftUI

// MARK: - Next Button
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
        .background(isDisabled ? Color.gray.opacity(0.4) : .brand)
        .cornerRadius(12)
        .padding(.horizontal, 16)
        .padding(.bottom, 24)
    }
}

// MARK: - Finish Button
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
        .background(isDisabled ? Color.gray.opacity(0.4) : .brand)
        .cornerRadius(12)
        .padding(.horizontal, 16)
        .padding(.bottom, 24)
    }
}

// MARK: - Back Button
struct BackButton: View {
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(systemName: "arrow.right")
                .font(.system(size: 17, weight: .semibold))
                .foregroundColor(.brand)
                .frame(width: 36, height: 36)
                .background(Color.brand.opacity(0.1))
                .clipShape(Circle())
        }
    }
}

// MARK: - Rounded specific corners
extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(RoundedCorner(radius: radius, corners: corners))
    }
}

private struct RoundedCorner: Shape {
    var radius: CGFloat
    var corners: UIRectCorner
    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: corners,
            cornerRadii: CGSize(width: radius, height: radius)
        )
        return Path(path.cgPath)
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
            ZStack(alignment: .topTrailing) {
                imageContent
                    .frame(width: 100, height: 100)
                    .clipped()
                    .cornerRadius(8)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(isSelected ? Color.brand : Color.gray.opacity(0.3), lineWidth: 2)
                    )

                Button(action: onDelete) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 18))
                        .foregroundColor(.red)
                        .background(Color.cardBackground.clipShape(Circle()))
                }
                .offset(x: 6, y: -6)

                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 18))
                        .foregroundColor(.brand)
                        .background(Color.cardBackground.clipShape(Circle()))
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomTrailing)
                        .padding(4)
                }
            }
        }
        .buttonStyle(.plain)
    }

    @ViewBuilder
    private var imageContent: some View {
        if url.hasPrefix("data:image"),
           let range = url.range(of: ","),
           let data = Data(base64Encoded: String(url[range.upperBound...])),
           let uiImage = UIImage(data: data) {
            Image(uiImage: uiImage).resizable().scaledToFill()
        } else {
            Color(.systemGray5)
                .overlay(Image(systemName: "photo").foregroundColor(.secondary))
        }
    }
}
