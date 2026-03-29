import SwiftUI

struct Step3View<FormData: PropertyForm>: View {
    @StateObject private var viewModel: Step3ViewModel<FormData>
    let propertySubType: PropertySubType
    let onBack: () -> Void
    let onNext: (FormData) -> Void

    init(form: FormData, propertySubType: PropertySubType, onBack: @escaping () -> Void, onNext: @escaping (FormData) -> Void) {
        _viewModel = StateObject(wrappedValue: Step3ViewModel(form: form, propertySubType: propertySubType))
        self.propertySubType = propertySubType
        self.onBack = onBack
        self.onNext = onNext
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Header
                VStack(spacing: 0) {
                    HStack {
                        BackButton(action: onBack)
                        Spacer()
                        Text(propertySubType.step3Title)
                            .font(.title2)
                            .fontWeight(.semibold)
                        Spacer()
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 12)

                    Divider()
                        .background(Color.brand)
                        .frame(height: 2)
                        .padding(.horizontal, 16)
                        .padding(.top, 4)
                }
                .background(Color.cardBackground)
                .shadow(radius: 1)

                ScrollView {
                    VStack(spacing: 12) {
                        content
                    }
                    .padding(.top, 16)
                    .padding(.bottom, 8)
                }

                ValidationView(errors: viewModel.validationErrors)
                NextButton(
                    action: { viewModel.goToNext(); onNext(viewModel.form) },
                    isDisabled: viewModel.isNextDisabled
                )
            }
            .background(Color.cardBackground)
            .navigationBarHidden(true)
        }
    }

    @ViewBuilder
    private var content: some View {
        // Type-selection options (hotelRoom, hotelApartment, resort)
        if propertySubType.showsSelectOptions {
            Group {
                switch propertySubType {
                case .hotelRoom:
                    ForEach(hotelRoomTypes, id: \.title) { item in
                        RoomTypeOption(
                            title: item.title,
                            isSelected: viewModel.selectedHotelRoomType == item.roomType,
                            onSelect: { viewModel.selectedHotelRoomType = item.roomType; viewModel.validate() }
                        )
                    }
                case .hotelApartment:
                    ForEach(apartmentUnitTypes, id: \.title) { item in
                        RoomTypeOption(
                            title: item.title,
                            isSelected: viewModel.selectedHotelApartmentType == item.hotelApartmentType,
                            onSelect: { viewModel.selectedHotelApartmentType = item.hotelApartmentType; viewModel.validate() }
                        )
                    }
                case .resort:
                    ForEach(resortTypes, id: \.title) { item in
                        RoomTypeOption(
                            title: item.title,
                            isSelected: viewModel.selectedResortType == item.resortType,
                            onSelect: { viewModel.selectedResortType = item.resortType; viewModel.validate() }
                        )
                    }
                default:
                    EmptyView()
                }
            }
            .padding(.horizontal, 16)
        }

        // Guest counters (chalet, restHouse, apartment)
        if propertySubType.usesGuestCounters {
            GuestCounter(label: "عدد البالغين", count: $viewModel.numberOfAdults, min: 1, max: 50)
            GuestCounter(label: "عدد الأطفال", count: $viewModel.numberOfChildren, min: 0, max: 50)
        }

        // Types that show options also show guest counters below them
        if propertySubType.showsSelectOptions {
            GuestCounter(label: "عدد الاطفال", count: $viewModel.numberOfChildren, min: 0, max: 10)
            GuestCounter(label: "عدد البالغين", count: $viewModel.numberOfAdults, min: 1, max: 10)
        }
    }
}

// MARK: - Type data
private struct HotelRoomTypeItem      { let title: String; let roomType: HotelRoomType }
private struct HotelApartmentTypeItem { let title: String; let hotelApartmentType: HotelApartmentType }
private struct ResortTypeItem         { let title: String; let resortType: ResortsType }

private let hotelRoomTypes: [HotelRoomTypeItem] = [
    .init(title: "غرفة فردية",            roomType: .singleRoom),
    .init(title: "غرفة زوجية بسرير واحد", roomType: .twinRoomOneBed),
    .init(title: "غرفة زوجية بسريرين",    roomType: .twinRoomTwoBeds),
    .init(title: "جناح",                  roomType: .suite),
    .init(title: "غرفة ثلاثية",           roomType: .tripleRoom),
    .init(title: "غرفة رباعية",           roomType: .quadrupleRoom),
    .init(title: "جناح وزاري",            roomType: .ministerialSuite),
    .init(title: "جناح رئاسي",            roomType: .presidentialSuite)
]

private let apartmentUnitTypes: [HotelApartmentTypeItem] = [
    .init(title: "استوديو",       hotelApartmentType: .studio),
    .init(title: "شقة غرفتين",   hotelApartmentType: .twoBedroom),
    .init(title: "شقة ثلاث غرف", hotelApartmentType: .threeBedroom)
]

private let resortTypes: [ResortTypeItem] = [
    .init(title: "استوديو",       resortType: .studio),
    .init(title: "شقة غرفتين",   resortType: .twoBedroom),
    .init(title: "شقة ثلاث غرف", resortType: .threeBedroom)
]
