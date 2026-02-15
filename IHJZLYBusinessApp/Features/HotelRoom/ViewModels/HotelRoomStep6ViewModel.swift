// Features/HotelRoom/ViewModels/HotelRoomStep6ViewModel.swift

import Foundation
import Combine

@MainActor
final class HotelRoomStep6ViewModel: ObservableObject {
    @Published var form: HotelRoomForm
    @Published var selectedFacilities: [Facility] = []
    @Published var selectedFeatures: [Feature] = []
    @Published var validationErrors: [ValidationError] = []

    init(form: HotelRoomForm) {
        self.form = form
        self.selectedFacilities = form.facilities
        validate()
    }

    var isNextDisabled: Bool {
        !validationErrors.isEmpty
    }

    func toggleFacility(_ facility: Facility) {
        if selectedFacilities.contains(facility) {
            selectedFacilities.removeAll { $0 == facility }
        } else {
            selectedFacilities.append(facility)
        }
        validate()
    }

    func toggleFeature(_ feature: Feature) {
        if selectedFeatures.contains(feature) {
            selectedFeatures.removeAll { $0 == feature }
        } else {
            selectedFeatures.append(feature)
        }
        validate()
    }

    func saveSelection() {
        form.facilities = selectedFacilities
        print("✅ Step 6: facilities=\(selectedFacilities.count)")
    }

    func validate() {
        validationErrors = ValidationManager.shared.validateStep6(facilities: selectedFacilities)
    }
}
