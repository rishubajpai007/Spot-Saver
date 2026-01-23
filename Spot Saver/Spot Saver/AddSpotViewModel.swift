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

// MARK: - View Model
@MainActor
class AddSpotViewModel: ObservableObject {
    @Published var name = ""
    @Published var notes = ""
    @Published var category = "Other"
    @Published var selectedPhotosData: [Data] = []
    @Published var location: CLLocationCoordinate2D?

    var isFormValid: Bool {
        !name.isEmpty && location != nil
    }

    func createSpot() -> Spot? {
        guard let location else {
            print("location not selected correctly")
            return nil
        }
        
        return Spot(
            name: name,
            notes: notes,
            category: category,
            latitude: location.latitude,
            longitude: location.longitude,
            photos: selectedPhotosData
        )
    }
}

