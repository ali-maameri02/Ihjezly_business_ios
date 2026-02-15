// Features/HotelRoom/ViewModels/HotelRoomStep2ViewModel.swift

import SwiftUI
import Foundation
import MapKit
import Combine
import CoreLocation

@MainActor
final class HotelRoomStep2ViewModel: NSObject, ObservableObject, CLLocationManagerDelegate {
    @Published var validationErrors: [ValidationError] = []

    @Published var region: MKCoordinateRegion
    @Published var selectedPin: MapPin?
    @Published var isSatellite: Bool = false
    @Published var errorMessage: String?
    @Published var isErrorAlertPresented = false

    private let initialLocation: LocationForm
    private let locationManager = CLLocationManager()

    override init() {
        fatalError("init() not supported")
    }

    init(form: HotelRoomForm) {
        self.initialLocation = form.location
        
        let libyaCenter = CLLocationCoordinate2D(latitude: 29.5, longitude: 17.5)
        self.region = MKCoordinateRegion(
            center: libyaCenter,
            span: MKCoordinateSpan(latitudeDelta: 10.0, longitudeDelta: 15.0)
        )
        
        if form.location.latitude != 0 && form.location.longitude != 0 {
            self.selectedPin = MapPin(coordinate: CLLocationCoordinate2D(
                latitude: form.location.latitude,
                longitude: form.location.longitude
            ))
        }
        
        super.init()
        
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
    }
    
    func setLocation(_ coordinate: CLLocationCoordinate2D) {
        self.selectedPin = MapPin(coordinate: coordinate)
        withAnimation {
            region = MKCoordinateRegion(
                center: coordinate,
                span: MKCoordinateSpan(latitudeDelta: 0.02, longitudeDelta: 0.02)
            )
        }
    }
    
    func getSelectedLocation() -> LocationForm {
        var updated = initialLocation
        if let pin = selectedPin {
            updated.latitude = pin.coordinate.latitude
            updated.longitude = pin.coordinate.longitude
        }
        return updated
    }
    
    func getCurrentLocation() {
        switch locationManager.authorizationStatus {
        case .authorizedWhenInUse, .authorizedAlways:
            locationManager.startUpdatingLocation()
        case .denied, .restricted:
            errorMessage = "يرجى تمكين خدمات الموقع في الإعدادات"
            isErrorAlertPresented = true
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        @unknown default:
            break
        }
    }
    
    // MARK: - CLLocationManagerDelegate
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        let coordinate = location.coordinate
        setLocation(coordinate)
        locationManager.stopUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        errorMessage = "فشل تحديد الموقع: \(error.localizedDescription)"
        isErrorAlertPresented = true
        locationManager.stopUpdatingLocation()
    }
}



struct MapPin: Identifiable {
    let id = UUID()
    let coordinate: CLLocationCoordinate2D
}
