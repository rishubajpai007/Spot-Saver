//
//  FullMapView.swift
//  Spot Saver
//
//  Created by Rishu Bajpai on 29/09/25.
//

import SwiftUI
import MapKit
import SwiftData

struct FullMapView: View {
    @Query(Self.allSpotsDescriptor) private var spots: [Spot]
    
    @State private var selectedSpot: Spot?
    
    var body: some View {
        Map(selection: $selectedSpot) {
            ForEach(spots) { spot in
                Marker(spot.name, coordinate: spot.coordinate)
                    .tint(.blue)
                    .tag(spot)
            }
        }
        .mapStyle(.standard(elevation: .realistic))
        .navigationTitle("All Spots Map")
        .sheet(item: $selectedSpot) { spot in
            NavigationStack {
                SpotDetailView(spot: spot)
            }
            .presentationDetents([.height(600), .medium, .large])
        }
    }
    
    static var allSpotsDescriptor: FetchDescriptor<Spot> {
        let sortByDate = SortDescriptor(\Spot.dateAdded, order: .reverse)
        return FetchDescriptor<Spot>(sortBy: [sortByDate])
    }
}
