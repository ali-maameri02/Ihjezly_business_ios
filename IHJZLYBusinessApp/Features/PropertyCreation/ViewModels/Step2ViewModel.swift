// Features/PropertyCreation/ViewModels/Step2ViewModel.swift t
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
            latitude: form.location.latitude != 0 ? form.location.latitude : 26.3351,
            longitude: form.location.longitude != 0 ? form.location.longitude : 17.2283
        )
        self.region = MKCoordinateRegion(
            center: coordinate,
            span: MKCoordinateSpan(latitudeDelta: 15.0, longitudeDelta: 15.0)
        )
        if form.location.latitude != 0 && form.location.longitude != 0 {
            self.selectedPin = IdentifiablePin(coordinate: coordinate)
        }
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
