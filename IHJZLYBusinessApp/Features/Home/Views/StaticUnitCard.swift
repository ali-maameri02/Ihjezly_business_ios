// Features/Home/Views/StaticUnitCard.swift
import SwiftUI
// Features/Home/Views/StaticUnitCard.swift
struct StaticUnitCard: View {
    let card: StaticUnitCardModel
    @State private var isLoading = false
    @State private var error: String?
    @State private var currentUser: User?
    
    private var destinationView: some View {
        guard let currentUser = currentUser else {
            return AnyView(Text("جارٍ التحميل..."))
        }
        
        let client = APIClient(baseURLString: "http://31.220.56.155:5050")
        client.defaultHeaders["Authorization"] = "Bearer \(UserDefaults.standard.string(forKey: "auth_token") ?? "")"
        
        let locationUseCase = LocationUseCase(apiClient: client, token: UserDefaults.standard.string(forKey: "auth_token") ?? "")
        let repo = HotelRoomRepository(apiClient: client) // Reuse existing repo
        let createUseCase = CreateHotelRoomUseCase(repo: repo, currentUser: currentUser)
        
        // Create empty form based on sub-type
        let form = HotelRoomForm(
            title: "",
            description: "",
            location: .init(),
            price: 0,
            discount: 0,
            videoUrl: "",
            details: DetailsForm(
                numberOfAdults: 0,
                numberOfChildren: 0,
                hotelRoomType: .singleRoom, // Default
                classification: .none
            ),
            facilities: [],
            images: []
        )
        
        return AnyView(
            HotelRoomCreationFlow(
                viewModel: HotelRoomStep1ViewModel(locationManager: locationUseCase, currentUser: currentUser),
                locationUseCase: locationUseCase,
                createHotelRoomUseCase: createUseCase
            )
        )
    }
    
    var body: some View {
        NavigationLink(destination: destinationView) {
            // Your existing card UI
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
    
    private func loadCurrentUser() {
        guard !isLoading else { return }
        guard let token = UserDefaults.standard.string(forKey: "auth_token") else {
            DispatchQueue.main.async {
                self.error = "يرجى تسجيل الدخول أولاً"
            }
            return
        }
        
        isLoading = true
        error = nil
        
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
                    self.error = "فشل تحميل بيانات المستخدم"
                    self.isLoading = false
                }
                print("❌ Failed to fetch current user: \(error)")
            }
        }
    }
}


    

    
  
