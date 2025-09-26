//
//  EditSpotView.swift
//  Spot Saver
//
//  Created by Rishu Bajpai on 26/09/25.
//

import SwiftUI
import PhotosUI
import CoreLocation

struct EditSpotView: View {
    @Bindable var spot: Spot
    @Environment(\.dismiss) private var dismiss
    
    @State private var location: CLLocationCoordinate2D?

    var body: some View {
        NavigationStack {
            Form {
                Section("Details") {
                    TextField("Name", text: $spot.name)
                    TextField("Notes", text: $spot.notes, axis: .vertical)
                    
                    Picker("Category", selection: $spot.category) {
                        Text("Favorites").tag("Favorites")
                        Text("Food").tag("Food")
                        Text("Parks").tag("Parks")
                    }
                }
                
                Section("Photo") {
                    PhotoPickerView(selectedPhotoData: $spot.photo)
                }

                Section("Location") {
                    LocationPickerView(location: $location)
                }
            }
            .navigationTitle("Edit Spot")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        if let location {
                            spot.latitude = location.latitude
                            spot.longitude = location.longitude
                        }
                        dismiss()
                    }
                }
            }
            .onAppear {
                location = spot.coordinate
            }
        }
    }
}
