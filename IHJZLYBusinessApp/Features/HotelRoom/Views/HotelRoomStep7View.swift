// Features/HotelRoom/Views/HotelRoomStep7View.swift

import SwiftUI

struct HotelRoomStep7View: View {
    @StateObject private var viewModel: HotelRoomStep7ViewModel
    let onBack: () -> Void
    let onNext: (HotelRoomForm) -> Void

    init(
        form: HotelRoomForm,
        onBack: @escaping () -> Void,
        onNext: @escaping (HotelRoomForm) -> Void
    ) {
        _viewModel = StateObject(wrappedValue: HotelRoomStep7ViewModel(form: form))
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
                        Text("سعر العقار")
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
                        // Current Price Section
                        VStack(alignment: .leading, spacing: 8) {
                            Text("السعر الحالي")
                                .font(.headline)
                                .foregroundColor(.secondary)
                            
                            TextField("دينار", text: $viewModel.priceText)
                                .keyboardType(.decimalPad)
                                .textFieldStyle(PlainTextFieldStyle())
                                .padding(12)
                                .background(Color.white)
                                .cornerRadius(8)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 8)
                                        .stroke(Color.gray.opacity(0.2), lineWidth: 0.5)
                                )
                        }
                        .padding(.horizontal, 16)
                        
                        // Discount Section
                        VStack(alignment: .leading, spacing: 8) {
                            Text("الخصم")
                                .font(.headline)
                                .foregroundColor(.secondary)
                            
                            HStack {
                                Text("%")
                                    .font(.headline)
                                    .foregroundColor(.secondary)
                                Spacer()
                                TextField("0", text: $viewModel.discountText)
                                    .keyboardType(.decimalPad)
                                    .textFieldStyle(PlainTextFieldStyle())
                                    .padding(12)
                                    .background(Color.white)
                                    .cornerRadius(8)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 8)
                                            .stroke(Color.gray.opacity(0.2), lineWidth: 0.5)
                                    )
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.horizontal, 16)
                        }
                    }
                    .padding(.bottom, 16)
                }
                
                // VALIDATION ERROR
                if !viewModel.validationErrors.isEmpty {
                    ValidationView(errors: viewModel.validationErrors)
                }
                
                FinishButton(
                    action: {
                        // Update form with latest values
                        var updatedForm = viewModel.form
                        updatedForm.price = Double(viewModel.priceText) ?? 0
                        updatedForm.discount = Double(viewModel.discountText) ?? 0
                        onNext(updatedForm) // ✅ Correct way to call onNext
                    },
                    isDisabled: viewModel.isNextDisabled
                )
            }
            .background(Color.white)
            .navigationBarHidden(true)
        }
    }
}
