//
//  EditSpotView.swift
//  Spot Saver
//

import SwiftUI
import PhotosUI
import CoreLocation

struct EditSpotView: View {
    @Bindable var spot: Spot
    @Environment(\.dismiss) private var dismiss
    
    @State private var location: CLLocationCoordinate2D?
    @State private var showValidationError = false
    @State private var validationMessage = ""
    @State private var attemptedSave = false

    var body: some View {
        NavigationStack {
            Form {
                // MARK: - Details
                Section {
                    VStack(alignment: .leading, spacing: 4) {
                        TextField("Name", text: $spot.name)
                            .submitLabel(.next)
                        
                        if attemptedSave && spot.name.trimmingCharacters(in: .whitespaces).isEmpty {
                            Text("A name is required to save this spot.")
                                .font(.caption)
                                .foregroundColor(.red)
                        }
                    }
                    
                    TextField("Notes (Optional)", text: $spot.notes, axis: .vertical)
                        .lineLimit(3...10)
                    
                    Picker("Category", selection: $spot.category) {
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
                } header: {
                    Text("Details")
                }

                // MARK: - Photos
                Section {
                    PhotoPickerView(selectedPhotosData: $spot.photos)
                    
                    if attemptedSave && spot.photos.isEmpty {
                        Text("At least one photo is recommended.")
                            .font(.caption)
                            .foregroundColor(.orange)
                    }
                } header: {
                    Text("Photos")
                }

                // MARK: - Location
                Section {
                    LocationPickerView(location: $location)
                    
                    if attemptedSave && location == nil {
                        HStack {
                            Image(systemName: "exclamationmark.triangle.fill")
                            Text("Location coordinates are missing.")
                        }
                        .font(.caption)
                        .foregroundColor(.red)
                    }
                } header: {
                    Text("Location")
                } footer: {
                    if location == nil {
                        Text("Please select or wait for location.")
                            .foregroundColor(.red)
                    } else {
                        Text("Coordinates captured successfully.")
                            .foregroundColor(.green)
                    }
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
                        validateAndSave()
                    }
                    .fontWeight(.bold)
                }
            }
            .alert("Incomplete Information", isPresented: $showValidationError) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(validationMessage)
            }
            .onAppear {
                location = spot.coordinate
            }
        }
    }
    
    private func validateAndSave() {
        attemptedSave = true
        
        if spot.name.trimmingCharacters(in: .whitespaces).isEmpty {
            validationMessage = "Please provide a name for your spot."
            showValidationError = true
            return
        }
        
        if location == nil {
            validationMessage = "Location is missing. Please select a location."
            showValidationError = true
            return
        }
        
        if let location {
            spot.latitude = location.latitude
            spot.longitude = location.longitude
        }
        
        dismiss()
    }
}
