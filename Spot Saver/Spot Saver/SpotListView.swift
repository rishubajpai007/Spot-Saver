//
//  SpotsListView.swift
//  Spot Saver
//
//  Created by Rishu Bajpai on 25/09/25.
//

import SwiftUI
import SwiftData
import CoreLocation

enum SortOption: String, CaseIterable {
    case date = "Newest"
    case distance = "Nearest"
    case name = "Name"
}

struct SpotsListView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Spot.dateAdded, order: .reverse) private var spots: [Spot]
    
    @State private var isAddingSpot = false
    @State private var searchText = ""
    @State private var sortOption: SortOption = .date
    
    @StateObject private var locationManager = LocationManager()

    // MARK: - Filtering & Sorting Logic
    var filteredAndSortedSpots: [Spot] {
        // 1. Filter by Search Text
        let filteredSpots: [Spot]
        if searchText.isEmpty {
            filteredSpots = spots
        } else {
            filteredSpots = spots.filter { spot in
                spot.name.localizedStandardContains(searchText) ||
                spot.category.localizedStandardContains(searchText) ||
                spot.notes.localizedStandardContains(searchText)
            }
        }
        
        // 2. Sort by Selected Option
        switch sortOption {
        case .date:
            return filteredSpots.sorted { $0.dateAdded > $1.dateAdded }
            
        case .name:
            return filteredSpots.sorted { $0.name < $1.name }
            
        case .distance:
            guard let userLoc = locationManager.currentLocation else { return filteredSpots }
            return filteredSpots.sorted { spot1, spot2 in
                let dist1 = userLoc.distance(from: CLLocation(latitude: spot1.latitude, longitude: spot1.longitude))
                let dist2 = userLoc.distance(from: CLLocation(latitude: spot2.latitude, longitude: spot2.longitude))
                return dist1 < dist2
            }
        }
    }

    var body: some View {
        NavigationStack {
            Group {
                if spots.isEmpty {
                    ContentUnavailableView(
                        "No Spots Saved",
                        systemImage: "mappin.and.ellipse",
                        description: Text("Tap the '+' button to add your first spot.")
                    )
                }
                else if filteredAndSortedSpots.isEmpty && !searchText.isEmpty {
                    ContentUnavailableView.search(text: searchText)
                }
                else {
                    List {
                        ForEach(filteredAndSortedSpots) { spot in
                            NavigationLink(destination: SpotDetailView(spot: spot)) {
                                SpotRowView(spot: spot, userLocation: locationManager.currentLocation)
                            }
                            .listRowSeparator(.hidden)
                            .listRowBackground(Color.clear)
                        }
                        .onDelete(perform: deleteSpots)
                    }
                    .listStyle(.plain)
                    .background(Color(uiColor: .systemGroupedBackground))
                }
            }
            .navigationTitle("Spot Saver")
            .toolbar {
                // MARK: - Sort Menu
                ToolbarItem(placement: .topBarLeading) {
                    Menu {
                        Picker("Sort By", selection: $sortOption) {
                            Label("Newest", systemImage: "calendar").tag(SortOption.date)
                            Label("Nearest", systemImage: "location").tag(SortOption.distance)
                            Label("Name", systemImage: "textformat").tag(SortOption.name)
                        }
                    } label: {
                        Image(systemName: "arrow.up.arrow.down.circle")
                            .foregroundStyle(.primary)
                    }
                }
                
                ToolbarItem(placement: .primaryAction) {
                    Button(action: { isAddingSpot = true }) {
                        Label("Add Spot", systemImage: "plus")
                    }
                }
            }
            .searchable(text: $searchText, placement: .navigationBarDrawer, prompt: "Search name, category...")
            .sheet(isPresented: $isAddingSpot) {
                AddSpotView { newSpot in
                    addSpot(spot: newSpot)
                }
            }
            .onAppear {
                locationManager.checkLocationAuthorization()
            }
        }
    }
    
    private func addSpot(spot: Spot) {
        modelContext.insert(spot)
    }

    private func deleteSpots(offsets: IndexSet) {
        withAnimation {
            for index in offsets {
                let spotToDelete = filteredAndSortedSpots[index]
                modelContext.delete(spotToDelete)
            }
        }
    }
}
