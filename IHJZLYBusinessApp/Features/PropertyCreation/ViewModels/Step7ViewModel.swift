// Features/PropertyCreation/ViewModels/Step7ViewModel.swift
import Foundation
import Combine

@MainActor
final class Step7ViewModel<FormData: PropertyForm>: ObservableObject {
    @Published var form: FormData
    @Published var priceText: String = ""
    @Published var discountText: String = ""
    @Published var validationErrors: [ValidationError] = []

    init(form: FormData) {
        self.form = form
        self.priceText = form.price > 0 ? "\(form.price)" : ""
        self.discountText = form.discount > 0 ? "\(form.discount)" : ""
        validate()
    }

    var isNextDisabled: Bool { !validationErrors.isEmpty }

    func validate() {
        let price = Double(priceText) ?? 0
        let discount = Double(discountText) ?? 0
        validationErrors = []
        if price <= 0 {
            validationErrors.append(ValidationError(message: "السعر مطلوب"))
        }
        if discount < 0 || discount > 100 {
            validationErrors.append(ValidationError(message: "الخصم يجب أن يكون بين 0 و 100"))
        }
    }
}
