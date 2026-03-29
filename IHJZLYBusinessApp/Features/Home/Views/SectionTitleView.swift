// Features/Home/Views/SectionTitleView.swift

import SwiftUI

struct SectionTitleView: View {
    let text: String

    var body: some View {
        VStack(alignment: .trailing, spacing: 4) {
            Text(text)
                .font(.title3)
                .fontWeight(.semibold)
                .foregroundColor(.primary)
                .multilineTextAlignment(.trailing)

            Rectangle()
                .fill(Color.brand)
                .frame(width: 40, height: 3)
                .cornerRadius(2)
        }
        .frame(maxWidth: .infinity, alignment: .trailing)
        .padding(.bottom, 4)
    }
}
