//
//  AddSpotView.swift
//  Spot Saver
//
//  Created by Rishu Bajpai on 25/09/25.
//
import SwiftUI
import PhotosUI
import SwiftData

struct AddSpotView: View {
    var onSave: (Spot) -> Void
    
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel = AddSpotViewModel()
    @StateObject private var locationManager = LocationManager()

    var body: some View {
        NavigationStack {
            Form {
                TextField("Name", text: $viewModel.name)
                TextField("Notes", text: $viewModel.notes, axis: .vertical)
                
                Picker("Category", selection: $viewModel.category) {
                    Text("Favorites").tag("Favorites")
                    Text("Food").tag("Food")
                    Text("Parks").tag("Parks")
                }
                
                PhotoPickerView(selectedPhotoData: $viewModel.selectedPhotoData)
                LocationPickerView(location: $viewModel.location)
            }
            .navigationTitle("New Spot")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save", action: saveSpot)
                        .disabled(!viewModel.isFormValid)
                }
            }
            .onAppear(perform: {
                locationManager.checkLocationAuthorization()
            })
            .onReceive(locationManager.$currentLocation) { location in
                if let location, viewModel.location == nil {
                    viewModel.location = location.coordinate
                }
            }
        }
    }
    
    private func saveSpot() {
        if let newSpot = viewModel.createSpot() {
            // Pass the newly created spot back to the parent view.
            onSave(newSpot)
            dismiss()
        }
    }
}
