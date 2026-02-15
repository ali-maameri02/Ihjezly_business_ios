// Features/Home/Views/AdPackagesGrid.swift

import SwiftUI

struct AdPackagesGrid: View {
    var body: some View {
        VStack(spacing: 16) { // ✅ 16pt between cards — matches PNG
            AdPackageCard(
                title: "باقَة فردية",
                price: "100",
                date: "7 يناير",
                description: "الحل الأمثل لبداية صحيحة",
                status: .active,
                adsCount: 1
            )
            
            AdPackageCard(
                title: "باقَة برونزية",
                price: "250",
                date: "7 يناير",
                description: "الحل الأمثل لبداية صحيحة",
                status: .inactive,
                adsCount: 1
            )
        }
        .padding(.bottom, 80)
        .frame(maxWidth: .infinity)
    }
}
