// Data/Models/HotelRoomCreateRequest.swift

import Foundation

// ✅ 1. Define PropertyType
enum PropertyType: String, Codable {
    case residence = "Residence"
    case hall = "Hall"
}

// ✅ 2. Main request
struct HotelRoomCreateRequest: Codable {
    let title: String
    let description: String
    let location: LocationInput
    let price: Double
    let currency: String
    let type: PropertyType
    let details: Details
    let isAd: Bool
    let discount: Discount?
    let facilities: [Facility]
    let videoUrl: String?
    let unavailables: [String] // ISO8601 dates
    let businessOwnerId: String
    let images: [ImageUpload]
}

struct LocationInput: Codable {
    let city: String
    let state: String
    let country: String
    let latitude: Double
    let longitude: Double
}

struct Details: Codable {
    let numberOfAdults: Int
    let numberOfChildren: Int
    let hotelRoomType: HotelRoomType
    
    let classification: Classification // ✅ Fixed spelling
}

struct Discount: Codable {
    let value: Double
}

enum HotelRoomType: String, Codable {
    case singleRoom = "SingleRoom"
    case twinRoomOneBed = "TwinRoomOneBed"
    case twinRoomTwoBeds = "TwinRoomTwoBeds"
    case suite = "Suite"
    case tripleRoom = "TripleRoom"
    case quadrupleRoom = "QuadrupleRoom"
    case ministerialSuite = "MinisterialSuite"
    case presidentialSuite = "PresidentialSuite"
}

enum Classification: String, Codable {
    case none = "None"
    case oneStar = "OneStar"
    case twoStars = "TwoStars"
    case threeStars = "ThreeStars"
    case fourStars = "FourStars"
    case fiveStars = "FiveStars"
    case sixStars = "SixStars"
    case sevenStars = "SevenStars"
}


// Add these enums (after existing Facility enum)
enum Feature: String, Codable, CaseIterable {
    case cateringAndDiningServices = "CateringAndDiningServices"
    case decor = "Decor"
    case giantScreens = "GiantScreens"
    case server = "Server"
    case soundEffects = "SoundEffects"
    case fumigationAndPerfuming = "FumigationAndPerfuming"
}

extension Feature {
    var arabicName: String {
        switch self {
        case .cateringAndDiningServices: return "خدمات طعام وشراب"
        case .decor: return "ديكور"
        case .giantScreens: return "شاشات عملاقة"
        case .server: return "خادم"
        case .soundEffects: return "تأثيرات صوتية"
        case .fumigationAndPerfuming: return "تعقيم وعطرة"
        }
    }
}
enum Facility: String, Codable, CaseIterable { // ✅ Add CaseIterable
    case gardenView = "GardenView"
    case mountainView = "MountainView"
    case seaView = "SeaView"
    case elevator = "Elevator"
    case internet = "Internet"
    case breakfast = "Breakfast"
    case privateBeach = "PrivateBeach"
    case parking = "Parking"
    case securityOffice = "SecurityOffice"
    case propertyFacilities = "PropertyFacilities"
    case airConditioning = "AirConditioning"
    case heating = "Heating"
    case cookingUtensils = "CookingUtensils"
    case microwave = "Microwave"
    case washingMachine = "WashingMachine"
    case refrigerator = "Refrigerator"
    case dishwasher = "Dishwasher"
    case oven = "Oven"
    case screen = "Screen"
    case massageChair = "MassageChair"
    case kitchen = "Kitchen"
    case childrenToys = "ChildrenToys"
    case sauna = "Sauna"
    case playStation = "PlayStation"
    case accessiblePlaceforPeoplewithDisabilities = "AccessiblePlaceforPeoplewithDisabilities"
    case jacuzzi = "Jacuzzi"
    case airportPickup = "AirportPickup"
    case swimmingPool = "SwimmingPool"
    case barbecueCorner = "BarbecueCorner"
}
// In Data/Models/HotelRoomCreateRequest.swift
extension Facility {
    var arabicName: String {
        switch self {
        case .gardenView: return "إطلالة على الحديقة"
        case .mountainView: return "إطلالة على الجبل"
        case .seaView: return "إطلالة على البحر"
        case .elevator: return "مصعد"
        case .internet: return "واي فاي"
        case .breakfast: return "إفطار"
        case .privateBeach: return "شاطئ خاص"
        case .parking: return "مواقف"
        case .securityOffice: return "أمن"
        case .propertyFacilities: return "مرافق العقار"
        case .airConditioning: return "تكييف"
        case .heating: return "تدفئة"
        case .cookingUtensils: return "أدوات طبخ"
        case .microwave: return "مايكروويف"
        case .washingMachine: return "غسالة"
        case .refrigerator: return "ثلاجة"
        case .dishwasher: return "غسالة أطباق"
        case .oven: return "فرن"
        case .screen: return "شاشة"
        case .massageChair: return "كرسي مساج"
        case .kitchen: return "مطبخ"
        case .childrenToys: return "ألعاب أطفال"
        case .sauna: return "ساونا"
        case .playStation: return "بلاي ستيشن"
        case .accessiblePlaceforPeoplewithDisabilities: return "مكان مخصص لذوي الاحتياجات"
        case .jacuzzi: return "جاكوزي"
        case .airportPickup: return "استقبال من المطار"
        case .swimmingPool: return "مسبح"
        case .barbecueCorner: return "ركن شواء"
        }
    }
}


struct ImageUpload: Codable {
    let url: String   // full data URL or base64 string
    let isMain: Bool
}
