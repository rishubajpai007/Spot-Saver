//
//  SpotsListView.swift
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
            Group {
                if spots.isEmpty {
                    ContentUnavailableView(
                        "No Spots Saved",
                        systemImage: "mappin.and.ellipse",
                        description: Text("Tap the '+' button to add your first spot.")
                    )
                } else {
                    List {
                        ForEach(searchResults) { spot in
                            NavigationLink(destination: SpotDetailView(spot: spot)) {
                                SpotRowView(spot: spot)
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
                ToolbarItem(placement: .primaryAction) {
                    Button(action: { isAddingSpot = true }) {
                        Label("Add Spot", systemImage: "plus")
                    }
                }
            }
            .searchable(text: $searchText, placement: .navigationBarDrawer, prompt: "Search by name or category")
        }
        .sheet(isPresented: $isAddingSpot) {
            AddSpotView { newSpot in
                addSpot(spot: newSpot)
            }
        }
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
