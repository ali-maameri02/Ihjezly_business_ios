// Features/Home/Views/TabToggleView.swift

import SwiftUI

struct TabToggleView: View {
    @Binding var selectedTab: Tab

    var body: some View {
        HStack(spacing: 8) {
            TabPill(title: "إضافة إعلان", isActive: selectedTab == .ads) {
                selectedTab = .ads
            }
            TabPill(title: "إضافة وحدة", isActive: selectedTab == .units) {
                selectedTab = .units
            }
        }
    }
}

private struct TabPill: View {
    let title: String
    let isActive: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.subheadline)
                .fontWeight(isActive ? .bold : .regular)
                .foregroundColor(isActive ? .white : .primary)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 11)
                .background(isActive ? Color.brand : Color(.systemGray5))
                .cornerRadius(10)
        }
        .buttonStyle(.plain)
        .animation(.easeInOut(duration: 0.2), value: isActive)
    }
}

struct TabButtonStyle: ButtonStyle {
    let isActive: Bool
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline)
            .foregroundColor(isActive ? .white : .primary)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background(isActive ? Color.brand : Color(.systemGray5))
            .cornerRadius(8)
    }
}
