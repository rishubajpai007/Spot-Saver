// LocationPickerView.swift
import SwiftUI
import MapKit

struct LocationPickerView: View {
    @Binding var location: CLLocationCoordinate2D?
    
    // MARK: - Internal State
    @State private var position: MapCameraPosition = .automatic
    @State private var showSearchSheet = false // Controls the sheet
    @State private var searchResults: [SearchResult] = [] // Hold results from the search sheet
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            
            // MARK: - 1. Header & Search Button
            HStack {
                if let location {
                    VStack(alignment: .leading) {
                        Text("Selected Location")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        Text("\(location.latitude, specifier: "%.4f"), \(location.longitude, specifier: "%.4f")")
                            .font(.subheadline)
                            .monospacedDigit()
                            .fontWeight(.medium)
                    }
                } else {
                    Text("Tap map to select location")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                
                Spacer()
                
                Button(action: { showSearchSheet = true }) {
                    Image(systemName: "magnifyingglass")
                        .font(.headline)
                        .foregroundStyle(.white)
                        .padding(8)
                        .background(Color.blue)
                        .clipShape(Circle())
                }
            }
            
            // MARK: - 2. Interactive Map
            MapReader { reader in
                Map(position: $position) {
                    if let location {
                        Marker("Selected", coordinate: location)
                    }
                }
                .onTapGesture { screenCoord in
                    if let coordinate = reader.convert(screenCoord, from: .local) {
                        updateLocation(to: coordinate)
                    }
                }
            }
            .frame(height: 300)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.secondary.opacity(0.3), lineWidth: 1)
            )
        }
        .onAppear {
            if let location {
                position = .region(MKCoordinateRegion(
                    center: location,
                    latitudinalMeters: 1000,
                    longitudinalMeters: 1000
                ))
            }
        }
        .onChange(of: searchResults) {
            if let first = searchResults.first {
                updateLocation(to: first.location)
                // Dismiss the sheet after selecting
                showSearchSheet = false
            }
        }
        // MARK: - 3. The Search Sheet
        .sheet(isPresented: $showSearchSheet) {
            LocationSearchView(searchResults: $searchResults)
                .presentationDetents([.medium, .large])
                .presentationDragIndicator(.visible)
        }
    }
    
    private func updateLocation(to coordinate: CLLocationCoordinate2D) {
        location = coordinate
        withAnimation {
            position = .region(MKCoordinateRegion(
                center: coordinate,
                latitudinalMeters: 1000,
                longitudinalMeters: 1000
            ))
        }
    }
}
