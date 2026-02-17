// Features/Home/Views/StaticUnitCard.swift
import SwiftUI

struct StaticUnitCard: View {
    let card: StaticUnitCardModel
    
    var body: some View {
        NavigationLink {
            PropertyCreationNavigator(propertySubType: card.subType)
        } label: {
            VStack(spacing: 8) {
                Image(card.image)
                    .resizable()
                    .aspectRatio(1.5, contentMode: .fill)
                    .clipped()
                    .cornerRadius(8)
                Text(card.title)
                    .font(.headline)
                    .fontWeight(.medium)
                    .lineLimit(2)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 8)
                    .foregroundStyle(Color.black)
            }
            .frame(maxWidth: .infinity)
            .background(Color.white)
            .cornerRadius(12)
            .shadow(radius: 3)
            .padding(.horizontal, 4)
        }
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
        .onAppear {
            loadCurrentUser()
        }
    }
    
    @ViewBuilder
    private func creationFlowView(user: User) -> some View {
        let client = APIClient(baseURLString: "http://31.220.56.155:5050")
        let token = UserDefaults.standard.string(forKey: "auth_token") ?? ""
        let _ = client.defaultHeaders["Authorization"] = "Bearer \(token)"
        
        let locationUseCase = LocationUseCase(apiClient: client, token: token)
        let repo = HotelRoomRepository(apiClient: client)
        let createUseCase = CreateHotelRoomUseCase(repo: repo, currentUser: user)
        
        HotelRoomCreationFlow(
            viewModel: HotelRoomStep1ViewModel(locationManager: locationUseCase, currentUser: user),
            locationUseCase: locationUseCase,
            createHotelRoomUseCase: createUseCase
        )
    }
    
    private var errorView: some View {
        VStack(spacing: 16) {
            Image(systemName: "exclamationmark.triangle")
                .font(.largeTitle)
                .foregroundColor(.red)
            Text("يرجى تسجيل الدخول أولاً")
                .font(.headline)
        }
    }
    
    private func loadCurrentUser() {
        guard let token = UserDefaults.standard.string(forKey: "auth_token") else {
            isLoading = false
            return
        }
        
        Task {
            do {
                let client = APIClient(baseURLString: "http://31.220.56.155:5050")
                client.defaultHeaders["Authorization"] = "Bearer \(token)"
                let authRepo = AuthRepository(apiClient: client)
                let user = try await authRepo.fetchCurrentUser()
                
                await MainActor.run {
                    self.currentUser = user
                    self.isLoading = false
                }
            } catch {
                await MainActor.run {
                    self.isLoading = false
                }
            }
        }
    }
}
