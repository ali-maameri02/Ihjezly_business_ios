// Domain/UseCases/CreateHotelRoomUseCase.swift

import Foundation

final class CreateHotelRoomUseCase {
    private let repo: HotelRoomRepository
    private let currentUser: User
    
    init(repo: HotelRoomRepository, currentUser: User) {
        self.repo = repo
        self.currentUser = currentUser
    }
    
    func execute(form: HotelRoomForm) async throws -> String {
        let request = HotelRoomCreateRequest(
            title: form.title,
            description: form.description,
            location: LocationInput(
                city: form.location.city,
                state: form.location.state,
                country: "Libya",
                latitude: form.location.latitude,
                longitude: form.location.longitude
            ),
            price: form.price,
            currency: "LYD",
            type: .residence,
            details: Details(
                numberOfAdults: form.details.numberOfAdults,
                numberOfChildren: form.details.numberOfChildren,
                hotelRoomType: form.details.hotelRoomType,
                classification: form.details.classification
            ),
            isAd: false,
            discount: form.discount > 0 ? Discount(value: form.discount) : nil,
            facilities: form.facilities,
            videoUrl: form.videoUrl.isEmpty ? nil : form.videoUrl,
            unavailables: [], // Add unavailable dates if needed
            businessOwnerId: currentUser.id,
            images: form.images
        )
        return try await repo.createHotelRoom(request)
    }
}
