// IHJZLYBusinessAppApp.swift

import SwiftUI

@main
struct IHJZLYBusinessAppApp: App {
    @StateObject private var appState = AppState()
    
    var body: some Scene {
        WindowGroup {
            if appState.isAuthenticated {
                MainTabView()
                    .environmentObject(appState)
            } else {
                AuthFlowView()
                    .environmentObject(appState)
            }
        }
    }
}
