//
//  AddSpotView.swift
//  Spot Saver
//
//  Created by Rishu Bajpai on 25/09/25.
//
import SwiftUI
import CoreLocation
import Combine

@MainActor
class AddSpotViewModel: ObservableObject {
    @Published var name = ""
    @Published var notes = ""
    @Published var category = "Favorites" // Default category
    @Published var selectedPhotoData: Data?
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
            photo: selectedPhotoData
        )
    }
}
