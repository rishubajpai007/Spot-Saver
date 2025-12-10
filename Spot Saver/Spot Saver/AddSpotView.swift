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
                Section("Details") {
                    TextField("Name", text: $viewModel.name)
                    TextField("Notes", text: $viewModel.notes, axis: .vertical)
                    
                    Picker("Category", selection: $viewModel.category) {
                        Text("Food").tag("Food")
                        Text("Place").tag("Place")
                        Text("Date").tag("Date")
                        Text("Parks").tag("Parks")
                    }
                }
                
                Section("Photo") {
                    PhotoPickerView(selectedPhotoData: $viewModel.selectedPhotoData)
                }
                
                Section("Location") {
                    LocationPickerView(location: $viewModel.location)
                }
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
            onSave(newSpot)
            dismiss()
        }
    }
}
