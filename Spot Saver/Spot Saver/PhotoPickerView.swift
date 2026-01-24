//
//  PhotoPickerView.swift
//  Spot Saver
//

import SwiftUI
import PhotosUI

struct PhotoPickerView: View {
    @Binding var selectedPhotosData: [Data]

    @State private var selectedItems: [PhotosPickerItem] = []
    @State private var displayImages: [UIImage] = []

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {

            if !displayImages.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach(Array(displayImages.enumerated()), id: \.offset) { index, image in
                            ZStack(alignment: .topTrailing) {
                                Image(uiImage: image)
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 120, height: 120)
                                    .clipShape(RoundedRectangle(cornerRadius: 12))

                                Button {
                                    removePhoto(at: index)
                                } label: {
                                    Image(systemName: "xmark.circle.fill")
                                        .foregroundStyle(.white)
                                        .padding(6)
                                }
                            }
                        }
                    }
                }
            }
            
            HStack(spacing: 12) {
                PhotosPicker(
                    selection: $selectedItems,
                    maxSelectionCount: 10,
                    matching: .images
                ) {
                    sourceTile(
                        icon: "photo.on.rectangle",
                        title: "Gallery",
                        color: .secondary
                    )
                }
            }

            
        }
        .onAppear {
            displayImages = selectedPhotosData.compactMap { UIImage(data: $0) }
        }
        .onChange(of: selectedItems) {
            Task {
                for item in selectedItems {
                    if let data = try? await item.loadTransferable(type: Data.self),
                       let image = UIImage(data: data) {
                        displayImages.append(image)
                        selectedPhotosData.insert(data, at: 0)                    }
                }
                selectedItems.removeAll()
            }
        }
        .onChange(of: selectedPhotosData) { _, newValue in
            displayImages = newValue.compactMap { UIImage(data: $0) }
        }
    }

    // MARK: - UI Helper
    private func sourceTile(icon: String, title: String, color: Color) -> some View {
        VStack {
            Image(systemName: icon).font(.title2)
            Text(title).font(.caption).fontWeight(.medium)
        }
        .frame(maxWidth: .infinity)
        .frame(height: 80)
        .background(color.opacity(0.1))
        .foregroundStyle(color)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    private func removePhoto(at index: Int) {
        guard displayImages.indices.contains(index) else { return }
        displayImages.remove(at: index)
        if selectedPhotosData.indices.contains(index) {
            selectedPhotosData.remove(at: index)
        }
    }
}

