// Data/Models/PropertyTypes.swift

// MARK: - Sub-Types
enum PropertySubType: String, CaseIterable {
    case hotelRoom      = "HotelRoom"
    case hotelApartment = "HotelApartment"
    case apartment      = "Apartment"
    case chalet         = "Chalet"
    case restHouse      = "RestHouse"
    case resort         = "Resort"
    case eventHallSmall = "EventHallSmall"
    case eventHallLarge = "EventHallLarge"
    case meetingRoom    = "MeetingRoom"
    case villaEvent     = "VillaEvent"

    // Step 3 shows type-selection options (studio / 2BR / 3BR etc.)
    var showsSelectOptions: Bool {
        switch self {
        case .apartment, .chalet, .restHouse: return false
        default: return hasStep3
        }
    }

    // Step 3 shows adults + children counters
    var usesGuestCounters: Bool {
        switch self {
        case .chalet, .restHouse, .apartment: return true
        default: return false
        }
    }

    // Step 3 is present when the type has any step-3 content
    var hasStep3: Bool {
        switch self {
        case .hotelRoom, .hotelApartment, .apartment, .chalet, .restHouse, .resort: return true
        default: return false
        }
    }

    var hasUnavailableDatesStep: Bool {
        switch self {
        case .chalet, .restHouse, .apartment: return true
        default: return false
        }
    }

    // Step 4 (classification) only for these types
    var hasClassification: Bool {
        switch self {
        case .hotelRoom, .resort: return true
        default: return false
        }
    }

    var apiEndpoint: String {
        switch self {
        case .hotelRoom:      return "/api/v1/HotelRoom"
        case .hotelApartment: return "/api/v1/HotelApartment"
        case .apartment:      return "/api/v1/Apartment"
        case .chalet:         return "/api/v1/Chalet"
        case .restHouse:      return "/api/v1/RestHouse"
        case .resort:         return "/api/v1/Resort"
        case .eventHallSmall: return "/api/v1/EventHallSmall"
        case .eventHallLarge: return "/api/v1/EventHallLarge"
        case .meetingRoom:    return "/api/v1/MeetingRoom"
        case .villaEvent:     return "/api/v1/VillaEvent"
        }
    }

    var isEventHall: Bool {
        switch self {
        case .eventHallSmall, .eventHallLarge, .meetingRoom, .villaEvent: return true
        default: return false
        }
    }

    // Ordered list of steps for this sub-type
    enum CreationStep {
        case step1, step2, step3, step4Classification,
             step3EventHallGuests, step4EventHallDates,
             step5Images, step6Facilities, step7UnavailableDates, step8Price
    }

    var creationSteps: [CreationStep] {
        if isEventHall {
            return [.step1, .step2, .step3EventHallGuests, .step4EventHallDates, .step5Images, .step8Price]
        }
        var steps: [CreationStep] = [.step1, .step2]
        if hasStep3 { steps.append(.step3) }
        if hasClassification { steps.append(.step4Classification) }
        steps.append(.step5Images)
        steps.append(.step6Facilities)
        if hasUnavailableDatesStep { steps.append(.step7UnavailableDates) }
        steps.append(.step8Price)
        return steps
    }

    var step3Title: String {
        switch self {
        case .hotelRoom:      return "نوع الغرفة"
        case .hotelApartment: return "نوع الشقة الفندقية"
        case .apartment:      return "عدد الضيوف"
        case .resort:         return "نوع الوحدة"
        case .chalet:         return "عدد الضيوف"
        case .restHouse:      return "عدد الضيوف"
        case .eventHallSmall, .eventHallLarge, .meetingRoom, .villaEvent: return "الضيوف والمميزات"
        default:              return "تفاصيل العقار"
        }
    }
}

// MARK: - PropertyForm Protocol
protocol PropertyForm {
    var title: String { get set }
    var description: String { get set }
    var location: LocationForm { get set }
    var price: Double { get set }
    var discount: Double { get set }
    var videoUrl: String { get set }
    var details: DetailsForm { get set }
    var facilities: [Facility] { get set }
    var images: [ImageUpload] { get set }
    var unavailableDates: [String] { get set }
    var features: [Feature] { get set }
}
