//
//  AddSpotView.swift
//  Spot Saver
//
//  Created by Rishu Bajpai on 25/09/25.
//

import SwiftUI
import CoreLocation
import Combine
import PhotosUI

struct AddSpotView: View {
    var onSave: (Spot) -> Void
    
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel = AddSpotViewModel()
    @StateObject private var locationManager = LocationManager()

    var body: some View {
        NavigationStack {
            Form {
                // MARK: - Details Section
                Section("Details") {
                    TextField("Name", text: $viewModel.name)
                    TextField("Notes", text: $viewModel.notes, axis: .vertical)
                    
                    Picker("Category", selection: $viewModel.category) {
                        Text("Food 🍔").tag("Food")
                        Text("Coffee & Drinks ☕️").tag("Drinks")
                        Text("Nature & Parks 🌲").tag("Nature")
                        Text("Shopping 🛍️").tag("Shopping")
                        Text("Culture & Art 🏛️").tag("Culture")
                        Text("Nightlife 🍸").tag("Nightlife")
                        Text("Entertainment 🎬").tag("Entertainment")
                        Text("Date Spot 💘").tag("Date")
                        Text("Work & Study 💼").tag("Work")
                        Text("Other 📍").tag("Other")
                    }
                }
                
                // MARK: - Photo Section
                Section("Photo") {
                    PhotoPickerView(selectedPhotoData: $viewModel.selectedPhotoData)
                }
                
                // MARK: - Location Section
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
            .onAppear {
                locationManager.checkLocationAuthorization()
            }
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

