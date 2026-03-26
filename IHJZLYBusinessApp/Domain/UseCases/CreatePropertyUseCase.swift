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
                numberOfAdults: form.details.numberOfAdults,
                numberOfChildren: form.details.numberOfChildren
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
                numberOfAdults: form.details.numberOfAdults,
                numberOfChildren: form.details.numberOfChildren,
                apartmentType: apartmentType
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
                numberOfAdults: form.details.numberOfAdults,
                numberOfChildren: form.details.numberOfChildren,
                type: .studio,
                clasification: form.details.classification
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
        case .twinRoomOneBed, .twinRoomTwoBeds: return .twoBedroom
        default: return .threeBedroom
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
    let numberOfAdults: Int
    let numberOfChildren: Int
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
    let numberOfAdults: Int
    let numberOfChildren: Int
    let apartmentType: ApartmentType
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
    let numberOfAdults: Int
    let numberOfChildren: Int
    let type: ResortsType
    let clasification: Classification
}

enum ResortsType: String, Codable {
    case studio = "studio"
    case twoBedroom = "TwoBedroom"
    case threeBedroom = "ThreeBedroom"
}

enum ApartmentType: String, Codable {
    case studio = "studio"
    case twoBedroom = "TwoBedroom"
    case threeBedroom = "ThreeBedroom"
}
