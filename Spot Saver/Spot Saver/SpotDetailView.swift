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

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 15) {
                // MARK: - Photo Section
                if let imageData = spot.photo, let uiImage = UIImage(data: imageData) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFit()
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .shadow(radius: 5)
                }

                // MARK: - Info Section
                VStack(alignment: .leading, spacing: 8) {
                    Text(spot.name)
                        .font(.largeTitle)
                        .fontWeight(.bold)

                    HStack {
                        Image(systemName: "tag.fill")
                        Text(spot.category)
                    }
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    
                    HStack {
                        Image(systemName: "calendar")
                        Text(spot.dateAdded.formatted(date: .long, time: .shortened))
                    }
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                }
                
                Divider()

                // MARK: - Notes Section
                if !spot.notes.isEmpty {
                    VStack(alignment: .leading, spacing: 5) {
                        Text("Notes")
                            .font(.title2)
                            .fontWeight(.semibold)
                        Text(spot.notes)
                    }
                    Divider()
                }

                // MARK: - Map Section
                VStack(alignment: .leading, spacing: 5) {
                    Text("Location")
                        .font(.title2)
                        .fontWeight(.semibold)
                    
                    Map(position: $cameraPosition) {
                        Marker(spot.name, coordinate: spot.coordinate)
                    }
                    .frame(height: 250)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                }
            }
            .padding()
        }
        .navigationTitle(spot.name)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItemGroup(placement: .topBarTrailing) {
               
                Button("Edit") {
                    isEditing = true
                }
                
                Button(role: .destructive) {
                    deleteSpot()
                } label: {
                    Label("Delete", systemImage: "trash")
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
    
    private func deleteSpot() {
        modelContext.delete(spot)
        dismiss()
    }
}

extension CLLocationCoordinate2D: Equatable {
    public static func == (lhs: CLLocationCoordinate2D, rhs: CLLocationCoordinate2D) -> Bool {
        lhs.latitude == rhs.latitude && lhs.longitude == rhs.longitude
    }
}
