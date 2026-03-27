// Features/PropertyCreation/ViewModels/Step4ViewModel.swift
import Foundation
import Combine

@MainActor
final class Step4ViewModel<FormData: PropertyForm>: ObservableObject {
    @Published var form: FormData
    @Published var selectedClassification: Classification = .none
    
    init(form: FormData) {
        self.form = form
        self.selectedClassification = form.details.classification
    }
    
    func goToNext() {
        form.details.classification = selectedClassification
    }
}
