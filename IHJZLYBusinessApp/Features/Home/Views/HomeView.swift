// Features/Home/Views/HomeView.swift

import SwiftUI

struct HomeView: View {
    @State private var selectedTab: Tab = .units
    @State private var selectedCategory: PropertyCategory = .accommodations

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                AppBarView()

                ScrollView {
                    VStack(spacing: 20) {
                        TabToggleView(selectedTab: $selectedTab)

                        if selectedTab == .units {
                            CategoryRadioView(selectedCategory: $selectedCategory)
                            SectionTitleView(text: selectedCategory == .accommodations
                                             ? "تصنيف العقارات"
                                             : "تصنيف المناسبات")
                            StaticUnitCardsGrid(category: selectedCategory)
                        } else {
                            AddAdView()
                        }

                        Spacer(minLength: 20)
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 16)
                }
            }
            .background(Color.pageBackground)
            .navigationBarHidden(true)
            .ignoresSafeArea(.keyboard)
        }
    }
}

enum Tab: Hashable {
    case units
    case ads
}

enum PropertyCategory: String, CaseIterable {
    case accommodations = "إقامات"
    case events = "قاعات مناسبات"
}
