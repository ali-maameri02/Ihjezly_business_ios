import Foundation
import Combine

@MainActor
class Step3ViewModel<FormData: PropertyForm>: ObservableObject {
    @Published var form: FormData
    @Published var validationErrors: [ValidationError] = []

    @Published var selectedHotelRoomType: HotelRoomType?
    @Published var selectedHotelApartmentType: HotelApartmentType?
    @Published var selectedApartmentType: ApartmentType?
    @Published var selectedResortType: ResortsType?
    @Published var numberOfAdults: Int = 1
    @Published var numberOfChildren: Int = 0
    @Published var maxGuests: Int = 0

    private let propertySubType: PropertySubType

    init(form: FormData, propertySubType: PropertySubType) {
        self.form = form
        self.propertySubType = propertySubType
        self.selectedHotelRoomType = form.details.hotelRoomType
        self.selectedHotelApartmentType = form.details.hotelApartmentType
        self.selectedApartmentType = form.details.apartmentType
        self.selectedResortType = form.details.resortType
        self.numberOfAdults = form.details.numberOfAdults > 0 ? form.details.numberOfAdults : 1
        self.numberOfChildren = form.details.numberOfChildren
        self.maxGuests = form.details.maxGuests > 0 ? form.details.maxGuests : 1
        validate()
    }

    var isNextDisabled: Bool { !validationErrors.isEmpty }

    func validate() {
        validationErrors = []
        switch propertySubType {
        case .hotelRoom:
            if selectedHotelRoomType == nil {
                validationErrors.append(ValidationError(message: "يجب اختيار نوع الغرفة"))
            }
        case .hotelApartment:
            if selectedHotelApartmentType == nil {
                validationErrors.append(ValidationError(message: "يجب اختيار نوع الشقة الفندقية"))
            }
        case .resort:
            if selectedResortType == nil {
                validationErrors.append(ValidationError(message: "يجب اختيار نوع الوحدة"))
            }
        default:
            break
        }
    }

    func goToNext() {
        saveToForm()
        validate()
    }

    private func saveToForm() {
        form.details.numberOfAdults = numberOfAdults
        form.details.numberOfChildren = numberOfChildren
        switch propertySubType {
        case .hotelRoom:
            form.details.hotelRoomType = selectedHotelRoomType ?? .singleRoom
        case .hotelApartment:
            form.details.hotelApartmentType = selectedHotelApartmentType
        case .resort:
            form.details.resortType = selectedResortType
        default:
            break
        }
    }
}
