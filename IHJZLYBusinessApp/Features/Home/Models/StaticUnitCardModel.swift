// Features/Home/Models/StaticUnitCardModel.swift

import Foundation

struct StaticUnitCardModel: Identifiable {
    let id = UUID()
    let title: String
    let image: String
    let subType: PropertySubType // ✅ Use sub-type for creation flow
    
    // Computed property for HomeView category
    var category: PropertyCategory {
        switch subType {
        case .hotelRoom, .hotelApartment, .apartment, .chalet, .restHouse, .resort:
            return .accommodations
        case .eventHallSmall, .eventHallLarge, .meetingRoom, .villaEvent:
            return .events
        }
    }
}
