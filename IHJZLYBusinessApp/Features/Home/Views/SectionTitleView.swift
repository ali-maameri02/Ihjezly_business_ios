// Features/Home/Views/SectionTitleView.swift

import SwiftUI

struct SectionTitleView: View {
    let text: String
    
    var body: some View {
        VStack(alignment: .trailing, spacing: 0) {
            Text(text)
                .font(.title3)
                .fontWeight(.semibold)
                .foregroundColor(.primary)
                .multilineTextAlignment(.trailing)
            
            // Underline: 20% of text width, aligned to text's trailing edge
            GeometryReader { geometry in
                let textWidth = geometry.size.width
                Rectangle()
                    .fill(Color(red: 136/255, green: 65/255, blue: 122/255)) // #88417A
                    .frame(width: textWidth * 0.2, height: 2)
                    .frame(maxWidth: .infinity, alignment: .trailing)
            }
            .frame(height: 2)
        }
        .padding(.top, 2)
        .padding(.bottom, 18)
        .frame(maxWidth: .infinity, alignment: .trailing)
    }
}
