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
                        isSelected: viewModel.selectedHotelRoomType == item.type,
                        onSelect: { viewModel.selectedHotelRoomType = item.type }
                    )
                }
                
            case .apartment:
                ForEach(apartmentTypes, id: \.title) { item in
                    RoomTypeOption(
                        title: item.title,
                        isSelected: viewModel.selectedApartmentType == item.type,
                        onSelect: { viewModel.selectedApartmentType = item.type }
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

private let hotelRoomTypes = [
    RoomTypeItem(title: "غرفة فردية", type: HotelRoomType.singleRoom),
    RoomTypeItem(title: "غرفة زوجية بسرير واحد", type: HotelRoomType.twinRoomOneBed),
    RoomTypeItem(title: "غرفة زوجية بسريرين", type: HotelRoomType.twinRoomTwoBeds),
    RoomTypeItem(title: "جناح", type: HotelRoomType.suite),
    RoomTypeItem(title: "غرفة ثلاثية", type: HotelRoomType.tripleRoom),
    RoomTypeItem(title: "غرفة رباعية", type: HotelRoomType.quadrupleRoom),
    RoomTypeItem(title: "جناح وزاري", type: HotelRoomType.ministerialSuite),
    RoomTypeItem(title: "جناح رئاسي", type: HotelRoomType.presidentialSuite)
]

private let apartmentTypes = [
    RoomTypeItem(title: "استوديو", type: ApartmentType.studio),
    RoomTypeItem(title: "شقة 1 غرفة", type: ApartmentType.oneBedroom),
    RoomTypeItem(title: "شقة 2 غرفة", type: ApartmentType.twoBedrooms),
    RoomTypeItem(title: "شقة 3 غرف", type: ApartmentType.threeBedrooms),
    RoomTypeItem(title: "فيلا", type: ApartmentType.villa)
]

struct RoomTypeItem {
    let title: String
    let type: any Equatable & Codable
}
