// Features/Authentication/Views/AuthFlowView.swift

import SwiftUI

struct AuthFlowView: View {
    @EnvironmentObject var appState: AppState
    
    var body: some View {
        LoginView(
            appState: appState,
            onSignUpTapped: {
                // TODO: Navigate to sign-up screen
                print("Navigate to Sign Up")
            }
        )
    }
}
