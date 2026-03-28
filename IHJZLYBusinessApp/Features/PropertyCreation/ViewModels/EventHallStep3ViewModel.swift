import Foundation
import Combine

@MainActor
final class EventHallStep3ViewModel<FormData: PropertyForm>: ObservableObject {
    @Published var form: FormData
    @Published var maxGuests: Int = 1
    @Published var selectedFeatures: Set<Feature> = []
    @Published var validationErrors: [ValidationError] = []

    init(form: FormData) {
        self.form = form
        self.maxGuests = form.details.maxGuests > 0 ? form.details.maxGuests : 1
        self.selectedFeatures = Set(form.features)
        validate()
    }

    var isNextDisabled: Bool { !validationErrors.isEmpty }

    func toggleFeature(_ feature: Feature) {
        if selectedFeatures.contains(feature) {
            selectedFeatures.remove(feature)
        } else {
            selectedFeatures.insert(feature)
        }
    }

    func validate() {
        validationErrors = []
        if maxGuests < 1 {
            validationErrors.append(ValidationError(message: "يجب أن يكون عدد الضيوف 1 على الأقل"))
        }
    }

    func saveAndProceed() {
        form.details.maxGuests = maxGuests
        form.features = Array(selectedFeatures)
        validate()
    }
}
