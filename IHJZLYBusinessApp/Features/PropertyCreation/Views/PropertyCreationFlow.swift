// Features/PropertyCreation/Views/PropertyCreationFlow.swift
import SwiftUI

struct PropertyCreationFlow: View {
    @State private var currentStep: Int = 1
    @State private var form = HotelRoomForm()
    @State private var isSubmitting = false
    @State private var submitError: String?
    
    private let propertySubType: PropertySubType
    private let locationUseCase: LocationUseCase
    private let createUseCase: CreatePropertyUseCaseProtocol
    private let currentUser: User
    
    init(
        propertySubType: PropertySubType,
        locationUseCase: LocationUseCase,
        createUseCase: CreatePropertyUseCaseProtocol,
        currentUser: User
    ) {
        self.propertySubType = propertySubType
        self.locationUseCase = locationUseCase
        self.createUseCase = createUseCase
        self.currentUser = currentUser
    }
    
    var body: some View {
        Group {
            switch currentStep {
            case 1:
                Step1View(
                    form: form,
                    locationUseCase: locationUseCase,
                    currentUser: currentUser,
                    onBack: nil,
                    onNext: { updatedForm in
                        form = updatedForm
                        currentStep = 2
                    }
                )
                
            case 2:
                Step2View(
                    form: form,
                    onNext: { location in
                        var updatedForm = form
                        updatedForm.location = location
                        self.form = updatedForm
                        currentStep = 3
                    }
                )
                
            case 3:
                Step3View(
                    form: form,
                    propertySubType: propertySubType,
                    onNext: { updatedForm in
                        form = updatedForm
                        currentStep = nextStepAfter3
                    }
                )
                
            case 4:
                if shouldShowClassification {
                    Step4View(
                        form: form,
                        onNext: { updatedForm in
                            form = updatedForm
                            currentStep = 5
                        }
                    )
                } else {
                    Step5View(
                        form: form,
                        onNext: { updatedForm in
                            form = updatedForm
                            currentStep = 6
                        }
                    )
                }
                
            case 5:
                if shouldShowClassification {
                    Step5View(
                        form: form,
                        onNext: { updatedForm in
                            form = updatedForm
                            currentStep = 6
                        }
                    )
                } else {
                    Step6View(
                        form: form,
                        onNext: { updatedForm in
                            form = updatedForm
                            currentStep = 7
                        }
                    )
                }
                
            case 6:
                if propertySubType == .chalet || propertySubType == .restHouse {
                    UnavailableDatesView(
                        form: form,
                        onBack: { currentStep = 5 },
                        onNext: { updatedForm in
                            form = updatedForm
                            currentStep = 7
                        }
                    )
                } else {
                    Step6View(
                        form: form,
                        onNext: { updatedForm in
                            form = updatedForm
                            currentStep = 7
                        }
                    )
                }
                
            case 7:
                Step7View(
                    form: form,
                    onNext: { updatedForm in
                        form = updatedForm
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
                .disabled(isSubmitting)
                
            default:
                Text("Unknown Step")
            }
        }
    }
    
    private var shouldShowClassification: Bool {
        propertySubType != .chalet && propertySubType != .restHouse
    }
    
    private var nextStepAfter3: Int {
        shouldShowClassification ? 4 : 5
    }
    
    private func submitForm() {
        isSubmitting = true
        Task {
            do {
                let propertyId = try await createUseCase.execute(form: form, propertyType: propertySubType)
                print("✅ Property created with ID: \(propertyId)")
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    // Dismiss flow
                }
            } catch {
                await MainActor.run {
                    self.submitError = "فشل إنشاء العقار: \(error.localizedDescription)"
                }
            }
            isSubmitting = false
        }
    }
}
