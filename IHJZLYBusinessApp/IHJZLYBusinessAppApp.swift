// IHJZLYBusinessAppApp.swift

import SwiftUI

@main
struct IHJZLYBusinessAppApp: App {
    @StateObject private var appState = AppState()

    var body: some Scene {
        WindowGroup {
            Group {
                if appState.isValidatingToken {
                    // Brief splash while we validate the stored token
                    splashView
                } else if appState.isAuthenticated {
                    MainTabView()
                        .environmentObject(appState)
                } else {
                    AuthFlowView()
                        .environmentObject(appState)
                }
            }
            .animation(.easeInOut(duration: 0.25), value: appState.isValidatingToken)
            .animation(.easeInOut(duration: 0.25), value: appState.isAuthenticated)
        }
    }

    private var splashView: some View {
        ZStack {
            Color(.systemBackground).ignoresSafeArea()
            VStack(spacing: 16) {
                Image("ihjzlyapplogo")
                    .resizable()
                    .frame(width: 80, height: 80)
                    .clipShape(RoundedRectangle(cornerRadius: 18))
                ProgressView()
                    .tint(.brand)
            }
        }
    }
}
