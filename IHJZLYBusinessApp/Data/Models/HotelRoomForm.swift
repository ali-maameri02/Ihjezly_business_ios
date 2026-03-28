// Data/Models/HotelRoomForm.swift
import Foundation

struct HotelRoomForm: PropertyForm {
    var title: String = ""
    var description: String = ""
    var location: LocationForm = .init()
    var price: Double = 0
    var discount: Double = 0
    var videoUrl: String = ""
    var details: DetailsForm = .init()
    var facilities: [Facility] = []
    var images: [ImageUpload] = []
    var unavailableDates: [String] = []
    var features: [Feature] = []
}

struct LocationForm {
    var state: String = ""
    var city: String = ""
    var latitude: Double = 0
    var longitude: Double = 0
}

// Single DetailsForm covering all property types
struct DetailsForm {
    // Shared
    var numberOfAdults: Int = 1
    var numberOfChildren: Int = 0
    var maxGuests: Int = 0
    var classification: Classification = .none

    // HotelRoom
    var hotelRoomType: HotelRoomType = .singleRoom

    // HotelApartment
    var hotelApartmentType: HotelApartmentType? = nil

    // Apartment
    var apartmentType: ApartmentType? = nil

    // Resort
    var resortType: ResortsType? = nil

    // EventHall unavailable periods
    var unavailablePeriods: [UnavailablePeriod] = []
}

struct UnavailablePeriod: Identifiable, Equatable {
    let id = UUID()
    var date: Date
    var period: DayPeriod
}

enum DayPeriod: String, CaseIterable {
    case morning = "Morning"
    case evening = "Evening"
    var arabicName: String { self == .morning ? "صباح" : "مساء" }
}
