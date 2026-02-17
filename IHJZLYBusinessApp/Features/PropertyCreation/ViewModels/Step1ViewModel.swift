// Features/PropertyCreation/ViewModels/Step1ViewModel.swift
import Foundation
import Combine

@MainActor
class Step1ViewModel<FormData: PropertyForm>: ObservableObject {
    @Published var form: FormData
    @Published var validationErrors: [ValidationError] = []
    @Published var states: [String] = []
    @Published var districts: [String] = []
    @Published var errorMessage: String?
    @Published var isErrorAlertPresented = false
    @Published var hasLoadedStates = false
    
    private let locationManager: LocationUseCase
    private let currentUser: User
    private var loadTask: Task<Void, Never>?
    
    init(form: FormData, locationManager: LocationUseCase, currentUser: User) {
        self.form = form
        self.locationManager = locationManager
        self.currentUser = currentUser
        loadTask = Task { await loadStates() }
        validate()
    }
    
    var title: String {
        get { form.title }
        set {
            form.title = newValue
            validate()
        }
    }
    
    var description: String {
        get { form.description }
        set {
            form.description = newValue
            validate()
        }
    }
    
    var state: String {
        get { form.location.state }
        set {
            form.location.state = newValue
            form.location.city = ""
            validate()
        }
    }
    
    var city: String {
        get { form.location.city }
        set {
            form.location.city = newValue
            validate()
        }
    }
    
    func loadStates() async {
        guard !Task.isCancelled else { return }
        do {
            let locations = try await locationManager.getAllLocations()
            let uniqueStates = Array(Set(locations.map { $0.state })).sorted()
            self.states = uniqueStates
            self.hasLoadedStates = true
        } catch {
            self.states = ["طرابلس", "بنغازي", "البيضاء"]
            self.hasLoadedStates = true
            errorMessage = "فشل تحميل المدن"
            isErrorAlertPresented = true
        }
    }
    
    func loadDistricts(for state: String) async {
        guard !Task.isCancelled else { return }
        do {
            let locations = try await locationManager.getAllLocations()
            let districtsInState = locations
                .filter { $0.state == state }
                .map { $0.city }
                .sorted()
            self.districts = districtsInState
        } catch {
            errorMessage = "فشل تحميل الأحياء"
            isErrorAlertPresented = true
        }
    }
    
    var isNextDisabled: Bool { !validationErrors.isEmpty }
    
    func validate() {
        validationErrors = []
        if form.title.isEmpty {
            validationErrors.append(ValidationError(message: "اسم العقار مطلوب"))
        }
        if form.description.isEmpty {
            validationErrors.append(ValidationError(message: "وصف العقار مطلوب"))
        }
    }
    
    deinit {
        loadTask?.cancel()
    }
}
