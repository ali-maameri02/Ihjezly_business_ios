// Features/Home/Views/StaticUnitCard.swift
import SwiftUI

struct StaticUnitCard: View {
    let card: StaticUnitCardModel

    var body: some View {
        NavigationLink {
            PropertyCreationNavigator(propertySubType: card.subType)
        } label: {
            VStack(spacing: 0) {
                Image(card.image)
                    .resizable()
                    .aspectRatio(1.4, contentMode: .fill)
                    .clipped()
                    .cornerRadius(10, corners: [.topLeft, .topRight])

                Text(card.title)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .lineLimit(2)
                    .multilineTextAlignment(.center)
                    .foregroundColor(.primary)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 10)
                    .frame(maxWidth: .infinity)
                    .background(Color.cardBackground)
                    .cornerRadius(10, corners: [.bottomLeft, .bottomRight])
            }
            .background(Color.cardBackground)
            .cornerRadius(10)
            .shadow(color: .black.opacity(0.07), radius: 5, x: 0, y: 2)
        }
        .buttonStyle(.plain)
    }
}

struct PropertyCreationNavigator: View {
    let propertySubType: PropertySubType
    @State private var currentUser: User?
    @State private var isLoading = true

    var body: some View {
        ZStack {
            if isLoading {
                ProgressView("جارٍ التحميل...")
            } else if let user = currentUser {
                creationFlowView(user: user)
            } else {
                errorView
            }
        }
        .onAppear { loadCurrentUser() }
    }

    @ViewBuilder
    private func creationFlowView(user: User) -> some View {
        let client = APIClient(baseURLString: "http://31.220.56.155:5050")
        let token = UserDefaults.standard.string(forKey: "auth_token") ?? ""
        let _ = client.defaultHeaders["Authorization"] = "Bearer \(token)"
        let locationUseCase = LocationUseCase(apiClient: client, token: token)
        let createUseCase = CreatePropertyUseCase(apiClient: client, currentUser: user)

        PropertyCreationFlow(
            propertySubType: propertySubType,
            locationUseCase: locationUseCase,
            createUseCase: createUseCase,
            currentUser: user
        )
    }

    private var errorView: some View {
        VStack(spacing: 16) {
            Image(systemName: "exclamationmark.triangle")
                .font(.largeTitle).foregroundColor(.red)
            Text("يرجى تسجيل الدخول أولاً").font(.headline)
        }
    }

    private func loadCurrentUser() {
        guard let token = UserDefaults.standard.string(forKey: "auth_token") else {
            isLoading = false; return
        }
        Task {
            do {
                let client = APIClient(baseURLString: "http://31.220.56.155:5050")
                client.defaultHeaders["Authorization"] = "Bearer \(token)"
                let user = try await AuthRepository(apiClient: client).fetchCurrentUser()
                await MainActor.run { currentUser = user; isLoading = false }
            } catch {
                await MainActor.run { isLoading = false }
            }
        }
    }
}
