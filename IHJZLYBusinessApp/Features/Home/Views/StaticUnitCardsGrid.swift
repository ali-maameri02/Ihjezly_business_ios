// Features/Home/Views/StaticUnitCardsGrid.swift

import SwiftUI
// Features/Home/Views/StaticUnitCardsGrid.swift
struct StaticUnitCardsGrid: View {
    let category: PropertyCategory
    
    // All available property types
    private let allCards: [StaticUnitCardModel] = [
        // Accommodations
        StaticUnitCardModel(title: "غرفة فندق", image: "hotel_room", subType: .hotelRoom),
        StaticUnitCardModel(title: "شقة", image: "apartment", subType: .apartment),
        StaticUnitCardModel(title: "شاليه", image: "chalet", subType: .chalet),
        StaticUnitCardModel(title: "استراحة", image: "rest_house", subType: .restHouse),
        StaticUnitCardModel(title: "منتجع", image: "resort", subType: .resort),
        
        // Events
        StaticUnitCardModel(title: "قاعة صغيرة", image: "event_small", subType: .eventHallSmall),
        StaticUnitCardModel(title: "قاعة كبيرة", image: "event_large", subType: .eventHallLarge),
        StaticUnitCardModel(title: "غرفة اجتماعات", image: "meeting_room", subType: .meetingRoom),
        StaticUnitCardModel(title: "فيلا مناسبات", image: "villa_event", subType: .villaEvent)
    ]
    
    var filteredCards: [StaticUnitCardModel] {
        allCards.filter { $0.category == category }
    }
    
    var body: some View {
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
            ForEach(filteredCards) { card in
                StaticUnitCard(card: card)
            }
        }
    }
}
