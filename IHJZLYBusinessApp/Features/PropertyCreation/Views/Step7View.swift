import SwiftUI

struct Step7View<FormData: PropertyForm>: View {
    @StateObject private var viewModel: Step7ViewModel<FormData>
    let onNext: (FormData) -> Void
    
    init(form: FormData, onNext: @escaping (FormData) -> Void) {
        _viewModel = StateObject(wrappedValue: Step7ViewModel(form: form))
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
                
                ScrollView {
                    // Price field
                    VStack(alignment: .leading) {
                        Text("السعر الحالي")
                            .font(.headline)
                            .foregroundColor(.secondary)
                        TextField("دينار", text: $viewModel.priceText)
                            .keyboardType(.decimalPad)
                            .textFieldStyle(PlainTextFieldStyle())
                            .padding(12)
                            .background(Color.white)
                            .cornerRadius(8)
                            .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.gray.opacity(0.2), lineWidth: 0.5))
                    }
                    .padding(.horizontal, 16)
                    
                    // Discount field
                    VStack(alignment: .leading) {
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
                                .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.gray.opacity(0.2), lineWidth: 0.5))
                        }
                    }
                    .padding(.horizontal, 16)
                }
                
                ValidationView(errors: viewModel.validationErrors)
                FinishButton(
                    action: {
                        var updatedForm = viewModel.form
                        updatedForm.price = Double(viewModel.priceText) ?? 0
                        updatedForm.discount = Double(viewModel.discountText) ?? 0
                        onNext(updatedForm)
                    },
                    isDisabled: viewModel.isNextDisabled
                )
            }
            .background(Color.white)
            .navigationBarHidden(true)
        }
    }
}
