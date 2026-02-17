import SwiftUI

struct Step4View<FormData: PropertyForm>: View {
    @StateObject private var viewModel: Step4ViewModel<FormData>
    let onNext: (FormData) -> Void
    
    init(form: FormData, onNext: @escaping (FormData) -> Void) {
        _viewModel = StateObject(wrappedValue: Step4ViewModel(form: form))
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
                
                ScrollView {
                    VStack(spacing: 8) {
                        ForEach(classifications, id: \.self) { classification in
                            ClassificationOption(
                                title: classification.arabicName,
                                isSelected: viewModel.selectedClassification == classification,
                                onSelect: { viewModel.selectedClassification = classification }
                            )
                        }
                    }
                    .padding(.horizontal, 16)
                }
                
                NextButton(
                    action: {
                        viewModel.goToNext()
                        onNext(viewModel.form)
                    },
                    isDisabled: false
                )
            }
            .background(Color.white)
            .navigationBarHidden(true)
        }
    }
    
    private let classifications: [Classification] = [
        .none, .oneStar, .twoStars, .threeStars,
        .fourStars, .fiveStars, .sixStars, .sevenStars
    ]
}
