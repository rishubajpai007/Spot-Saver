//
//  PhotoPickerView.swift
//  Spot Saver
//
//  Created by Rishu Bajpai on 25/09/25.
//

import SwiftUI
import PhotosUI

struct PhotoPickerView: View {
    @Binding var selectedPhotoData: Data?
    
    // Internal State
    @State private var selectedItem: PhotosPickerItem? = nil
    @State private var showCamera = false
    @State private var displayImage: UIImage? = nil
    
    var body: some View {
        VStack {
            if let displayImage {
                // MARK: - State 1: Photo Selected
                ZStack(alignment: .topTrailing) {
                    Image(uiImage: displayImage)
                        .resizable()
                        .scaledToFill()
                        .frame(height: 200)
                        .frame(maxWidth: .infinity)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                    
                    // Remove Button
                    Button(action: removePhoto) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.title)
                            .foregroundStyle(.white)
                            .shadow(radius: 2)
                            .padding(8)
                    }
                }
            } else {
                // MARK: - State 2: Empty (Choose Source)
                HStack(spacing: 12) {
                    // Option A: Camera Button
                    Button(action: { showCamera = true }) {
                        VStack {
                            Image(systemName: "camera.fill")
                                .font(.title2)
                            Text("Camera")
                                .font(.caption)
                                .fontWeight(.medium)
                        }
                        .frame(maxWidth: .infinity)
                        .frame(height: 80)
                        .background(Color.blue.opacity(0.1))
                        .foregroundStyle(.blue)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                    
                    // Option B: Gallery Button (PhotosPicker)
                    PhotosPicker(selection: $selectedItem, matching: .images) {
                        VStack {
                            Image(systemName: "photo.on.rectangle")
                                .font(.title2)
                            Text("Gallery")
                                .font(.caption)
                                .fontWeight(.medium)
                        }
                        .frame(maxWidth: .infinity)
                        .frame(height: 80)
                        .background(Color.secondary.opacity(0.1))
                        .foregroundStyle(.primary)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                }
            }
        }
        // Load image if editing existing spot
        .onAppear {
            if let selectedPhotoData, let image = UIImage(data: selectedPhotoData) {
                self.displayImage = image
            }
        }
        // Handle Gallery Selection
        .onChange(of: selectedItem) {
            Task {
                if let data = try? await selectedItem?.loadTransferable(type: Data.self),
                   let image = UIImage(data: data) {
                    DispatchQueue.main.async {
                        self.displayImage = image
                        self.selectedPhotoData = data
                    }
                }
            }
        }
        // Handle Camera Selection
        .sheet(isPresented: $showCamera) {
            CameraView(selectedImage: Binding(
                get: { displayImage },
                set: { newImage in
                    if let newImage {
                        self.displayImage = newImage
                        // Compress heavily to save storage space
                        self.selectedPhotoData = newImage.jpegData(compressionQuality: 0.6)
                    }
                }
            ))
        }
    }
    
    private func removePhoto() {
        withAnimation {
            self.selectedPhotoData = nil
            self.displayImage = nil
            self.selectedItem = nil
        }
    }
}
