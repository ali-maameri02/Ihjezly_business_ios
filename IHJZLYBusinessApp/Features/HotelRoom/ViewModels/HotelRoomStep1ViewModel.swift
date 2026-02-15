// Features/HotelRoom/ViewModels/HotelRoomStep1ViewModel.swift

import Foundation
import Combine

@MainActor
final class HotelRoomStep1ViewModel: ObservableObject {
    @Published var validationErrors: [ValidationError] = []

    @Published var form: HotelRoomForm = .init()
    @Published var states: [String] = []
    @Published var districts: [String] = []
    @Published var errorMessage: String?
    @Published var isErrorAlertPresented = false
    @Published var hasLoadedStates = false
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
               form.location.city = "" // Reset district when state changes
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
       
    private let locationManager: LocationUseCase
    private let currentUser: User
    private var loadTask: Task<Void, Never>?

    init(locationManager: LocationUseCase, currentUser: User) {
           self.locationManager = locationManager
           self.currentUser = currentUser
           loadTask = Task { await loadStates() }
           validate() // Initial validation
       }

    func loadStates() async {
        guard !Task.isCancelled else { return }
        do {
            let locations = try await locationManager.getAllLocations()
            let uniqueStates = Array(Set(locations.map { $0.state })).sorted()
            self.states = uniqueStates
            self.hasLoadedStates = true
        } catch {
            print("❌ loadStates error: \(error)")
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
            print("❌ loadDistricts error: \(error)")
            errorMessage = "فشل تحميل الأحياء"
            isErrorAlertPresented = true
        }
    }

    var isNextDisabled: Bool {
            !validationErrors.isEmpty
        }
    
    func validate() {
            validationErrors = ValidationManager.shared.validateStep1(form: form)
        }

    // In HotelRoomStep1ViewModel.swift
    var onStep1Completed: ((HotelRoomForm) -> Void)?

    func goToNext() {
            validate()
            if validationErrors.isEmpty {
                onStep1Completed?(form)
            }
        }

    deinit {
        loadTask?.cancel()
    }
}
