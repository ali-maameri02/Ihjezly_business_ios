// Features/HotelRoom/ViewModels/HotelRoomStep4ViewModel.swift

import Foundation
import Combine

@MainActor
final class HotelRoomStep4ViewModel: ObservableObject {
    @Published var form: HotelRoomForm
    @Published var selectedClassification: Classification
    @Published var validationErrors: [ValidationError] = []

    init(form: HotelRoomForm) {
        self.form = form
        self.selectedClassification = form.details.classification
    }

    var isNextDisabled: Bool {
           !validationErrors.isEmpty
       }
       
       func validate() {
           validationErrors = ValidationManager.shared.validateStep4(classification: selectedClassification)
       }
       
       func goToNext() {
           validate()
           if validationErrors.isEmpty {
               form.details.classification = selectedClassification
           }
       }
}
