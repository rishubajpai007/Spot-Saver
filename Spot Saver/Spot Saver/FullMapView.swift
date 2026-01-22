//
//  FullMapView.swift
//  Spot Saver
//
//  Created by Rishu Bajpai on 29/09/25.
//

import SwiftUI
import MapKit
import SwiftData

struct FullMapView: View {
    @Query(Self.allSpotsDescriptor) private var spots: [Spot]
    
    // MARK: - State
    @State private var selectedSpot: Spot?
    @State private var position: MapCameraPosition = .userLocation(fallback: .automatic)
    
    private func fitAllSpots() {
        guard !spots.isEmpty else { return }
        // Build a region that fits all coordinates with a small padding span
        let lats = spots.map { $0.coordinate.latitude }
        let lons = spots.map { $0.coordinate.longitude }
        guard let minLat = lats.min(), let maxLat = lats.max(), let minLon = lons.min(), let maxLon = lons.max() else { return }
        // Add a small padding (~10%)
        let latDelta = max((maxLat - minLat) * 1.1, 0.005)
        let lonDelta = max((maxLon - minLon) * 1.1, 0.005)
        let center = CLLocationCoordinate2D(latitude: (minLat + maxLat) / 2.0, longitude: (minLon + maxLon) / 2.0)
        let span = MKCoordinateSpan(latitudeDelta: latDelta, longitudeDelta: lonDelta)
        let region = MKCoordinateRegion(center: center, span: span)
        position = .region(region)
    }
    
    var body: some View {
        Map(position: $position, selection: $selectedSpot) {
            
            // 1. Show User Location
            UserAnnotation()
            
            // 2. Show Dynamic Category Markers
            ForEach(spots) { spot in
                Marker(spot.name, monogram: Text(spot.categoryIcon), coordinate: spot.coordinate)
                    .tint(spot.categoryColor)
                    .tag(spot)
            }
        }
        // 3. Map Controls
        .mapControls {
            MapUserLocationButton()
            MapCompass()
            MapScaleView()
        }
        .mapStyle(.standard(elevation: .realistic))
        .navigationTitle("All Spots Map")
        .onAppear {
            DispatchQueue.main.async {
                withAnimation(.easeInOut(duration: 0.25)) {
                    fitAllSpots()
                }
            }
        }
        .onChange(of: spots) { _ in
            DispatchQueue.main.async {
                withAnimation(.easeInOut(duration: 0.25)) {
                    fitAllSpots()
                }
            }
        }
        .sheet(item: $selectedSpot) { spot in
            NavigationStack {
                SpotDetailView(spot: spot)
            }
            .presentationDetents([.height(600), .medium, .large])
        }
    }
    
    static var allSpotsDescriptor: FetchDescriptor<Spot> {
        let sortByDate = SortDescriptor(\Spot.dateAdded, order: .reverse)
        return FetchDescriptor<Spot>(sortBy: [sortByDate])
    }
}

// MARK: - Spot Visual Helpers

extension Spot {
    var categoryIcon: String {
        switch category {
        case "Food": return "🍔"
        case "Drinks": return "☕️"
        case "Nature": return "🌲"
        case "Shopping": return "🛍️"
        case "Culture": return "🏛️"
        case "Nightlife": return "🍸"
        case "Entertainment": return "🎬"
        case "Date": return "💘"
        case "Work": return "💼"
        default: return "📍"         }
    }
    
    var categoryColor: Color {
        switch category {
        case "Food": return .orange
        case "Drinks": return .brown
        case "Nature": return .green
        case "Shopping": return .purple
        case "Culture": return .red
        case "Nightlife": return .indigo
        case "Entertainment": return .pink
        case "Date": return .red
        case "Work": return .blue
        default: return .gray
        }
    }
}
