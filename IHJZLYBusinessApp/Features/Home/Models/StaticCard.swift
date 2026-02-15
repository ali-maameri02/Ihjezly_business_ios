// Features/Home/Models/StaticCard.swift

import Foundation

struct StaticCard: Identifiable {
    let id = UUID()
    let imageName: String
    let title: String
    let route: Subtype
}

enum Subtype: String, CaseIterable {
    // Residences
    case apartment = "Apartment"
    case chalet = "Chalet"
    case hotelRoom = "HotelRoom"
    case hotelApartment = "HotelApartment"
    case resort = "Resort"
    case restHouse = "RestHouse"
    
    // Halls
    case eventHallSmall = "EventHallSmall"
    case eventHallLarge = "EventHallLarge"
    case meetingRoom = "MeetingRoom"
    case villaEvent = "villaEvent"
}
