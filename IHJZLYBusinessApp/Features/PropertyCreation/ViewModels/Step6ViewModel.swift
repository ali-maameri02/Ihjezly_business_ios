// Features/PropertyCreation/ViewModels/Step6ViewModel.swift
import Foundation
import Combine

@MainActor
final class Step6ViewModel<FormData: PropertyForm>: ObservableObject {
    @Published var form: FormData
    @Published var selectedFacilities: Set<Facility> = []
    @Published var validationErrors: [ValidationError] = []

    init(form: FormData) {
        self.form = form
        self.selectedFacilities = Set(form.facilities)
        validate()
    }

    var isNextDisabled: Bool { !validationErrors.isEmpty }

    func validate() {
        validationErrors = ValidationManager.shared.validateStep6(facilities: Array(selectedFacilities))
    }

    func toggleFacility(_ facility: Facility) {
        if selectedFacilities.contains(facility) {
            selectedFacilities.remove(facility)
        } else {
            selectedFacilities.insert(facility)
        }
        validate()
    }

    func saveSelection() {
        form.facilities = Array(selectedFacilities)
    }
}
