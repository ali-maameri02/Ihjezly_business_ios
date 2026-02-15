// Features/HotelRoom/ViewModels/HotelRoomStep3ViewModel.swift

import Foundation
import Combine
// Features/HotelRoom/ViewModels/HotelRoomStep3ViewModel.swift
@MainActor
final class HotelRoomStep3ViewModel: ObservableObject {
    @Published var form: HotelRoomForm
    @Published var selectedRoomType: HotelRoomType
    @Published var adultCount: Int {
        didSet { validate() }
    }
    @Published var childCount: Int {
        didSet { validate() }
    }
    @Published var validationErrors: [ValidationError] = []

    init(form: HotelRoomForm) {
        self.form = form
        self.selectedRoomType = form.details.hotelRoomType
        self.adultCount = form.details.numberOfAdults
        self.childCount = form.details.numberOfChildren
        validate()
    }

    var isNextDisabled: Bool { !validationErrors.isEmpty }

    func validate() {
        validationErrors = ValidationManager.shared.validateStep3(adults: adultCount, children: childCount)
    }
    
    func goToNext() {
        validate()
        if validationErrors.isEmpty {
            // ✅ Update form immediately
            form.details.numberOfAdults = adultCount
            form.details.numberOfChildren = childCount
            form.details.hotelRoomType = selectedRoomType
        }
    }
}
