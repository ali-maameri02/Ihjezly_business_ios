// Features/HotelRoom/ViewModels/HotelRoomStep7ViewModel.swift

import Foundation
import Combine

@MainActor
final class HotelRoomStep7ViewModel: ObservableObject {
    @Published var form: HotelRoomForm
    @Published var priceText: String {
        didSet {
            validate() // ✅ Re-validate when price changes
        }
    }
    @Published var discountText: String {
        didSet {
            validate() // ✅ Re-validate when discount changes
        }
    }
    @Published var validationErrors: [ValidationError] = []

    init(form: HotelRoomForm) {
        self.form = form
        self.priceText = form.price > 0 ? String(format: "%.2f", form.price) : ""
        self.discountText = form.discount > 0 ? String(format: "%.2f", form.discount) : "0"
        validate()
    }

    var isNextDisabled: Bool {
        !validationErrors.isEmpty
    }

    func validate() {
        validationErrors = []
        
        // Handle empty string
        if priceText.isEmpty {
            return // Don't show error until user starts typing
        }
        
        // Validate numeric value
        if let price = Double(priceText), price > 0 {
            // Valid price
        } else {
            validationErrors.append(ValidationError(message: "يرجى إدخال سعر العقار (يجب أن يكون أكبر من 0)"))
        }
    }
}
