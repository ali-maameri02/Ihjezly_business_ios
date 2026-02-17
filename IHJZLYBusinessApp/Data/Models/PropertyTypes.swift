

// MARK: - Sub-Types (for API endpoints)
enum PropertySubType: String, CaseIterable {
    // Accommodations
    case hotelRoom = "HotelRoom"
    case apartment = "Apartment"
    case chalet = "Chalet"
    case restHouse = "RestHouse"
    case resort = "Resort"
    
    // Events
    case eventHallSmall = "EventHallSmall"
    case eventHallLarge = "EventHallLarge"
    case meetingRoom = "MeetingRoom"
    case villaEvent = "VillaEvent"
}

// MARK: - Shared Form Protocol
protocol PropertyForm {
    var title: String { get set }
    var description: String { get set }
    var location: LocationForm { get set }
    var price: Double { get set }
    var discount: Double { get set }
    var videoUrl: String { get set }
    var facilities: [Facility] { get set }
    var images: [ImageUpload] { get set }
    var unavailableDates: [String] { get set }
}

//// MARK: - Specific Forms
//struct HotelRoomForm: PropertyForm {
//    var title: String = ""
//    var description: String = ""
//    var location: LocationForm = .init()
//    var price: Double = 0
//    var discount: Double = 0
//    var videoUrl: String = ""
//    var details: DetailsForm = .init()
//    var facilities: [Facility] = []
//    var images: [ImageUpload] = []
//    var unavailableDates: [String] = []
//}

struct ChaletForm: PropertyForm {
    var title: String = ""
    var description: String = ""
    var location: LocationForm = .init()
    var price: Double = 0
    var discount: Double = 0
    var videoUrl: String = ""
    var maxGuests: Int = 0
    var facilities: [Facility] = []
    var images: [ImageUpload] = []
    var unavailableDates: [String] = []
}

struct ApartmentForm: PropertyForm {
    var title: String = ""
    var description: String = ""
    var location: LocationForm = .init()
    var price: Double = 0
    var discount: Double = 0
    var videoUrl: String = ""
    var roomType: ApartmentType = .studio
    var facilities: [Facility] = []
    var images: [ImageUpload] = []
    var unavailableDates: [String] = []
}

//// MARK: - Room Types
//enum ApartmentType: String, Codable {
//    case studio = "Studio"
//    case oneBedroom = "OneBedroom"
//    case twoBedrooms = "TwoBedrooms"
//    case threeBedrooms = "ThreeBedrooms"
//    case villa = "Villa"
//}
