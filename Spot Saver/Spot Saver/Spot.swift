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
final class Spot : CustomStringConvertible,Hashable {
    @Attribute(.unique) var id: UUID
    var name: String
    var notes: String
    var category: String
    var latitude: Double
    var longitude: Double
    @Attribute(.externalStorage) var photo: Data?
    var dateAdded: Date
    var isFavorite: Bool
    
    init(name: String, notes: String, category: String, latitude: Double, longitude: Double, photo: Data? = nil, isFavorite: Bool = false) {
        self.id = UUID()
        self.name = name
        self.notes = notes
        self.category = category
        self.latitude = latitude
        self.longitude = longitude
        self.photo = photo
        self.dateAdded = .now
        self.isFavorite = isFavorite
    }
    
    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
    
    var description: String {
        return "Spot(name: \"\(name)\", category: \"\(category)\", lat: \(latitude), lon: \(longitude))"
    }
    
    static func == (lhs: Spot, rhs: Spot) -> Bool {
        lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
