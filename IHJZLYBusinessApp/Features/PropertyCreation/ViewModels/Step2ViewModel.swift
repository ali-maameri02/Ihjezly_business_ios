// Features/PropertyCreation/ViewModels/Step2ViewModel.swift
import Foundation
import Combine
import MapKit

@MainActor
final class Step2ViewModel<FormData: PropertyForm>: ObservableObject {
    @Published var form: FormData
    @Published var region: MKCoordinateRegion
    @Published var selectedPin: IdentifiablePin?

    init(form: FormData) {
        self.form = form
        let coordinate = CLLocationCoordinate2D(
            latitude: form.location.latitude != 0 ? form.location.latitude : 32.8872,
            longitude: form.location.longitude != 0 ? form.location.longitude : 13.1913
        )
        self.region = MKCoordinateRegion(
            center: coordinate,
            span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
        )
        if form.location.latitude != 0 && form.location.longitude != 0 {
            self.selectedPin = IdentifiablePin(coordinate: coordinate)
        }
    }

    // Convert a tap point (CGPoint) inside a view of given size to a map coordinate
    func coordinate(for point: CGPoint, in size: CGSize) -> CLLocationCoordinate2D {
        let latDelta = region.span.latitudeDelta
        let lonDelta = region.span.longitudeDelta

        let lat = region.center.latitude  + latDelta  * (0.5 - Double(point.y / size.height))
        let lon = region.center.longitude + lonDelta  * (Double(point.x / size.width) - 0.5)

        return CLLocationCoordinate2D(latitude: lat, longitude: lon)
    }

    func placePin(at coordinate: CLLocationCoordinate2D) {
        selectedPin = IdentifiablePin(coordinate: coordinate)
    }

    func getSelectedLocation() -> LocationForm {
        var location = form.location
        if let pin = selectedPin {
            location.latitude  = pin.coordinate.latitude
            location.longitude = pin.coordinate.longitude
        }
        return location
    }
}

struct IdentifiablePin: Identifiable {
    let id = UUID()
    let coordinate: CLLocationCoordinate2D
}
