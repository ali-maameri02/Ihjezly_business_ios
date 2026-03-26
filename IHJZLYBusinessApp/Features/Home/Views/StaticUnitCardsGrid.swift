// Features/Home/Views/StaticUnitCardsGrid.swift

import SwiftUI
// Features/Home/Views/StaticUnitCardsGrid.swift
struct StaticUnitCardsGrid: View {
    let category: PropertyCategory
    
    // All available property types
    private let allCards: [StaticUnitCardModel] = [
        // Accommodations
        StaticUnitCardModel(title: "فنادق", image: "hotel", subType: .hotelRoom),
        StaticUnitCardModel(title: "شقق فندقية", image: "hotelapartments", subType: .hotelApartment),
        StaticUnitCardModel(title: "شاليهات", image: "chalet", subType: .chalet),
        StaticUnitCardModel(title: "استراحات", image: "miniqaat", subType: .restHouse),
        StaticUnitCardModel(title: "منتجعات", image: "resort", subType: .resort),
        StaticUnitCardModel(title: "شقق خاصة", image: "khassa", subType: .apartment),
        
        // Events
        StaticUnitCardModel(title: "قاعة صغيرة", image: "eventhalls", subType: .eventHallSmall),
        StaticUnitCardModel(title: "قاعة كبيرة", image: "eventhalls", subType: .eventHallLarge),
        StaticUnitCardModel(title: "غرفة اجتماعات", image: "meeting", subType: .meetingRoom),
        StaticUnitCardModel(title: "فيلا مناسبات", image: "events", subType: .villaEvent)
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
