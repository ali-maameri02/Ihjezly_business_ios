// Features/HotelRoom/Views/HotelRoomStep6View.swift

import SwiftUI

struct HotelRoomStep6View: View {
    @StateObject private var viewModel: HotelRoomStep6ViewModel
    let onBack: () -> Void
    let onNext: (HotelRoomForm) -> Void

    init(
        form: HotelRoomForm,
        onBack: @escaping () -> Void,
        onNext: @escaping (HotelRoomForm) -> Void
    ) {
        _viewModel = StateObject(wrappedValue: HotelRoomStep6ViewModel(form: form))
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
                
                // SCROLLABLE CONTENT
                ScrollView {
                    VStack(spacing: 24) {
                        // Facilities Grid (3x3) - "الميزات"
                        VStack(spacing: 16) {
                            Text("الميزات")
                                .font(.headline)
                                .foregroundColor(.secondary)
                            
                            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 3), spacing: 16) {
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
                        
                        // Features Grid (3x3) - "المرافق" (✅ Changed from horizontal to grid)
                        VStack(spacing: 16) {
                            Text("المرافق")
                                .font(.headline)
                                .foregroundColor(.secondary)
                            
                            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 3), spacing: 16) {
                                ForEach(Feature.allCases, id: \.self) { feature in
                                    FeatureCard(
                                        feature: feature,
                                        isSelected: viewModel.selectedFeatures.contains(feature),
                                        onSelect: { viewModel.toggleFeature(feature) }
                                    )
                                }
                            }
                            .padding(.horizontal, 16)
                        }
                    }
                    .padding(.bottom, 16)
                }
                
                // VALIDATION ERROR
                if !viewModel.validationErrors.isEmpty {
                    ValidationView(errors: viewModel.validationErrors)
                }
                
                // FIXED NEXT BUTTON
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
