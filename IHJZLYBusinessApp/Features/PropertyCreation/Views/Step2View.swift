import SwiftUI
import MapKit

struct Step2View<FormData: PropertyForm>: View {
    @StateObject private var viewModel: Step2ViewModel<FormData>
    let onNext: (LocationForm) -> Void
    
    init(form: FormData, onNext: @escaping (LocationForm) -> Void) {
        _viewModel = StateObject(wrappedValue: Step2ViewModel(form: form))
        self.onNext = onNext
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Header
                VStack(spacing: 0) {
                    HStack {
                        BackButton(action: {})
                        Spacer()
                        Text("الخريطة على الموقع")
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
                
                // Map (reuse existing implementation)
                Map(coordinateRegion: $viewModel.region, annotationItems: viewModel.selectedPin.map { [$0] } ?? []) { _ in
                    MapMarker(coordinate: viewModel.selectedPin?.coordinate ?? CLLocationCoordinate2D(), tint: Color(hex: "#88417A"))
                }
                .frame(height: 400)
                
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
