// Features/HotelRoom/Views/HotelRoomStep4View.swift

import SwiftUI

struct HotelRoomStep4View: View {
    @StateObject private var viewModel: HotelRoomStep4ViewModel
    let onBack: () -> Void
    let onNext: (HotelRoomForm) -> Void // ✅ Pass updated form back

    init(
        form: HotelRoomForm,
        onBack: @escaping () -> Void,
        onNext: @escaping (HotelRoomForm) -> Void
    ) {
        _viewModel = StateObject(wrappedValue: HotelRoomStep4ViewModel(form: form))
        self.onBack = onBack
        self.onNext = onNext
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // FIXED HEADER
                VStack(spacing: 0) {
                    HStack {
                        BackButton(action: onBack)
                        Spacer()
                        Text("اختار التصنيف")
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
                
                // SCROLLABLE CONTENT
                ScrollView {
                    VStack(spacing: 16) {
                        ClassificationOption(
                            title: "غير مصنف",
                            isSelected: viewModel.selectedClassification == .none,
                            onSelect: { viewModel.selectedClassification = .none }
                        )
                        
                        ClassificationOption(
                            title: "1 نجمة",
                            isSelected: viewModel.selectedClassification == .oneStar,
                            onSelect: { viewModel.selectedClassification = .oneStar }
                        )
                        
                        ClassificationOption(
                            title: "2 نجمتان",
                            isSelected: viewModel.selectedClassification == .twoStars,
                            onSelect: { viewModel.selectedClassification = .twoStars }
                        )
                        
                        ClassificationOption(
                            title: "3 نجوم",
                            isSelected: viewModel.selectedClassification == .threeStars,
                            onSelect: { viewModel.selectedClassification = .threeStars }
                        )
                        
                        ClassificationOption(
                            title: "4 نجوم",
                            isSelected: viewModel.selectedClassification == .fourStars,
                            onSelect: { viewModel.selectedClassification = .fourStars }
                        )
                        
                        ClassificationOption(
                            title: "5 نجوم",
                            isSelected: viewModel.selectedClassification == .fiveStars,
                            onSelect: { viewModel.selectedClassification = .fiveStars }
                        )
                        
                        ClassificationOption(
                            title: "6 نجوم",
                            isSelected: viewModel.selectedClassification == .sixStars,
                            onSelect: { viewModel.selectedClassification = .sixStars }
                        )
                        
                        ClassificationOption(
                            title: "7 نجوم",
                            isSelected: viewModel.selectedClassification == .sevenStars,
                            onSelect: { viewModel.selectedClassification = .sevenStars }
                        )
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 16)
                    .padding(.bottom, 8)
                }
                
                ValidationView(errors: viewModel.validationErrors)

                NextButton(
                    action: {
                        viewModel.goToNext() // ✅ Save classification in ViewModel
                        onNext(viewModel.form) // ✅ Pass updated form back
                    },
                    isDisabled: false
                )
            }
            .background(Color.white)
            .navigationBarHidden(true)
        }
    }
}

// MARK: - Classification Option (unchanged)
struct ClassificationOption: View {
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
