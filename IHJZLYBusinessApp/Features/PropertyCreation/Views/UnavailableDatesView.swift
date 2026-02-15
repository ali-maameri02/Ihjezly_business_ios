// Features/PropertyCreation/Views/UnavailableDatesView.swift
import SwiftUI

struct UnavailableDatesView: View {
    @StateObject private var viewModel: UnavailableDatesViewModel
    let onBack: () -> Void
    let onNext: (HotelRoomForm) -> Void
    
    init(form: HotelRoomForm, onBack: @escaping () -> Void, onNext: @escaping (HotelRoomForm) -> Void) {
        _viewModel = StateObject(wrappedValue: UnavailableDatesViewModel(form: form))
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
                        Text("تواريخ عدم التوفر")
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
                    VStack(spacing: 16) {
                        // Date picker explanation
                        Text("اختر التواريخ التي لن يكون العقار متاحًا فيها")
                            .font(.body)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 16)
                        
                        // Selected dates list
                        if !viewModel.selectedDates.isEmpty {
                            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 8) {
                                ForEach(viewModel.selectedDates, id: \.self) { date in
                                    HStack {
                                        Text(date.formatted(.dateTime.year().month().day()))
                                            .font(.caption)
                                            .foregroundColor(.white)
                                        Button(action: { viewModel.removeDate(date) }) {
                                            Image(systemName: "xmark")
                                                .font(.caption)
                                                .foregroundColor(.white)
                                        }
                                    }
                                    .frame(maxWidth: .infinity)
                                    .padding(8)
                                    .background(Color(hex: "#88417A"))
                                    .cornerRadius(8)
                                }
                            }
                            .padding(.horizontal, 16)
                        }
                        
                        // Add date button
                        Button(action: { viewModel.showDatePicker = true }) {
                            HStack {
                                Image(systemName: "plus")
                                Text("إضافة تاريخ")
                            }
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                        }
                        .background(Color(hex: "#88417A"))
                        .cornerRadius(12)
                        .padding(.horizontal, 16)
                    }
                    .padding(.vertical, 16)
                }
                
                NextButton(
                    action: {
                        viewModel.saveDates()
                        onNext(viewModel.form)
                    },
                    isDisabled: false
                )
            }
            .background(Color.white)
            .navigationBarHidden(true)
            .sheet(isPresented: $viewModel.showDatePicker) {
                DatePickerView(selectedDate: $viewModel.tempDate) {
                    viewModel.addDate(viewModel.tempDate)
                    viewModel.showDatePicker = false
                }
            }
        }
    }
}

