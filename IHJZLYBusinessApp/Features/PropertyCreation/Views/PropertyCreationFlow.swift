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

    // Whether this property type has a classification step
    private var hasClassification: Bool {
        propertySubType != .chalet && propertySubType != .restHouse
    }

    // Step mapping:
    // 1 = Title/Description
    // 2 = Location
    // 3 = Type-specific details (room type / guest count)
    // 4 = Classification (only if hasClassification), else skip to 5
    // 5 = Images
    // 6 = Facilities
    // 7 = Unavailable Dates (all types)
    // 8 = Price

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
                        currentStep = hasClassification ? 4 : 5
                    }
                )

            case 4:
                Step4View(
                    form: form,
                    onNext: { updatedForm in
                        form = updatedForm
                        currentStep = 5
                    }
                )

            case 5:
                Step5View(
                    form: form,
                    onNext: { updatedForm in
                        form = updatedForm
                        currentStep = 6
                    }
                )

            case 6:
                Step6View(
                    form: form,
                    onNext: { updatedForm in
                        form = updatedForm
                        currentStep = 7
                    }
                )

            case 7:
                UnavailableDatesView(
                    form: form,
                    onBack: { currentStep = 6 },
                    onNext: { updatedForm in
                        form = updatedForm
                        currentStep = 8
                    }
                )

            case 8:
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

    private func submitForm() {
        isSubmitting = true
        Task {
            do {
                let propertyId = try await createUseCase.execute(form: form, propertyType: propertySubType)
                print("✅ Property created with ID: \(propertyId)")
            } catch {
                await MainActor.run {
                    self.submitError = "فشل إنشاء العقار: \(error.localizedDescription)"
                }
            }
            isSubmitting = false
        }
    }
}
