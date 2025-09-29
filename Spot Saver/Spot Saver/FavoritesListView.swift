//
//  FavoritesListView.swift
//  Spot Saver
//
//  Created by Rishu Bajpai on 29/09/25.
//

import SwiftUI
import SwiftData

struct FavoritesListView: View {
    @Query(filter: #Predicate<Spot> { $0.isFavorite }, sort: \.dateAdded, order: .reverse)
    private var favoriteSpots: [Spot]
    
    @Environment(\.modelContext) private var modelContext
    
    var body: some View {
        List {
            ForEach(favoriteSpots) { spot in
                NavigationLink(destination: SpotDetailView(spot: spot)) {
                    SpotRowView(spot: spot)
                }
                .listRowSeparator(.hidden)
                .listRowBackground(Color.clear)
                .padding(.vertical, 6)
            }
            .onDelete(perform: deleteSpots)
        }
        .listStyle(.plain)
        .background(Color("AppBackground"))
        .navigationTitle("Favorites")
        .overlay {
            if favoriteSpots.isEmpty {
                ContentUnavailableView(
                    "No Favorites",
                    systemImage: "star",
                    description: Text("Tap the star on a spot's detail page to add it to your favorites.")
                )
            }
        }
    }
    
    private func deleteSpots(offsets: IndexSet) {
        withAnimation {
            for index in offsets {
                modelContext.delete(favoriteSpots[index])
            }
        }
    }
}
