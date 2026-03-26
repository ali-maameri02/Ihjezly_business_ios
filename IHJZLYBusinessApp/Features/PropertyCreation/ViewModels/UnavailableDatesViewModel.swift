import Foundation
import Combine
import SwiftUI

// MARK: - ViewModel
@MainActor
final class UnavailableDatesViewModel<FormData: PropertyForm>: ObservableObject {
    @Published var form: FormData
    @Published var selectedDates: [Date] = []
    @Published var showDatePicker = false
    @Published var tempDate = Date()

    init(form: FormData) {
        self.form = form
        let formatter = ISO8601DateFormatter()
        selectedDates = form.unavailableDates.compactMap { formatter.date(from: $0) }
    }

    func addDate(_ date: Date) {
        guard !selectedDates.contains(where: { Calendar.current.isDate($0, inSameDayAs: date) }) else { return }
        selectedDates.append(date)
    }

    func removeDate(_ date: Date) {
        selectedDates.removeAll { Calendar.current.isDate($0, inSameDayAs: date) }
    }

    func saveDates() {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withFullDate]
        form.unavailableDates = selectedDates.map { formatter.string(from: $0) }
    }
}

// MARK: - DatePicker View
struct DatePickerView: View {
    @Binding var selectedDate: Date
    let onConfirm: () -> Void

    var body: some View {
        NavigationStack {
            VStack {
                DatePicker("اختر التاريخ", selection: $selectedDate, displayedComponents: [.date])
                    .datePickerStyle(GraphicalDatePickerStyle())
                    .padding()

                Button("تأكيد") {
                    onConfirm()
                }
                .font(.headline)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color(hex: "#88417A"))
                .cornerRadius(12)
                .padding()
            }
            .navigationTitle("اختيار التاريخ")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}
