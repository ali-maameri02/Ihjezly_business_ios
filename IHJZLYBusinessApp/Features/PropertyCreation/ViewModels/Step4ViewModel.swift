// Features/PropertyCreation/ViewModels/Step4ViewModel.swift
import Foundation
import Combine

@MainActor
final class Step4ViewModel<FormData: PropertyForm>: ObservableObject {
    @Published var form: FormData
    @Published var selectedClassification: Classification = .none
    
    init(form: FormData) {
        self.form = form
    }
    
    func goToNext() {
        // Classification is saved in the form by the view
    }
}
