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
    @State private var selectedItem: PhotosPickerItem?

    var body: some View {
        PhotosPicker(selection: $selectedItem, matching: .images) {
            if let selectedPhotoData, let uiImage = UIImage(data: selectedPhotoData) {
                // MARK: - State 1: Photo Selected
                HStack {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 80, height: 80)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.secondary.opacity(0.2), lineWidth: 1)
                        )
                    
                    VStack(alignment: .leading) {
                        Text("Photo Added")
                            .font(.headline)
                            .foregroundStyle(.primary)
                        Text("Tap to change")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
            } else {
                // MARK: - State 2: Empty Placeholder
                HStack {
                    ZStack {
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color(uiColor: .secondarySystemBackground))
                            .frame(width: 80, height: 80)
                        
                        Image(systemName: "camera.fill")
                            .font(.title2)
                            .foregroundStyle(.tint)
                    }
                    
                    Text("Add Photo")
                        .font(.headline)
                        .foregroundStyle(.tint)
                }
            }
        }
        .buttonStyle(.plain)
        .onChange(of: selectedItem) {
            Task {
                if let data = try? await selectedItem?.loadTransferable(type: Data.self) {
                    if let uiImage = UIImage(data: data),
                       let compressedData = uiImage.jpegData(compressionQuality: 0.7) {
                        selectedPhotoData = compressedData
                    } else {
                        selectedPhotoData = data
                    }
                }
            }
        }
    }
}
