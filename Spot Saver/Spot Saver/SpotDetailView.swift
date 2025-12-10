//
//  SpotDetailView.swift
//  Spot Saver
//
//  Created by Rishu Bajpai on 25/09/25.
//

import SwiftUI
import MapKit
import SwiftData

struct SpotDetailView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    let spot: Spot
    
    @State private var isEditing = false
    @State private var cameraPosition: MapCameraPosition
    
    init(spot: Spot) {
        self.spot = spot
        _cameraPosition = State(initialValue: .region(MKCoordinateRegion(
            center: spot.coordinate,
            latitudinalMeters: 500,
            longitudinalMeters: 500
        )))
    }
    
    private var shareableContent: String {
        let name = spot.name
        let notes = spot.notes.isEmpty ? "" : "\n\nNotes: \(spot.notes)"
        let mapLink = "http://maps.apple.com/?ll=\(spot.latitude),\(spot.longitude)"
        
        return """
        Check out this spot: \(name)!
        \(notes)
        
        Find it on a map: \(mapLink)
        """
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                // MARK: - Hero Image
                if let imageData = spot.photo, let uiImage = UIImage(data: imageData) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFill()
                        .frame(height: 300)
                        .clipped()
                } else {
                    // Fallback gradient
                    LinearGradient(colors: [.blue.opacity(0.3), .purple.opacity(0.3)], startPoint: .topLeading, endPoint: .bottomTrailing)
                        .frame(height: 200)
                        .overlay {
                            Image(systemName: "mappin.and.ellipse")
                                .font(.system(size: 60))
                                .foregroundStyle(.secondary)
                        }
                }
                
                VStack(alignment: .leading, spacing: 24) {
                    // MARK: - Header
                    VStack(alignment: .leading, spacing: 12) {
                        Text(spot.name)
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundStyle(.primary)
                        
                        HStack {
                            InfoTagView(text: spot.category, iconName: "tag.fill")
                            InfoTagView(text: spot.dateAdded.formatted(date: .abbreviated, time: .omitted), iconName: "calendar")
                        }
                    }
                    
                    // MARK: - Notes Section
                    if !spot.notes.isEmpty {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Notes")
                                .font(.title2)
                                .fontWeight(.semibold)
                                .foregroundStyle(.primary)
                            Text(spot.notes)
                                .foregroundStyle(.secondary)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                    }
                    
                    // MARK: - Location Section
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Location")
                            .font(.title2)
                            .fontWeight(.semibold)
                            .foregroundStyle(.primary)
                        
                        Map(position: $cameraPosition) {
                            Marker(spot.name, coordinate: spot.coordinate)
                        }
                        .frame(height: 250)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                        .shadow(radius: 2)
                        
                        // MARK: - Get Directions Button (FIXED)
                        Button(action: openDirections) {
                            HStack {
                                Image(systemName: "car.fill")
                                Text("Get Directions")
                            }
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 4)
                        }
                        .buttonStyle(.borderedProminent)
                        .tint(.blue)
                    }
                }
                .padding(24)
            }
        }
        .background(Color(uiColor: .systemBackground))
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItemGroup(placement: .topBarTrailing) {
                ShareLink(item: shareableContent) {
                    Label("Share", systemImage: "square.and.arrow.up")
                }
                
                Button {
                    spot.isFavorite.toggle()
                } label: {
                    Label("Favorite", systemImage: spot.isFavorite ? "star.fill" : "star")
                }
                .tint(.yellow)
                
                Menu {
                    Button("Edit", systemImage: "pencil") {
                        isEditing = true
                    }
                    Button("Delete", systemImage: "trash", role: .destructive) {
                        deleteSpot()
                    }
                } label: {
                    Image(systemName: "ellipsis.circle")
                }
            }
        }
        .sheet(isPresented: $isEditing) {
            EditSpotView(spot: spot)
        }
        .onChange(of: spot.coordinate) {
            cameraPosition = .region(MKCoordinateRegion(
                center: spot.coordinate,
                latitudinalMeters: 500,
                longitudinalMeters: 500
            ))
        }
    }
    
    // MARK: - Helper Functions
    private func deleteSpot() {
        modelContext.delete(spot)
        dismiss()
    }
    
    private func openDirections() {
        let placemark = MKPlacemark(coordinate: spot.coordinate)
        let mapItem = MKMapItem(placemark: placemark)
        mapItem.name = spot.name
        mapItem.openInMaps(launchOptions: [
            MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving
        ])
    }
}

// MARK: - Extensions & Subviews

extension CLLocationCoordinate2D: Equatable {
    public static func == (lhs: CLLocationCoordinate2D, rhs: CLLocationCoordinate2D) -> Bool {
        lhs.latitude == rhs.latitude && lhs.longitude == rhs.longitude
    }
}

struct InfoTagView: View {
    let text: String
    let iconName: String
    
    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: iconName)
            Text(text)
        }
        .font(.caption)
        .fontWeight(.medium)
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .background(Color.blue.opacity(0.1))
        .foregroundStyle(Color.blue)
        .clipShape(Capsule())
    }
}
