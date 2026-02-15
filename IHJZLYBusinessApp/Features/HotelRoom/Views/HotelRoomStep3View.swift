// Features/HotelRoom/Views/HotelRoomStep3View.swift
// Features/HotelRoom/Views/HotelRoomStep3View.swift
import SwiftUI

struct HotelRoomStep3View: View {
    @StateObject private var viewModel: HotelRoomStep3ViewModel
    let onBack: () -> Void
    let onNext: (HotelRoomForm) -> Void

    init(
        form: HotelRoomForm,
        onBack: @escaping () -> Void,
        onNext: @escaping (HotelRoomForm) -> Void
    ) {
        _viewModel = StateObject(wrappedValue: HotelRoomStep3ViewModel(form: form))
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
                        Text("نوع الغرفة")
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
                    VStack(spacing: 12) {
                        ForEach(roomTypes, id: \.title) { item in
                            RoomTypeOption(
                                title: item.title,
                                isSelected: viewModel.selectedRoomType == item.type,
                                onSelect: { viewModel.selectedRoomType = item.type }
                            )
                        }
                        .padding(.horizontal, 16)
                        .padding(.top, 16)
                        
                        GuestCounter(
                            label: "عدد الاطفال",
                            count: $viewModel.childCount,
                            min: 0,
                            max: 10
                        )
                        
                        GuestCounter(
                            label: "عدد البالغين",
                            count: $viewModel.adultCount,
                            min: 1,
                            max: 10
                        )
                    }
                    .padding(.bottom, 8)
                }
                
                ValidationView(errors: viewModel.validationErrors)

                NextButton(
                    action: {
                        viewModel.goToNext()
                        onNext(viewModel.form) // ✅ Pass updated form
                    },
                    isDisabled: viewModel.isNextDisabled
                )
            }
            .background(Color.white)
            .navigationBarHidden(true)
        }
    }
}

// MARK: - Reusable Components (same as before)
private let roomTypes = [
    RoomTypeItem(title: "غرفة فردية", type: HotelRoomType.singleRoom),
    RoomTypeItem(title: "غرفة زوجية بسرير واحد", type: HotelRoomType.twinRoomOneBed),
    RoomTypeItem(title: "غرفة زوجية بسريرين", type: HotelRoomType.twinRoomTwoBeds),
    RoomTypeItem(title: "جناح", type: HotelRoomType.suite),
    RoomTypeItem(title: "غرفة ثلاثية", type: HotelRoomType.tripleRoom),
    RoomTypeItem(title: "غرفة رباعية", type: HotelRoomType.quadrupleRoom),
    RoomTypeItem(title: "جناح وزاري", type: HotelRoomType.ministerialSuite),
    RoomTypeItem(title: "جناح رئاسي", type: HotelRoomType.presidentialSuite)
]

struct RoomTypeItem {
    let title: String
    let type: HotelRoomType
}

struct RoomTypeOption: View {
    let title: String
    let isSelected: Bool
    let onSelect: () -> Void

    var body: some View {
        HStack {
            Text(title)
                .font(.headline)
                .foregroundColor(.primary)
            Spacer()
            RadioButton(isSelected: isSelected, action: onSelect)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
    }
}

struct RadioButton: View {
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            ZStack {
                Circle()
                    .stroke(Color.gray.opacity(0.5), lineWidth: 2)
                    .frame(width: 28, height: 28)
                if isSelected {
                    Circle()
                        .fill(Color(red: 136/255, green: 65/255, blue: 122/255))
                        .frame(width: 18, height: 18)
                }
            }
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct GuestCounter: View {
    let label: String
    @Binding var count: Int
    let min: Int
    let max: Int

    var body: some View {
        HStack {
            Text(label)
                .font(.headline)
                .foregroundColor(.primary)
            Spacer()
            HStack(spacing: 12) {
                Button("-") {
                    if count > min { count -= 1 }
                }
                .frame(width: 44, height: 44)
                .background(Color(hex: "#88417A"))
                .cornerRadius(22)
                .foregroundColor(.white)
                
                Text("\(count)")
                    .font(.title2)
                    .minimumScaleFactor(0.5)
                
                Button("+") {
                    if count < max { count += 1 }
                }
                .frame(width: 44, height: 44)
                .background(Color(hex: "#88417A"))
                .cornerRadius(22)
                .foregroundColor(.white)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
    }
}
