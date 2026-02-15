extension Facility {
    var iconName: String {
        switch self {
        case .gardenView: return "leaf.fill"
        case .mountainView: return "mountain.2.fill"
        case .seaView: return "water.waves"
        case .elevator: return "evelvator"
        case .internet: return "wifi"
        case .breakfast: return "cup.and.saucer.fill"
        case .privateBeach: return "beach.umbrella.fill"
        case .parking: return "car.fill"
        case .securityOffice: return "shield.checkered"
        case .propertyFacilities: return "building.2.fill"
        case .airConditioning: return "snowflake"
        case .heating: return "thermometer.sun.fill"
        case .cookingUtensils: return "fork.knife"
        case .microwave: return "washer" // Visuellement plus proche d'un micro-ondes que oven
        case .washingMachine: return "washer.fill"
        case .refrigerator: return "refrigerator.fill"
        case .dishwasher: return "dishwasher.fill"
        case .oven: return "oven.fill"
        case .screen: return "tv.fill"
        case .massageChair: return "chair.lounge.fill"
        case .kitchen: return "kitchen"
        case .childrenToys: return "teddybear.fill" // Plus évocateur pour les enfants
        case .sauna: return "sauna"
        case .playStation: return "gamecontroller.fill"
        case .accessiblePlaceforPeoplewithDisabilities: return "figure.roll" // Icône standard accessibilité
        case .jacuzzi: return "bathtub.fill"
        case .airportPickup: return "airplane.arrival"
        case .swimmingPool: return "figure.pool.swim"
        case .barbecueCorner: return "stove.fill"
        }
    }
}

