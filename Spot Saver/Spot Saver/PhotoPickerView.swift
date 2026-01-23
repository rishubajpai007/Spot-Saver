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

    @State private var showCamera = false
    @State private var cameraCapturedImage: UIImage?

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {

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
                        selectedPhotosData.append(data)
                    }
                }
                selectedItems.removeAll()
            }
        }
        .onChange(of: cameraCapturedImage) {
            if let img = cameraCapturedImage,
               let data = img.jpegData(compressionQuality: 0.6) {
                displayImages.append(img)
                selectedPhotosData.append(data)
            }
            cameraCapturedImage = nil
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
