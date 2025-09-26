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
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(spots) { spot in
                    NavigationLink(destination: SpotDetailView(spot: spot)) {
                        VStack(alignment: .leading) {
                            Text(spot.name).font(.headline)
                            Text(spot.category).font(.subheadline).foregroundStyle(.secondary)
                        }
                    }
                }
                .onDelete(perform: deleteSpots)
            }
            .navigationTitle("Spot Saver")
            .toolbar {
                ToolbarItem {
                    Button(action: { isAddingSpot = true }) {
                        Label("Add Spot", systemImage: "plus")
                    }
                }
            }
            .sheet(isPresented: $isAddingSpot) {
                AddSpotView { newSpot in
                    addSpot(spot: newSpot)
                }
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
