//
//  SpotListView.swift
//  Spot Saver
//
//  Created by Rishu Bajpai on 25/09/25.
//

import SwiftUI
import SwiftData

struct SpotsListView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Spot.dateAdded, order: .reverse) private var spots: [Spot]
    @State private var isAddingSpot = false
    @State private var searchText = ""

    
    var body: some View {
        NavigationStack {
            if spots.isEmpty {
                ContentUnavailableView(
                    "No Spots Saved",
                    systemImage: "mappin.and.ellipse",
                    description: Text("Tap the '+' button to add your first spot.")
                )
                .navigationTitle("Spot Saver")
                .toolbar {
                    ToolbarItem {
                        Button(action: { isAddingSpot = true }) {
                            Label("Add Spot", systemImage: "plus")
                        }
                    }
                }
            } else {
                List {
                    ForEach(searchResults) { spot in
                        NavigationLink(destination: SpotDetailView(spot: spot)) {
                            SpotRowView(spot:spot)
                        }
                    }
                    .onDelete(perform: deleteSpots)
                    .listStyle(.plain) 
                    .background(Color("AppBackground"))
                }
                .navigationTitle("Spot Saver")
                .toolbar {
                    ToolbarItem {
                        Button(action: { isAddingSpot = true }) {
                            Label("Add Spot", systemImage: "plus")
                        }
                    }
                }
            }
        }
        .sheet(isPresented: $isAddingSpot) {
            AddSpotView { newSpot in
                addSpot(spot: newSpot)
            }
        }
        .searchable(text: $searchText,placement: .navigationBarDrawer)
    }

    var searchResults: [Spot] {
            if searchText.isEmpty {
                return spots
            } else {
                return spots.filter { spot in
                    let nameMatch = spot.name.localizedStandardContains(searchText)
                    let categoryMatch = spot.category.localizedStandardContains(searchText)
                    return nameMatch || categoryMatch
                }
            }
        }
    
    private func addSpot(spot: Spot) {
        modelContext.insert(spot)
    }

    private func deleteSpots(offsets: IndexSet) {
        withAnimation {
            for index in offsets {
                modelContext.delete(spots[index])
            }
        }
    }
}

