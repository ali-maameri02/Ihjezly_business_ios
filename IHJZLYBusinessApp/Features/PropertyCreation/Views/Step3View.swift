import SwiftUI

struct Step3View<FormData: PropertyForm>: View {
    @StateObject private var viewModel: Step3ViewModel<FormData>
    let propertySubType: PropertySubType
    let onNext: (FormData) -> Void
    
    init(form: FormData, propertySubType: PropertySubType, onNext: @escaping (FormData) -> Void) {
        _viewModel = StateObject(wrappedValue: Step3ViewModel(form: form, propertySubType: propertySubType))
        self.propertySubType = propertySubType
        self.onNext = onNext
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Header
                VStack(spacing: 0) {
                    HStack {
                        BackButton(action: {})
                        Spacer()
                        Text(stepTitle)
                            .font(.title2)
                            .fontWeight(.semibold)
                        Spacer()
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 12)
                    
                    Divider()
                        .background(Color(hex: "#88417A"))
                        .frame(height: 2)
                        .padding(.horizontal, 16)
                        .padding(.top, 4)
                }
                .background(Color.white)
                .shadow(radius: 1)
                
                ScrollView {
                    content
                }
                
                ValidationView(errors: viewModel.validationErrors)
                NextButton(
                    action: {
                        viewModel.goToNext()
                        onNext(viewModel.form)
                    },
                    isDisabled: viewModel.isNextDisabled
                )
            }
            .background(Color.white)
            .navigationBarHidden(true)
        }
    }
    
    private var stepTitle: String {
        switch propertySubType {
        case .hotelRoom, .resort:
            return "نوع الغرفة"
        case .apartment:
            return "نوع الشقة"
        case .chalet, .restHouse:
            return "عدد الضيوف"
        default:
            return "تفاصيل العقار"
        }
    }
    
    private var content: some View {
        Group {
            switch propertySubType {
            case .hotelRoom:
                ForEach(hotelRoomTypes, id: \.title) { item in
                    RoomTypeOption(
                        title: item.title,
                        isSelected: viewModel.selectedHotelRoomType == item.roomType,
                        onSelect: { viewModel.selectedHotelRoomType = item.roomType }
                    )
                }
                
            case .apartment:
                ForEach(apartmentTypes, id: \.title) { item in
                    RoomTypeOption(
                        title: item.title,
                        isSelected: viewModel.selectedApartmentType == item.apartmentType,
                        onSelect: { viewModel.selectedApartmentType = item.apartmentType }
                    )
                }
                
            case .chalet, .restHouse:
                GuestCounter(
                    label: "عدد الضيوف",
                    count: $viewModel.maxGuests,
                    min: 1,
                    max: 20
                )
                
            default:
                Text("Not implemented")
            }
        }
    }
}

private struct HotelRoomTypeItem {
    let title: String
    let roomType: HotelRoomType
}

private struct ApartmentTypeItem {
    let title: String
    let apartmentType: ApartmentType
}

private let hotelRoomTypes = [
    HotelRoomTypeItem(title: "غرفة فردية", roomType: .singleRoom),
    HotelRoomTypeItem(title: "غرفة زوجية بسرير واحد", roomType: .twinRoomOneBed),
    HotelRoomTypeItem(title: "غرفة زوجية بسريرين", roomType: .twinRoomTwoBeds),
    HotelRoomTypeItem(title: "جناح", roomType: .suite),
    HotelRoomTypeItem(title: "غرفة ثلاثية", roomType: .tripleRoom),
    HotelRoomTypeItem(title: "غرفة رباعية", roomType: .quadrupleRoom),
    HotelRoomTypeItem(title: "جناح وزاري", roomType: .ministerialSuite),
    HotelRoomTypeItem(title: "جناح رئاسي", roomType: .presidentialSuite)
]

private let apartmentTypes = [
    ApartmentTypeItem(title: "استوديو", apartmentType: .studio),
    ApartmentTypeItem(title: "شقة 1 غرفة", apartmentType: .oneBedroom),
    ApartmentTypeItem(title: "شقة 2 غرفة", apartmentType: .twoBedrooms),
    ApartmentTypeItem(title: "شقة 3 غرف", apartmentType: .threeBedrooms),
    ApartmentTypeItem(title: "فيلا", apartmentType: .villa)
]
