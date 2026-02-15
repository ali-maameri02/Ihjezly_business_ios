//
//  UnavailableDatesViewModel.swift
//  IHJZLYBusinessApp
//
//  Created by Mohamed Ali Benouarzeg on 15/2/2026.
//

import Foundation
import Combine
// MARK: - ViewModel
@MainActor
final class UnavailableDatesViewModel: ObservableObject {
    @Published var form: HotelRoomForm
    @Published var selectedDates: [Date] = []
    @Published var showDatePicker = false
    @Published var tempDate = Date()
    
    init(form: HotelRoomForm) {
        self.form = form
        // Convert existing unavailable dates from form
        selectedDates = form.unavailableDates.compactMap { dateString in
            let formatter = ISO8601DateFormatter()
            return formatter.date(from: dateString)
        }
    }
    
    func addDate(_ date: Date) {
        guard !selectedDates.contains(where: { $0 == date }) else { return }
        selectedDates.append(date)
    }
    
    func removeDate(_ date: Date) {
        selectedDates.removeAll { $0 == date }
    }
    
    func saveDates() {
        let formatter = ISO8601DateFormatter()
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
