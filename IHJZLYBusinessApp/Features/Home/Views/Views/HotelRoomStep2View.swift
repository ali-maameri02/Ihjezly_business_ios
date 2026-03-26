// Features/HotelRoom/Views/HotelRoomStep2View.swift

import SwiftUI
import MapKit
import CoreLocation

struct HotelRoomStep2View: View {
    @StateObject private var viewModel: HotelRoomStep2ViewModel
    let onBack: () -> Void
    let onNext: (LocationForm) -> Void

    init(
        form: HotelRoomForm,
        onBack: @escaping () -> Void,
        onNext: @escaping (LocationForm) -> Void
    ) {
        _viewModel = StateObject(wrappedValue: HotelRoomStep2ViewModel(form: form))
        self.onBack = onBack
        self.onNext = onNext
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // FIXED HEADER
                VStack(spacing: 0) {
                    HStack {
                        BackButton(action: onBack)
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
                
                // SCROLLABLE CONTENT
                ScrollView {
                    VStack(spacing: 16) {
                        // "Go back to current location" button
                        Button(action: {
                            viewModel.getCurrentLocation()
                        }) {
                            HStack(spacing: 8) {
                                Image(systemName: "location.fill")
                                    .font(.title3)
                                Text("الرجوع إلى موقعي الحالي")
                                    .font(.headline)
                            }
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                        }
                        .frame(height: 52)
                        .background(Color(hex: "#88417A"))
                        .cornerRadius(12)
                        .padding(.horizontal, 16)
                        
                        // Map
                        Map(
                            coordinateRegion: $viewModel.region,
                            interactionModes: .all,
                            showsUserLocation: false,
                            annotationItems: viewModel.selectedPin.map { [$0] } ?? []
                        ) { pin in
                            MapMarker(coordinate: pin.coordinate, tint: Color(red: 136/255, green: 65/255, blue: 122/255))
                        }
                        .mapStyle(viewModel.isSatellite ? .imagery : .standard)
                        .frame(height: 400)
                        .edgesIgnoringSafeArea(.bottom)
                        .onTapGesture { location in
                            let mapView = MKMapView()
                            mapView.region = viewModel.region
                            let coordinate = mapView.convert(location, toCoordinateFrom: mapView)
                            viewModel.setLocation(coordinate)
                        }
                        
                        // Satellite toggle
                        Toggle("وضع الأقمار", isOn: $viewModel.isSatellite)
                            .toggleStyle(SwitchToggleStyle(tint: Color(red: 136/255, green: 65/255, blue: 122/255)))
                            .padding(.horizontal, 16)
                            .padding(.top, 16)
                    }
                }
                
                // FIXED NEXT BUTTON
                NextButton(
                    action: { onNext(viewModel.getSelectedLocation()) },
                    isDisabled: viewModel.selectedPin == nil
                )
            }
            .background(Color.white)
            .navigationBarHidden(true)
            .alert("خطأ", isPresented: $viewModel.isErrorAlertPresented) {
                Button("موافق") {
                    viewModel.isErrorAlertPresented = false
                }
            } message: {
                Text(viewModel.errorMessage ?? "")
            }
        }
    }
}
