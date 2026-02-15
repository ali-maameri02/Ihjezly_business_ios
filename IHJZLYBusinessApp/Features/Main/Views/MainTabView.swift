// Features/Main/Views/MainTabView.swift

import SwiftUI

struct MainTabView: View {
    var body: some View {
        TabView {
            HomeView()
                .tabItem {
                    Label("الرئيسية", systemImage: "house.fill")
                }
            
            Text("الحجوزات")
                .tabItem {
                    Label("الحجوزات", systemImage: "calendar")
                }
            
            Text("المحفظة")
                .tabItem {
                    Label("المحفظة", systemImage: "creditcard.fill")
                }
            
            Text("الحساب")
                .tabItem {
                    Label("الحساب", systemImage: "person.crop.circle")
                }
        }
        .tint(Color.purple)
    }
}
