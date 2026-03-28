import Foundation
import Combine
import SwiftUI

// MARK: - Per-date availability entry (UI model only)
struct DateAvailabilityEntry: Identifiable {
    let id = UUID()
    let date: Date
    var morning: Bool = false
    var evening: Bool = false
}

@MainActor
final class EventHallStep4ViewModel<FormData: PropertyForm>: ObservableObject {
    @Published var form: FormData
    @Published var startDate: Date = Date()
    @Published var endDate: Date = Date()
    @Published var entries: [DateAvailabilityEntry] = []

    init(form: FormData) {
        self.form = form
        // Restore previously saved entries if any
        let saved = form.details.unavailablePeriods
        if !saved.isEmpty {
            // Rebuild entries from saved periods
            var dict: [String: DateAvailabilityEntry] = [:]
            let cal = Calendar.current
            for p in saved {
                let key = cal.startOfDay(for: p.date).description
                if dict[key] == nil {
                    dict[key] = DateAvailabilityEntry(date: cal.startOfDay(for: p.date))
                }
                if p.period == .morning { dict[key]!.morning = true }
                if p.period == .evening { dict[key]!.evening = true }
            }
            entries = dict.values.sorted { $0.date < $1.date }
        }
    }

    // Expand the selected date range into individual DateAvailabilityEntry rows
    func generateRange() {
        let cal = Calendar.current
        let start = cal.startOfDay(for: startDate)
        let end   = cal.startOfDay(for: endDate)
        guard start <= end else { return }

        var current = start
        var newEntries: [DateAvailabilityEntry] = []
        while current <= end {
            // Preserve existing toggles if the date was already added
            if let existing = entries.first(where: { cal.isDate($0.date, inSameDayAs: current) }) {
                newEntries.append(existing)
            } else {
                newEntries.append(DateAvailabilityEntry(date: current))
            }
            current = cal.date(byAdding: .day, value: 1, to: current)!
        }

        // Merge: keep entries outside the new range + the new range
        let outsideRange = entries.filter { e in
            !newEntries.contains { Calendar.current.isDate($0.date, inSameDayAs: e.date) }
        }
        entries = (outsideRange + newEntries).sorted { $0.date < $1.date }
    }

    func removeEntry(_ entry: DateAvailabilityEntry) {
        entries.removeAll { $0.id == entry.id }
    }

    func save() {
        // Convert entries → UnavailablePeriod list (for local state)
        var periods: [UnavailablePeriod] = []
        for entry in entries {
            if entry.morning { periods.append(UnavailablePeriod(date: entry.date, period: .morning)) }
            if entry.evening { periods.append(UnavailablePeriod(date: entry.date, period: .evening)) }
        }
        form.details.unavailablePeriods = periods

        // Serialize for API: each (date, period) → one ISO8601 datetime string
        // Backend expects List<DateTime> in Unavailables
        // Morning = 09:00, Evening = 20:00 — distinguishable by the backend if needed
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime]
        let cal = Calendar.current

        var dates: [String] = []
        for entry in entries {
            if entry.morning {
                if let dt = cal.date(bySettingHour: 9, minute: 0, second: 0, of: entry.date) {
                    dates.append(formatter.string(from: dt))
                }
            }
            if entry.evening {
                if let dt = cal.date(bySettingHour: 20, minute: 0, second: 0, of: entry.date) {
                    dates.append(formatter.string(from: dt))
                }
            }
        }
        form.unavailableDates = dates
    }

    func formattedDate(_ date: Date) -> String {
        let f = DateFormatter()
        f.dateStyle = .medium
        f.locale = Locale(identifier: "ar")
        return f.string(from: date)
    }
}
