//
//  Spot.swift
//  Spot Saver
//
//  Created by Rishu Bajpai on 25/09/25.
//

import Foundation
import SwiftData
import CoreLocation

@Model
final class Spot {
    @Attribute(.unique) var id: UUID
    var name: String
    var notes: String
    var category: String
    var latitude: Double
    var longitude: Double
    @Attribute(.externalStorage) var photo: Data? // Use externalStorage for large data like images
    var dateAdded: Date

    init(name: String, notes: String, category: String, latitude: Double, longitude: Double, photo: Data? = nil) {
        self.id = UUID()
        self.name = name
        self.notes = notes
        self.category = category
        self.latitude = latitude
        self.longitude = longitude
        self.photo = photo
        self.dateAdded = .now
    }

    // Computed property to make using coordinates with MapKit easier
    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
    
    var description: String {
            return "Spot(name: \"\(name)\", category: \"\(category)\", lat: \(latitude), lon: \(longitude))"
        }
}
