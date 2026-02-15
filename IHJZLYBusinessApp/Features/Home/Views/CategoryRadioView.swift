// Features/Home/Views/CategoryRadioView.swift

import SwiftUI

struct CategoryRadioView: View {
    @Binding var selectedCategory: PropertyCategory
    
    var body: some View {
        HStack {
            Button("مناسبات") {
                selectedCategory = .events
            }
            .buttonStyle(CategoryButtonStyle(isSelected: selectedCategory == .events))
            
            Spacer() // 👈 This pushes buttons to edges
            
            Button("إقامات") {
                selectedCategory = .accommodations
            }
            .buttonStyle(CategoryButtonStyle(isSelected: selectedCategory == .accommodations))
        }
        .padding(.horizontal)
    }
}

struct CategoryButtonStyle: ButtonStyle {
    let isSelected: Bool
    
    func makeBody(configuration: Configuration) -> some View {
        HStack(spacing: 8) {
            configuration.label
                .font(.body)
                .foregroundColor(isSelected ? .primary : .secondary)
            
            if isSelected {
                Image(systemName: "circle.fill")
                    .foregroundColor(Color(red: 136/255, green: 65/255, blue: 122/255)) // #88417A
                    .font(.caption)
            } else {
                Image(systemName: "circle")
                    .foregroundColor(.gray)
                    .font(.caption)
            }
        }
        .padding(.horizontal)
        .padding(.vertical, 12)
        .background(isSelected ? Color.gray.opacity(0.1) : Color.clear)
        .cornerRadius(6)
    }
}
