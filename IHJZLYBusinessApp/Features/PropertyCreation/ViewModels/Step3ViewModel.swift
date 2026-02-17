// Features/PropertyCreation/ViewModels/Step3ViewModel.swift
import Foundation
import Combine

@MainActor
class Step3ViewModel<FormData: PropertyForm>: ObservableObject {
    @Published var form: FormData
    @Published var validationErrors: [ValidationError] = []
    @Published var selectedHotelRoomType: HotelRoomType?
    @Published var selectedApartmentType: ApartmentType?
    @Published var maxGuests: Int = 0
    
    private let propertySubType: PropertySubType
    
    init(form: FormData, propertySubType: PropertySubType) {
        self.form = form
        self.propertySubType = propertySubType
        validate()
    }
    
    var isNextDisabled: Bool { !validationErrors.isEmpty }
    
    func validate() {
        validationErrors = []
        switch propertySubType {
        case .hotelRoom, .resort:
            if selectedHotelRoomType == nil {
                validationErrors.append(ValidationError(message: "يجب اختيار نوع الغرفة"))
            }
        case .apartment:
            if selectedApartmentType == nil {
                validationErrors.append(ValidationError(message: "يجب اختيار نوع الشقة"))
            }
        case .chalet, .restHouse:
            if maxGuests == 0 {
                validationErrors.append(ValidationError(message: "يجب تحديد عدد الضيوف"))
            }
        default:
            break
        }
    }
    
    func goToNext() {
        validate()
    }
}
