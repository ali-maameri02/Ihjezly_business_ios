// Features/HotelRoom/Views/HotelRoomCreationFlow.swift
import SwiftUI

struct HotelRoomCreationFlow: View {
    @State private var currentStep: Int = 1
    @StateObject private var step1ViewModel: HotelRoomStep1ViewModel
    @State private var form = HotelRoomForm()
    @State private var isSubmitting = false
    @State private var submitError: String?
    @State private var showSuccessAlert = false
    @Environment(\.dismiss) var dismiss
    private let locationUseCase: LocationUseCase
    private let createHotelRoomUseCase: CreateHotelRoomUseCase

    init(
        viewModel: HotelRoomStep1ViewModel,
        locationUseCase: LocationUseCase,
        createHotelRoomUseCase: CreateHotelRoomUseCase
    ) {
        _step1ViewModel = StateObject(wrappedValue: viewModel)
        self.locationUseCase = locationUseCase
        self.createHotelRoomUseCase = createHotelRoomUseCase
    }
    
    var body: some View {
        Group {
            switch currentStep {
            case 1:
                HotelRoomStep1View(
                    viewModel: step1ViewModel,
                    onBack: nil,
                    onNext: {
                        form = step1ViewModel.form
                        currentStep = 2
                    }
                )
            case 2:
                HotelRoomStep2View(
                    form: form,
                    onBack: { currentStep = 1 },
                    onNext: { location in
                        var updatedForm = form
                        updatedForm.location = location
                        self.form = updatedForm
                        currentStep = 3
                    }
                )
            case 3:
                HotelRoomStep3View(
                    form: form,
                    onBack: { currentStep = 2 },
                    onNext: { updatedForm in
                        self.form = updatedForm
                        currentStep = 4
                    }
                )
            case 4:
                HotelRoomStep4View(
                    form: form,
                    onBack: { currentStep = 3 },
                    onNext: { updatedForm in
                        self.form = updatedForm
                        currentStep = 5
                    }
                )
            case 5:
                HotelRoomStep5View(
                    form: form,
                    onBack: { currentStep = 4 },
                    onNext: { updatedForm in
                        self.form = updatedForm
                        currentStep = 6
                    }
                )
            case 6:
                HotelRoomStep6View(
                    form: form,
                    onBack: { currentStep = 5 },
                    onNext: { updatedForm in
                        self.form = updatedForm
                        currentStep = 7
                    }
                )
            case 7:
                ZStack {
                    HotelRoomStep7View(
                        form: form,
                        onBack: { currentStep = 6 },
                        onNext: { updatedForm in
                            self.form = updatedForm
                            submitForm()
                        }
                    )
                    .alert("خطأ", isPresented: Binding(
                        get: { self.submitError != nil },
                        set: { _ in self.submitError = nil }
                    )) {
                        Button("موافق") { }
                    } message: {
                        Text(self.submitError ?? "")
                    }
                    .alert("نجاح", isPresented: $showSuccessAlert) {
                        Button("حسناً") {
                            dismiss()
                        }
                    } message: {
                        Text("تم إضافة العقار بنجاح")
                    }
                    .disabled(isSubmitting)
                    
                    if isSubmitting {
                        ZStack {
                            Color.black.opacity(0.3)
                                .ignoresSafeArea()
                            VStack(spacing: 16) {
                                ProgressView()
                                    .scaleEffect(1.5)
                                    .tint(.white)
                                Text("جارٍ إضافة العقار...")
                                    .foregroundColor(.white)
                                    .font(.headline)
                            }
                            .padding(30)
                            .background(Color(hex: "#88417A"))
                            .cornerRadius(16)
                        }
                    }
                }
                
            default:
                Text("Unknown Step")
            }
        }
    }
    
    private func submitForm() {
        isSubmitting = true
        Task {
            do {
                let propertyId = try await createHotelRoomUseCase.execute(form: form)
                await MainActor.run {
                    print("✅ Property created with ID: \(propertyId)")
                    isSubmitting = false
                    showSuccessAlert = true
                }
            } catch {
                await MainActor.run {
                    self.submitError = "فشل إنشاء العقار: \(error.localizedDescription)"
                    isSubmitting = false
                }
            }
        }
    }
}
