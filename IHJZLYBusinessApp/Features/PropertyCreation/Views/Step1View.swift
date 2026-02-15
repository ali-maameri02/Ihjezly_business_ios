import SwiftUI

struct Step1View<FormData: PropertyForm>: View {
    @StateObject private var viewModel: Step1ViewModel<FormData>
    let onBack: (() -> Void)?
    let onNext: (FormData) -> Void
    
    init(
        form: FormData,
        locationUseCase: LocationUseCase,
        currentUser: User,
        onBack: (() -> Void)? = nil,
        onNext: @escaping (FormData) -> Void
    ) {
        _viewModel = StateObject(wrappedValue: Step1ViewModel(form: form, locationManager: locationUseCase, currentUser: currentUser))
        self.onBack = onBack
        self.onNext = onNext
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Header
                VStack(spacing: 0) {
                    HStack {
                        if let onBack = onBack {
                            BackButton(action: onBack)
                        } else {
                            BackButton(action: {})
                        }
                        Spacer()
                        Text("معلومات العقار")
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
                    // Title field
                    VStack(alignment: .leading, spacing: 4) {
                        Text("اسم العقار")
                            .font(.headline)
                            .foregroundColor(.secondary)
                        TextField("", text: $viewModel.title)
                            .textFieldStyle(PlainTextFieldStyle())
                            .padding(12)
                            .background(Color.white)
                            .cornerRadius(8)
                            .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.gray.opacity(0.2), lineWidth: 0.5))
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.horizontal, 16)
                    
                    // City/District selectors (reuse existing implementation)
                    // ...
                    
                    // Description field
                    VStack(alignment: .leading, spacing: 4) {
                        Text("وصف العقار")
                            .font(.headline)
                            .foregroundColor(.secondary)
                        TextField("", text: $viewModel.description)
                            .multilineTextAlignment(.leading)
                            .lineLimit(nil)
                            .frame(height: 40)
                            .textFieldStyle(PlainTextFieldStyle())
                            .padding(12)
                            .background(Color.white)
                            .cornerRadius(8)
                            .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.gray.opacity(0.2), lineWidth: 0.5))
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.horizontal, 16)
                }
                
                ValidationView(errors: viewModel.validationErrors)
                NextButton(
                    action: { onNext(viewModel.form) },
                    isDisabled: viewModel.isNextDisabled
                )
            }
            .background(Color.white)
            .navigationBarHidden(true)
        }
    }
}
