// Domain/UseCases/CreatePropertyUseCase.swift
import Foundation

protocol CreatePropertyUseCaseProtocol {
    func execute(form: HotelRoomForm, propertyType: PropertySubType) async throws -> String
}

final class CreatePropertyUseCase: CreatePropertyUseCaseProtocol {
    private let apiClient: APIClient
    private let currentUser: User
    
    init(apiClient: APIClient, currentUser: User) {
        self.apiClient = apiClient
        self.currentUser = currentUser
    }
    
    func execute(form: HotelRoomForm, propertyType: PropertySubType) async throws -> String {
        switch propertyType {
        case .hotelRoom:
            return try await createHotelRoom(form: form)
        case .chalet, .restHouse:
            return try await createChalet(form: form)
        case .apartment:
            return try await createApartment(form: form)
        case .resort:
            return try await createResort(form: form)
        default:
            throw APIError.badRequest("نوع العقار غير مدعوم")
        }
    }
    
    // MARK: - Hotel Room
    private func createHotelRoom(form: HotelRoomForm) async throws -> String {
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
            videoUrl: nil,
            unavailables: form.unavailableDates,
            businessOwnerId: currentUser.id,
            images: form.images
        )
        return try await apiClient.post(to: "/api/v1/HotelRoom", body: request)
    }
    
    // MARK: - Chalet/RestHouse
    private func createChalet(form: HotelRoomForm) async throws -> String {
        // Map HotelRoomForm to Chalet structure
        let chaletRequest = ChaletCreateRequest(
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
            details: ChaletDetails(
                maxGuests: form.details.numberOfAdults, // Reuse numberOfAdults for maxGuests
                classification: form.details.classification
            ),
            isAd: false,
            discount: form.discount > 0 ? Discount(value: form.discount) : nil,
            facilities: form.facilities,
            videoUrl: nil,
            unavailables: form.unavailableDates,
            businessOwnerId: currentUser.id,
            images: form.images
        )
        return try await apiClient.post(to: "/api/v1/Chalet", body: chaletRequest)
    }
    
    // MARK: - Apartment
    private func createApartment(form: HotelRoomForm) async throws -> String {
        // Map HotelRoomType to ApartmentType
        let apartmentType = mapHotelRoomToApartment(form.details.hotelRoomType)
        let apartmentRequest = ApartmentCreateRequest(
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
            details: ApartmentDetails(
                roomType: apartmentType,
                classification: form.details.classification
            ),
            isAd: false,
            discount: form.discount > 0 ? Discount(value: form.discount) : nil,
            facilities: form.facilities,
            videoUrl: nil,
            unavailables: form.unavailableDates,
            businessOwnerId: currentUser.id,
            images: form.images
        )
        return try await apiClient.post(to: "/api/v1/Apartment", body: apartmentRequest)
    }
    
    // MARK: - Resort
    private func createResort(form: HotelRoomForm) async throws -> String {
        // Similar to HotelRoom but with different endpoint
        let resortRequest = ResortCreateRequest(
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
            details: ResortDetails(
                roomType: form.details.hotelRoomType,
                classification: form.details.classification
            ),
            isAd: false,
            discount: form.discount > 0 ? Discount(value: form.discount) : nil,
            facilities: form.facilities,
            videoUrl: nil,
            unavailables: form.unavailableDates,
            businessOwnerId: currentUser.id,
            images: form.images
        )
        return try await apiClient.post(to: "/api/v1/Resort", body: resortRequest)
    }
    
    // MARK: - Helpers
    private func mapHotelRoomToApartment(_ hotelType: HotelRoomType) -> ApartmentType {
        switch hotelType {
        case .singleRoom: return .studio
        case .twinRoomOneBed: return .oneBedroom
        case .twinRoomTwoBeds: return .twoBedrooms
        case .tripleRoom: return .threeBedrooms
        case .suite, .ministerialSuite, .presidentialSuite: return .villa
        default: return .studio
        }
    }
}

// MARK: - Request Models
struct ChaletCreateRequest: Codable {
    let title: String
    let description: String
    let location: LocationInput
    let price: Double
    let currency: String
    let type: PropertyType
    let details: ChaletDetails
    let isAd: Bool
    let discount: Discount?
    let facilities: [Facility]
    let videoUrl: String?
    let unavailables: [String]
    let businessOwnerId: String
    let images: [ImageUpload]
}

struct ChaletDetails: Codable {
    let maxGuests: Int
    let classification: Classification
}

struct ApartmentCreateRequest: Codable {
    let title: String
    let description: String
    let location: LocationInput
    let price: Double
    let currency: String
    let type: PropertyType
    let details: ApartmentDetails
    let isAd: Bool
    let discount: Discount?
    let facilities: [Facility]
    let videoUrl: String?
    let unavailables: [String]
    let businessOwnerId: String
    let images: [ImageUpload]
}

struct ApartmentDetails: Codable {
    let roomType: ApartmentType
    let classification: Classification
}

struct ResortCreateRequest: Codable {
    let title: String
    let description: String
    let location: LocationInput
    let price: Double
    let currency: String
    let type: PropertyType
    let details: ResortDetails
    let isAd: Bool
    let discount: Discount?
    let facilities: [Facility]
    let videoUrl: String?
    let unavailables: [String]
    let businessOwnerId: String
    let images: [ImageUpload]
}

struct ResortDetails: Codable {
    let roomType: HotelRoomType
    let classification: Classification
}

enum ApartmentType: String, Codable {
    case studio = "Studio"
    case oneBedroom = "OneBedroom"
    case twoBedrooms = "TwoBedrooms"
    case threeBedrooms = "ThreeBedrooms"
    case villa = "Villa"
}
