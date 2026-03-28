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
        var fields: [String: Any] = [
            "Title":          form.title,
            "Description":    form.description,
            "Price":          "\(form.price)",
            "Currency":       "LYD",
            "Type":           propertyType.isEventHall ? "Hall" : "Residence",
            "IsAd":           "false",
            "Location.City":    form.location.city,
            "Location.State":   form.location.state,
            "Location.Country": "Libya",
            "Location.Latitude":  "\(form.location.latitude)",
            "Location.Longitude": "\(form.location.longitude)",
        ]

        if form.discount > 0 {
            fields["Discount.Value"] = "\(form.discount)"
        }

        if !form.videoUrl.isEmpty {
            fields["ViedeoUrl.Url"] = form.videoUrl
        }

        for (i, date) in form.unavailableDates.enumerated() {
            fields["Unavailables[\(i)]"] = date
        }

        for (i, facility) in form.facilities.enumerated() {
            fields["Facilities[\(i)]"] = facility.rawValue
        }

        switch propertyType {
        case .hotelRoom:
            fields["Details.NumberOfAdults"]   = "\(form.details.numberOfAdults)"
            fields["Details.NumberOfChildren"] = "\(form.details.numberOfChildren)"
            fields["Details.hotelRoomType"]    = form.details.hotelRoomType.rawValue
            fields["Details.clasification"]    = form.details.classification.rawValue

        case .hotelApartment:
            fields["Details.NumberOfAdults"]     = "\(form.details.numberOfAdults)"
            fields["Details.NumberOfChildren"]   = "\(form.details.numberOfChildren)"
            fields["Details.hotalApartmentType"] = (form.details.hotelApartmentType ?? .studio).rawValue

        case .apartment:
            fields["Details.NumberOfAdults"]   = "\(form.details.numberOfAdults)"
            fields["Details.NumberOfChildren"] = "\(form.details.numberOfChildren)"
            fields["Details.apartmentType"]    = (form.details.apartmentType ?? .studio).rawValue

        case .chalet, .restHouse:
            fields["Details.NumberOfAdults"]   = "\(form.details.numberOfAdults)"
            fields["Details.NumberOfChildren"] = "\(form.details.numberOfChildren)"

        case .resort:
            fields["Details.NumberOfAdults"]   = "\(form.details.numberOfAdults)"
            fields["Details.NumberOfChildren"] = "\(form.details.numberOfChildren)"
            fields["Details.type"]             = (form.details.resortType ?? .studio).rawValue
            fields["Details.clasification"]    = form.details.classification.rawValue

        case .eventHallSmall, .eventHallLarge, .meetingRoom, .villaEvent:
            fields["Type"] = "Hall"
            fields["Details.NumberOfGuests"] = "\(form.details.maxGuests)"
            for (i, feature) in form.features.enumerated() {
                fields["Details.Features[\(i)]"] = feature.rawValue
            }

        default:
            throw APIError.badRequest("نوع العقار غير مدعوم: \(propertyType.rawValue)")
        }

        // Images as raw binary multipart files
        let imageDataList = form.images.compactMap { img -> Data? in
            if let range = img.url.range(of: ",") {
                return Data(base64Encoded: String(img.url[range.upperBound...]))
            }
            return Data(base64Encoded: img.url)
        }
        if !imageDataList.isEmpty {
            fields["images"] = imageDataList
        }

        print("📤 Submitting \(propertyType.rawValue) with fields: \(fields.keys.sorted())")

        let (data, response) = try await apiClient.postMultipartRaw(
            to: propertyType.apiEndpoint,
            formData: fields
        )

        guard let http = response as? HTTPURLResponse else { throw APIError.invalidResponse }

        if !(200...299).contains(http.statusCode) {
            let msg = String(data: data, encoding: .utf8) ?? "Unknown error"
            print("❌ API error (\(http.statusCode)): \(msg)")
            throw APIError.badRequest(msg)
        }

        // Backend returns the created property UUID
        if let id = try? JSONDecoder().decode(String.self, from: data) { return id }
        if let id = (try? JSONDecoder().decode([String: String].self, from: data))?["id"] { return id }
        return String(data: data, encoding: .utf8) ?? ""
    }
}

// MARK: - Request Models

struct HotelApartmentCreateRequest: Codable {
    let title: String; let description: String; let location: LocationInput
    let price: Double; let currency: String; let type: PropertyType
    let details: HotelApartmentDetails
    let isAd: Bool; let discount: Discount?; let facilities: [Facility]
    let videoUrl: String?; let unavailables: [String]
    let businessOwnerId: String; let images: [ImageUpload]
}

struct HotelApartmentDetails: Codable {
    let numberOfAdults: Int; let numberOfChildren: Int
    let hotalApartmentType: HotelApartmentType
}

struct ChaletCreateRequest: Codable {
    let title: String; let description: String; let location: LocationInput
    let price: Double; let currency: String; let type: PropertyType
    let details: ChaletDetails
    let isAd: Bool; let discount: Discount?; let facilities: [Facility]
    let videoUrl: String?; let unavailables: [String]
    let businessOwnerId: String; let images: [ImageUpload]
}

struct ChaletDetails: Codable {
    let numberOfAdults: Int; let numberOfChildren: Int
}

struct ApartmentCreateRequest: Codable {
    let title: String; let description: String; let location: LocationInput
    let price: Double; let currency: String; let type: PropertyType
    let details: ApartmentDetails
    let isAd: Bool; let discount: Discount?; let facilities: [Facility]
    let videoUrl: String?; let unavailables: [String]
    let businessOwnerId: String; let images: [ImageUpload]
}

struct ApartmentDetails: Codable {
    let numberOfAdults: Int; let numberOfChildren: Int
    let apartmentType: ApartmentType
}

struct ResortCreateRequest: Codable {
    let title: String; let description: String; let location: LocationInput
    let price: Double; let currency: String; let type: PropertyType
    let details: ResortDetails
    let isAd: Bool; let discount: Discount?; let facilities: [Facility]
    let videoUrl: String?; let unavailables: [String]
    let businessOwnerId: String; let images: [ImageUpload]
}

struct ResortDetails: Codable {
    let numberOfAdults: Int; let numberOfChildren: Int
    let type: ResortsType; let clasification: Classification
}

// MARK: - Type Enums

enum HotelApartmentType: String, Codable {
    case studio = "studio"
    case twoBedroom = "TwoBedroom"
    case threeBedroom = "ThreeBedroom"
}

enum ApartmentType: String, Codable {
    case studio = "studio"
    case twoBedroom = "TwoBedroom"
    case threeBedroom = "ThreeBedroom"
}

enum ResortsType: String, Codable {
    case studio = "studio"
    case twoBedroom = "TwoBedroom"
    case threeBedroom = "ThreeBedroom"
}
