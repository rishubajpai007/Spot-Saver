//
//  LocationPickerView.swift
//  Spot Saver
//
//  Created by Rishu Bajpai on 25/09/25.
//

// LocationPickerView.swift
import SwiftUI
import MapKit

struct LocationPickerView: View {
    @Binding var location: CLLocationCoordinate2D?
    @State private var position: MapCameraPosition = .automatic

    var body: some View {
        VStack {
            if let location {
                Text("Location Selected: \(location.latitude, specifier: "%.4f"), \(location.longitude, specifier: "%.4f")")
                    .padding(.top)
            } else {
                Text("Tap on the map to select a location")
                    .padding(.top)
            }

            MapReader { reader in
                Map(position: $position) {
                    if let location {
                        Marker("New Spot", coordinate: location)
                    }
                }
                .onTapGesture { screenCoord in
                    // Convert screen tap to map coordinate
                    location = reader.convert(screenCoord, from: .local)
                }
            }
            .frame(height: 300)
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
    }
}
