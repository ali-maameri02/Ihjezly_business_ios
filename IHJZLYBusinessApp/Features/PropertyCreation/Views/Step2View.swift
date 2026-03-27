import SwiftUI
import MapKit

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

                // Map with tap gesture
                ZStack {
                    Map(
                        coordinateRegion: $viewModel.region,
                        annotationItems: viewModel.selectedPin.map { [$0] } ?? []
                    ) { pin in
                        MapMarker(coordinate: pin.coordinate, tint: Color(hex: "#88417A"))
                    }

                    // Transparent overlay to capture taps
                    GeometryReader { geo in
                        Color.clear
                            .contentShape(Rectangle())
                            .onTapGesture { location in
                                let coordinate = viewModel.coordinate(
                                    for: location,
                                    in: geo.size
                                )
                                viewModel.placePin(at: coordinate)
                            }
                    }
                }
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
