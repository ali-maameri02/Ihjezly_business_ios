// Domain/Models/HotelRoomForm.swift
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
    var images: [ImageUpload] = [] // Keep as ImageUpload
    var unavailableDates: [String] = []
}

struct LocationForm {
    var state: String = ""
    var city: String = ""
    var latitude: Double = 0
    var longitude: Double = 0
}

struct DetailsForm {
    var numberOfAdults: Int = 0
    var numberOfChildren: Int = 0
    var hotelRoomType: HotelRoomType = .singleRoom
    var classification: Classification = .none
}


