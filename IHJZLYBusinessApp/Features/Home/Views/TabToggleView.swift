// Features/Home/Views/TabToggleView.swift

import SwiftUI

struct TabToggleView: View {
    @Binding var selectedTab: Tab
    
    var body: some View {
        HStack(spacing: 8) {
           
            Button("إضافة إعلان") {
                selectedTab = .ads
            }
            .buttonStyle(TabButtonStyle(isActive: selectedTab == .ads))
            Button("إضافة وحدة") {
                selectedTab = .units
            }
            .buttonStyle(TabButtonStyle(isActive: selectedTab == .units))
            
        }
        .padding(.horizontal)
    }
}

struct TabButtonStyle: ButtonStyle {
    let isActive: Bool
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline)
            .foregroundColor(isActive ? .white : Color.primary)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background(isActive ? Color(hex: "#88417A") : Color.gray.opacity(0.1))
            .cornerRadius(8)
    }
}
