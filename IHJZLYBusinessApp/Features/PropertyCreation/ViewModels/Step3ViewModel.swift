// Features/PropertyCreation/ViewModels/Step3ViewModel.swift
import Foundation
import Combine

@MainActor
class Step3ViewModel: ObservableObject {
    @Published var form: GenericPropertyForm
    @Published var validationErrors: [ValidationError] = []
    
    // Type-specific state
    @Published var selectedHotelRoomType: HotelRoomType?
    @Published var selectedApartmentType: ApartmentType?
    @Published var maxGuests: Int = 0
    
    init(form: GenericPropertyForm) {
        self.form = form
        setupInitialState()
    }
    
    private func setupInitialState() {
        switch form.details {
        case let details as HotelRoomDetails:
            selectedHotelRoomType = details.roomType
        case let details as ApartmentDetails:
            selectedApartmentType = details.roomType
        case let details as SimplePropertyDetails:
            maxGuests = details.maxGuests
        default: break
        }
    }
    
    var isNextDisabled: Bool { !validationErrors.isEmpty }
    
    func validate() {
        if let _ = form.details as? HotelRoomDetails {
            validationErrors = ValidationManager.shared.validateStep3(
                adults: selectedHotelRoomType != nil ? 1 : 0,
                children: 0
            )
        }
    }
    
    func goToNext() {
        validate()
        if validationErrors.isEmpty {
            switch form.details {
            case is HotelRoomDetails:
                if let type = selectedHotelRoomType {
                    form.details = HotelRoomDetails(
                        numberOfAdults: 1,
                        numberOfChildren: 0,
                        roomType: type,
                        classification: .none
                    )
                }
            case is ApartmentDetails:
                if let type = selectedApartmentType {
                    form.details = ApartmentDetails(
                        roomType: type,
                        classification: .none
                    )
                }
            case is SimplePropertyDetails:
                form.details = SimplePropertyDetails(
                    maxGuests: maxGuests,
                    classification: .none
                )
            default: break
            }
        }
    }
}
