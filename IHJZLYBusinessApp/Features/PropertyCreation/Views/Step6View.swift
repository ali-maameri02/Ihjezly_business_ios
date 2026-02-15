import SwiftUI

struct Step6View<FormData: PropertyForm>: View {
    @StateObject private var viewModel: Step6ViewModel<FormData>
    let onNext: (FormData) -> Void
    
    init(form: FormData, onNext: @escaping (FormData) -> Void) {
        _viewModel = StateObject(wrappedValue: Step6ViewModel(form: form))
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
                        Text("ميزات و مزايا العقار")
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
                    // Facilities grid (reuse existing implementation)
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 3)) {
                        ForEach(Facility.allCases, id: \.self) { facility in
                            FacilityCard(
                                facility: facility,
                                isSelected: viewModel.selectedFacilities.contains(facility),
                                onSelect: { viewModel.toggleFacility(facility) }
                            )
                        }
                    }
                    .padding(.horizontal, 16)
                }
                
                ValidationView(errors: viewModel.validationErrors)
                NextButton(
                    action: {
                        viewModel.saveSelection()
                        onNext(viewModel.form)
                    },
                    isDisabled: viewModel.isNextDisabled
                )
            }
            .background(Color.white)
            .navigationBarHidden(true)
        }
    }
}
