import SwiftUI
import MapKit

// MARK: - Interactive MKMapView wrapper
struct InteractiveMapView: UIViewRepresentable {
    @Binding var region: MKCoordinateRegion
    @Binding var selectedPin: IdentifiablePin?

    func makeCoordinator() -> Coordinator { Coordinator(self) }

    func makeUIView(context: Context) -> MKMapView {
        let map = MKMapView()
        map.isScrollEnabled = true
        map.isZoomEnabled = true
        map.isRotateEnabled = true
        map.isUserInteractionEnabled = true
        map.delegate = context.coordinator
        map.setRegion(region, animated: false)

        let tap = UITapGestureRecognizer(target: context.coordinator,
                                         action: #selector(Coordinator.handleTap(_:)))
        map.addGestureRecognizer(tap)
        return map
    }

    func updateUIView(_ map: MKMapView, context: Context) {
        // Sync pin annotation
        map.removeAnnotations(map.annotations)
        if let pin = selectedPin {
            let annotation = MKPointAnnotation()
            annotation.coordinate = pin.coordinate
            map.addAnnotation(annotation)
        }
    }

    class Coordinator: NSObject, MKMapViewDelegate {
        var parent: InteractiveMapView
        init(_ parent: InteractiveMapView) { self.parent = parent }

        @objc func handleTap(_ gesture: UITapGestureRecognizer) {
            guard let map = gesture.view as? MKMapView else { return }
            let point = gesture.location(in: map)
            let coordinate = map.convert(point, toCoordinateFrom: map)
            parent.selectedPin = IdentifiablePin(coordinate: coordinate)
        }

        func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
            let view = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: "pin")
            view.markerTintColor = UIColor(red: 0x88/255, green: 0x41/255, blue: 0x7A/255, alpha: 1)
            return view
        }

        func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
            parent.region = mapView.region
        }
    }
}

// MARK: - Step2View
struct Step2View<FormData: PropertyForm>: View {
    @StateObject private var viewModel: Step2ViewModel<FormData>
    let onBack: () -> Void
    let onNext: (LocationForm) -> Void

    init(form: FormData, onBack: @escaping () -> Void, onNext: @escaping (LocationForm) -> Void) {
        _viewModel = StateObject(wrappedValue: Step2ViewModel(form: form))
        self.onBack = onBack
        self.onNext = onNext
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Header
                VStack(spacing: 0) {
                    HStack {
                        BackButton(action: onBack)
                        Spacer()
                        Text("تحديد الموقع على الخريطة")
                            .font(.title2)
                            .fontWeight(.semibold)
                        Spacer()
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 12)

                    Divider()
                        .background(Color(hex: "#88417A"))
                        .frame(height: 2)
                        .padding(.horizontal, 16)
                        .padding(.top, 4)
                }
                .background(Color.white)
                .shadow(radius: 1)

                // Hint
                Text("اضغط على الخريطة لتحديد موقع العقار")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .padding(.vertical, 8)

                // Fully interactive map
                InteractiveMapView(
                    region: $viewModel.region,
                    selectedPin: $viewModel.selectedPin
                )
                .frame(maxHeight: .infinity)

                // Selected coordinates display
                if let pin = viewModel.selectedPin {
                    HStack {
                        Image(systemName: "mappin.circle.fill")
                            .foregroundColor(Color(hex: "#88417A"))
                        Text(String(format: "%.5f, %.5f",
                                    pin.coordinate.latitude,
                                    pin.coordinate.longitude))
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .padding(.vertical, 8)
                }

                NextButton(
                    action: { onNext(viewModel.getSelectedLocation()) },
                    isDisabled: viewModel.selectedPin == nil
                )
            }
            .background(Color.white)
            .navigationBarHidden(true)
        }
    }
}
