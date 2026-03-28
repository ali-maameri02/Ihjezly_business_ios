// Features/PropertyCreation/Views/PropertyCreationFlow.swift
import SwiftUI

struct PropertyCreationFlow: View {
    @State private var currentIndex: Int = 0
    @State private var form = HotelRoomForm()
    @State private var isSubmitting = false
    @State private var submitError: String?
    @State private var showSuccessAlert = false
    @Environment(\.dismiss) private var dismiss

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

    private var steps: [PropertySubType.CreationStep] { propertySubType.creationSteps }
    private var totalSteps: Int { steps.count }
    private var currentStep: PropertySubType.CreationStep { steps[currentIndex] }

    private func goNext() { if currentIndex < steps.count - 1 { currentIndex += 1 } }
    private func goBack() { if currentIndex > 0 { currentIndex -= 1 } }

    var body: some View {
        VStack(spacing: 0) {
            StepProgressBar(current: currentIndex + 1, total: totalSteps)

            Group {
                switch currentStep {
                case .step1:
                    Step1View(
                        form: form,
                        locationUseCase: locationUseCase,
                        currentUser: currentUser,
                        onBack: { dismiss() },
                        onNext: { updatedForm in form = updatedForm; goNext() }
                    )
                case .step2:
                    Step2View(
                        form: form,
                        onBack: { goBack() },
                        onNext: { location in
                            var f = form; f.location = location; form = f
                            goNext()
                        }
                    )
                case .step3EventHallGuests:
                    EventHallStep3View(
                        form: form,
                        onBack: { goBack() },
                        onNext: { updatedForm in form = updatedForm; goNext() }
                    )
                case .step4EventHallDates:
                    EventHallStep4View(
                        form: form,
                        onBack: { goBack() },
                        onNext: { updatedForm in form = updatedForm; goNext() }
                    )
                case .step3:
                    Step3View(
                        form: form,
                        propertySubType: propertySubType,
                        onBack: { goBack() },
                        onNext: { updatedForm in form = updatedForm; goNext() }
                    )
                case .step4Classification:
                    Step4View(
                        form: form,
                        onBack: { goBack() },
                        onNext: { updatedForm in form = updatedForm; goNext() }
                    )
                case .step5Images:
                    Step5View(
                        form: form,
                        onBack: { goBack() },
                        onNext: { updatedForm in form = updatedForm; goNext() }
                    )
                case .step6Facilities:
                    Step6View(
                        form: form,
                        onBack: { goBack() },
                        onNext: { updatedForm in form = updatedForm; goNext() }
                    )
                case .step7UnavailableDates:
                    UnavailableDatesView(
                        form: form,
                        onBack: { goBack() },
                        onNext: { updatedForm in form = updatedForm; goNext() }
                    )
                case .step8Price:
                    Step7View(
                        form: form,
                        onBack: { goBack() },
                        onNext: { updatedForm in
                            form = updatedForm
                            submitForm()
                        }
                    )
                    .alert("خطأ", isPresented: Binding(
                        get: { submitError != nil },
                        set: { _ in submitError = nil }
                    )) {
                        Button("موافق") {}
                    } message: {
                        Text(submitError ?? "")
                    }
                    .alert("نجاح", isPresented: $showSuccessAlert) {
                        Button("حسناً") { dismiss() }
                    } message: {
                        Text("تم إضافة العقار بنجاح")
                    }
                    .disabled(isSubmitting)
                }
            }
            .transition(.asymmetric(
                insertion: .move(edge: .trailing),
                removal: .move(edge: .leading)
            ))
            .animation(.easeInOut(duration: 0.25), value: currentIndex)

            if isSubmitting {
                ZStack {
                    Color.black.opacity(0.3).ignoresSafeArea()
                    VStack(spacing: 16) {
                        ProgressView().scaleEffect(1.5).tint(.white)
                        Text("جارٍ إضافة العقار...")
                            .foregroundColor(.white).font(.headline)
                    }
                    .padding(30)
                    .background(Color(hex: "#88417A"))
                    .cornerRadius(16)
                }
            }
        }
        .navigationBarHidden(true)
    }

    private func submitForm() {
        isSubmitting = true
        Task {
            do {
                let id = try await createUseCase.execute(form: form, propertyType: propertySubType)
                await MainActor.run {
                    print("✅ Created: \(id)")
                    isSubmitting = false
                    showSuccessAlert = true
                }
            } catch {
                await MainActor.run {
                    submitError = "فشل إنشاء العقار: \(error.localizedDescription)"
                    isSubmitting = false
                }
            }
        }
    }
}

// MARK: - Progress Bar
struct StepProgressBar: View {
    let current: Int
    let total: Int
    private let brand = Color(red: 136/255, green: 65/255, blue: 122/255)

    var body: some View {
        VStack(spacing: 6) {
            HStack(spacing: 4) {
                ForEach(1...total, id: \.self) { step in
                    Capsule()
                        .fill(step <= current ? brand : Color.gray.opacity(0.25))
                        .frame(height: 4)
                        .animation(.easeInOut(duration: 0.3), value: current)
                }
            }
            .padding(.horizontal, 16)
            Text("الخطوة \(current) من \(total)")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding(.vertical, 10)
        .background(Color(.systemBackground))
    }
}
