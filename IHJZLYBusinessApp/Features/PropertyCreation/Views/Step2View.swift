import SwiftUI
import MapKit
import WebKit

// MARK: - OpenStreetMap via Leaflet (full Libya coverage)
struct OSMMapView: UIViewRepresentable {
    @Binding var region: MKCoordinateRegion
    @Binding var selectedPin: IdentifiablePin?

    func makeCoordinator() -> Coordinator { Coordinator(self) }

    func makeUIView(context: Context) -> WKWebView {
        let config = WKWebViewConfiguration()
        config.userContentController.add(context.coordinator, name: "mapTap")
        config.userContentController.add(context.coordinator, name: "mapMove")

        let web = WKWebView(frame: .zero, configuration: config)
        web.scrollView.isScrollEnabled = false
        web.isOpaque = false
        web.backgroundColor = .clear
        web.navigationDelegate = context.coordinator
        web.loadHTMLString(Self.html(lat: region.center.latitude,
                                     lon: region.center.longitude,
                                     zoom: 6), baseURL: URL(string: "https://www.openstreetmap.org"))
        return web
    }

    func updateUIView(_ web: WKWebView, context: Context) {
        if let pin = selectedPin {
            let js = "setPin(\(pin.coordinate.latitude), \(pin.coordinate.longitude));"
            web.evaluateJavaScript(js, completionHandler: nil)
        } else {
            web.evaluateJavaScript("removePin();", completionHandler: nil)
        }
    }

    // MARK: Coordinator
    class Coordinator: NSObject, WKScriptMessageHandler, WKNavigationDelegate {
        var parent: OSMMapView
        init(_ parent: OSMMapView) { self.parent = parent }

        func userContentController(_ controller: WKUserContentController,
                                   didReceive message: WKScriptMessage) {
            guard let body = message.body as? [String: Double] else { return }
            let lat = body["lat"] ?? 0
            let lon = body["lon"] ?? 0
            if message.name == "mapTap" {
                parent.selectedPin = IdentifiablePin(
                    coordinate: CLLocationCoordinate2D(latitude: lat, longitude: lon)
                )
            } else if message.name == "mapMove" {
                let latDelta = body["latDelta"] ?? 1
                let lonDelta = body["lonDelta"] ?? 1
                parent.region = MKCoordinateRegion(
                    center: CLLocationCoordinate2D(latitude: lat, longitude: lon),
                    span: MKCoordinateSpan(latitudeDelta: latDelta, longitudeDelta: lonDelta)
                )
            }
        }
    }

    // MARK: Leaflet HTML
    static func html(lat: Double, lon: Double, zoom: Int) -> String {
        """
        <!DOCTYPE html>
        <html>
        <head>
        <meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no">
        <link rel="stylesheet" href="https://unpkg.com/leaflet@1.9.4/dist/leaflet.css"/>
        <script src="https://unpkg.com/leaflet@1.9.4/dist/leaflet.js"></script>
        <style>
          * { margin:0; padding:0; box-sizing:border-box; }
          html, body, #map { width:100%; height:100%; }
        </style>
        </head>
        <body>
        <div id="map"></div>
        <script>
          var map = L.map('map', {
            center: [\(lat), \(lon)],
            zoom: \(zoom),
            zoomControl: true,
            attributionControl: false
          });

          L.tileLayer('https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png', {
            maxZoom: 19,
            minZoom: 1
          }).addTo(map);

          var marker = null;

          function setPin(lat, lon) {
            if (marker) { map.removeLayer(marker); }
            marker = L.marker([lat, lon]).addTo(map);
          }

          function removePin() {
            if (marker) { map.removeLayer(marker); marker = null; }
          }

          map.on('click', function(e) {
            window.webkit.messageHandlers.mapTap.postMessage({
              lat: e.latlng.lat, lon: e.latlng.lng
            });
            setPin(e.latlng.lat, e.latlng.lng);
          });

          map.on('moveend', function() {
            var c = map.getCenter();
            var b = map.getBounds();
            window.webkit.messageHandlers.mapMove.postMessage({
              lat: c.lat, lon: c.lng,
              latDelta: b.getNorth() - b.getSouth(),
              lonDelta: b.getEast()  - b.getWest()
            });
          });
        </script>
        </body>
        </html>
        """
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

                // Fully interactive OpenStreetMap
                OSMMapView(
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
