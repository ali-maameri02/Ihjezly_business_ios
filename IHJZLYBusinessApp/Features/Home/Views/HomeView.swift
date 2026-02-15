// Features/Home/Views/HomeView.swift

import SwiftUI

struct HomeView: View {
    @State private var selectedTab: Tab = .units
    @State private var selectedCategory: PropertyCategory = .accommodations
    
    var body: some View {
        
        NavigationStack {
            VStack(spacing: 0) {
                AppBarView()
                    .frame(height: 80)
                
                ScrollView {
                    VStack(spacing: 24) {
                        TabToggleView(selectedTab: $selectedTab)
                        
                        if selectedTab == .units {
                            CategoryRadioView(selectedCategory: $selectedCategory)
                            
                            if selectedCategory == .accommodations {
                                SectionTitleView(text: "تصنيف العقارات")

                            }
                            if selectedCategory == .events {
                                SectionTitleView(text: "تصنيف المناسبات")
                            }
                        }
                        // ❌ Do NOT show section title for ads
                        // (No need for .hidden — just don't render it)
                        
                        if selectedTab == .units {
                            StaticUnitCardsGrid(category: selectedCategory)
                        } else {
                            AdPackagesGrid()
                        }
                        
                        Spacer(minLength: 20)
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 16)
                }
            }
            .navigationTitle("")
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
