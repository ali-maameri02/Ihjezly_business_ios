extension Feature {
    var iconName: String {
        switch self {
        case .cateringAndDiningServices: return "cup.and.saucer.fill"
        case .decor: return "paintbrush.fill"
        case .giantScreens: return "tv.fill"
        case .server: return "server.rack" // ✅ This one DOES exist (no ".fill")
        case .soundEffects: return "speaker.wave.3.fill"
        case .fumigationAndPerfuming: return "aqi.medium" // Closest to "spray/clean"
        }
    }
}
