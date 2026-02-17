// Features/Main/Views/MainTabView.swift

import SwiftUI

struct MainTabView: View {
    var body: some View {
        TabView {
            HomeView()
                .tabItem {
                    Label("الرئيسية", systemImage: "house.fill")
                }
            
            BookingsView()
                .tabItem {
                    Label("الحجوزات", systemImage: "calendar")
                }
            
            WalletView()
                .tabItem {
                    Label("المحفظة", systemImage: "creditcard.fill")
                }
            
            ProfileView()
                .tabItem {
                    Label("الحساب", systemImage: "person.crop.circle")
                }
        }
        .tint(Color.purple)
    }
}
