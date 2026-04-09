// Features/Authentication/Views/AuthFlowView.swift

import SwiftUI

/// Root authentication view.
/// Wraps everything in a NavigationStack so SignUpView → OTPVerificationView → CompleteProfileView
/// all work with .navigationDestination.
struct AuthFlowView: View {

    @EnvironmentObject var appState: AppState
    @State private var showSignUp = false

    var body: some View {
        NavigationStack {
            LoginView(
                appState: appState,
                onSignUpTapped: { showSignUp = true }
            )
            .navigationDestination(isPresented: $showSignUp) {
                SignUpView()
            }
        }
    }
}
