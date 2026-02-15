// Features/Home/Views/StaticPropertyCardView.swift

import SwiftUI

struct StaticPropertyCardView: View {
    let card: StaticCard
    
    var body: some View { // ✅ MUST have 'body'
        VStack(spacing: 8) {
            Image(card.imageName)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(height: 160)
                .clipped()
                .cornerRadius(8)
            
            Text(card.title)
                .font(.headline)
                .fontWeight(.medium)
                .lineLimit(2)
                .padding(.horizontal, 8)
        }
        .background(Color.white)
        .cornerRadius(12)
        .shadow(radius: 3)
        .frame(height: 240)
    }
}
