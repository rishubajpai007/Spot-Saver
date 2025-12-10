//
//  SpotRowView.swift
//  Spot Saver
//
//  Created by Rishu Bajpai on 29/09/25.
//

import SwiftUI

struct SpotRowView: View {
    let spot: Spot

    var body: some View {
        HStack(spacing: 16) {
            // MARK: - Image Section
            if let imageData = spot.photo, let uiImage = UIImage(data: imageData) {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 80, height: 80)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            } else {
                Image(systemName: "mappin.and.ellipse")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 40, height: 40)
                    .padding()
                    .background(Color(UIColor.systemGray5))
                    .frame(width: 80, height: 80)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .foregroundStyle(.white)
            }
            
            // MARK: - Text Section
            VStack(alignment: .leading, spacing: 6) {
                Text(spot.name)
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundStyle(.primary)
                
                Text(spot.category)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundStyle(.accent) // Keeps your app's tint color
                
                Text(spot.dateAdded.formatted(date: .abbreviated, time: .omitted))
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            
            Spacer()
        }
        .padding()
        .background(Color(uiColor: .secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 4)
    }
}
