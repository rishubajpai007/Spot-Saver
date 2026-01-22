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
    @FocusState private var focusedField: Field?
    private enum Field { case name, notes }

    var body: some View {
        NavigationStack {
            Form {
                Section("Details") {
                    TextField("Name", text: $viewModel.name)
                        .focused($focusedField, equals: .name)
                        .submitLabel(.next)
                        .onSubmit { focusedField = .notes }
                    VStack(alignment: .leading, spacing: 4) {
                        TextField("Notes", text: $viewModel.notes, axis: .vertical)
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
