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
    @FocusState private var focusedField: Field?
    private enum Field { case name, notes }
    
    @State private var showValidationError = false
    @State private var validationMessage = ""
    @State private var attemptedSave = false

    var body: some View {
        NavigationStack {
            Form {
                Section {
                  VStack(alignment: .leading, spacing: 4) {
                        TextField("Name", text: $viewModel.name)
                            .focused($focusedField, equals: .name)
                            .submitLabel(.next)
                            .onSubmit { focusedField = .notes }
                        
                        if attemptedSave && viewModel.name.trimmingCharacters(in: .whitespaces).isEmpty {
                            Text("A name is required to save this spot.")
                                .font(.caption)
                                .foregroundColor(.red)
                        }
                    }
                    VStack(alignment: .leading, spacing: 4) {
                        TextField("Notes(Optional)", text: $viewModel.notes, axis: .vertical)
                            .focused($focusedField, equals: .notes)
                            .onChange(of: viewModel.notes) { oldValue, newValue in
                                if newValue.allSatisfy({ $0.isWhitespace || $0.isNewline }) {
                                    viewModel.notes = ""
                                }
                            }
                            .onSubmit {
                                viewModel.notes = viewModel.notes.trimmingCharacters(in: .whitespacesAndNewlines)
                                focusedField = nil
                            }
                    }
                    
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
                } header: {
                    Text("Details")
                } footer: {
                    Text("Give your spot a recognizable name.")
                }
                
                // MARK: - Photo Section
                Section {
                    PhotoPickerView(selectedPhotosData: $viewModel.selectedPhotosData)
                    
                    if attemptedSave && viewModel.selectedPhotosData.isEmpty {
                        Text("Adding at least one photo helps you identify the spot later.")
                            .font(.caption)
                            .foregroundColor(.orange)
                    }
                } header: {
                    Text("Photos")
                }
                
                // MARK: - Location Section
                Section {
                    LocationPickerView(location: $viewModel.location)
                    
                    if attemptedSave && viewModel.location == nil {
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
                    if viewModel.location == nil {
                        Text("Ensure Location Services are enabled to tag this spot.")
                            .foregroundColor(.red)
                    } else {
                        Text("Coordinates captured successfully.")
                            .foregroundColor(.green)
                    }
                }
            }
            .navigationTitle("New Spot")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItemGroup(placement: .keyboard) {
                    Spacer()
                    Button("Done") {
                        viewModel.notes = viewModel.notes.trimmingCharacters(in: .whitespacesAndNewlines)
                        focusedField = nil
                    }
                }
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        validateAndSave()
                    }
                    .fontWeight(.bold)
                }
            }
            .alert("Incomplete Information", isPresented: $showValidationError) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(validationMessage)
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
    
    private func validateAndSave() {
        attemptedSave = true
        
        if viewModel.name.trimmingCharacters(in: .whitespaces).isEmpty {
            validationMessage = "Please provide a name for your spot."
            showValidationError = true
            return
        }
        
        if viewModel.location == nil {
            validationMessage = "We couldn't determine the location. Please wait for the GPS signal or pick a location manually."
            showValidationError = true
            return
        }
        
        if let newSpot = viewModel.createSpot() {
            onSave(newSpot)
            dismiss()
        }
    }
}
