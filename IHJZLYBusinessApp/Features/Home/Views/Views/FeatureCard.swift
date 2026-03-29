
import SwiftUI
struct FeatureCard: View {
    let feature: Feature
    let isSelected: Bool
    let onSelect: () -> Void

    var body: some View {
        Button(action: onSelect) {
            VStack(spacing: 8) {
                Image(systemName: feature.iconName)
                    .font(.system(size: 24))
                    .foregroundColor(isSelected ? .white : Color.brand)

                Text(feature.arabicName)
                    .font(.caption)
                    .foregroundColor(isSelected ? .white : Color.brand)
                    .multilineTextAlignment(.center)
            }
            .frame(width: 100, height: 100)
            .background(isSelected ? Color.brand : .white)
            .cornerRadius(8)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(isSelected ? Color.brand : Color.gray.opacity(0.3), lineWidth: 1)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}
