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
                if let imageData = spot.photo, let uiImage = UIImage(data: imageData) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFill()
                        .frame(height: 300)
                        .clipped()
                }
                
                VStack(alignment: .leading, spacing: 20) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text(spot.name)
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundStyle(Color("PrimaryText"))
                        
                        HStack {
                            InfoTagView(text: spot.category, iconName: "tag.fill")
                            InfoTagView(text: spot.dateAdded.formatted(date: .abbreviated, time: .omitted), iconName: "calendar")
                        }
                    }
                    
                    if !spot.notes.isEmpty {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Notes")
                                .font(.title2)
                                .fontWeight(.semibold)
                                .foregroundStyle(Color("PrimaryText"))
                            Text(spot.notes)
                                .foregroundStyle(Color("SecondaryText"))
                        }
                    }
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Location")
                            .font(.title2)
                            .fontWeight(.semibold)
                            .foregroundStyle(Color("PrimaryText"))
                        
                        Map(position: $cameraPosition) {
                            Marker(spot.name, coordinate: spot.coordinate)
                        }
                        .frame(height: 250)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                }
                .padding(.horizontal,30)
            }
        }
        .background(Color("AppBackground"))
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

// This extension is needed for the .onChange modifier
extension CLLocationCoordinate2D: Equatable {
    public static func == (lhs: CLLocationCoordinate2D, rhs: CLLocationCoordinate2D) -> Bool {
        lhs.latitude == rhs.latitude && lhs.longitude == rhs.longitude
    }
}

struct InfoTagView: View {
    let text: String
    let iconName: String
    
    var body: some View {
        HStack {
            Image(systemName: iconName)
            Text(text)
        }
        .font(.caption)
        .fontWeight(.medium)
        .padding(.horizontal, 10)
        .padding(.vertical, 5)
        .background(Color.accentColor.opacity(0.1))
        .foregroundStyle(.accent)
        .clipShape(Capsule())
    }
}
