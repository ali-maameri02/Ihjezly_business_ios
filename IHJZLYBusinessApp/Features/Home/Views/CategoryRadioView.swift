// Features/Home/Views/CategoryRadioView.swift

import SwiftUI

struct CategoryRadioView: View {
    @Binding var selectedCategory: PropertyCategory

    var body: some View {
        HStack(spacing: 12) {
            ForEach(PropertyCategory.allCases, id: \.self) { cat in
                Button {
                    withAnimation(.easeInOut(duration: 0.2)) { selectedCategory = cat }
                } label: {
                    HStack(spacing: 8) {
                        Image(systemName: selectedCategory == cat ? "largecircle.fill.circle" : "circle")
                            .font(.system(size: 16))
                            .foregroundColor(selectedCategory == cat ? .brand : .secondary)
                        Text(cat.rawValue)
                            .font(.subheadline)
                            .fontWeight(selectedCategory == cat ? .semibold : .regular)
                            .foregroundColor(selectedCategory == cat ? .primary : .secondary)
                    }
                    .padding(.horizontal, 14)
                    .padding(.vertical, 9)
                    .background(selectedCategory == cat ? Color.brand.opacity(0.08) : Color(.systemGray6))
                    .cornerRadius(20)
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(selectedCategory == cat ? Color.brand.opacity(0.4) : Color.clear, lineWidth: 1)
                    )
                }
                .buttonStyle(.plain)
            }
            Spacer()
        }
    }
}

struct CategoryButtonStyle: ButtonStyle {
    let isSelected: Bool
    func makeBody(configuration: Configuration) -> some View {
        HStack(spacing: 8) {
            configuration.label
                .font(.body)
                .foregroundColor(isSelected ? .primary : .secondary)
            Image(systemName: isSelected ? "circle.fill" : "circle")
                .foregroundColor(isSelected ? .brand : .gray)
                .font(.caption)
        }
        .padding(.horizontal)
        .padding(.vertical, 12)
        .background(isSelected ? Color.brand.opacity(0.08) : Color.clear)
        .cornerRadius(6)
    }
}
