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
    
    // MARK: - State
    @State private var isAddingSpot = false
    @State private var searchText = ""
    @State private var sortOption: SortOption = .date
    @State private var selectedCategory: String? = nil
    @StateObject private var locationManager = LocationManager()

    // MARK: - Category Data
    let categories: [(tag: String, label: String, icon: String)] = [
        ("Food", "Food", "🍔"),
        ("Drinks", "Drinks", "☕️"),
        ("Nature", "Nature", "🌲"),
        ("Shopping", "Shopping", "🛍️"),
        ("Culture", "Culture", "🏛️"),
        ("Nightlife", "Nightlife", "🍸"),
        ("Entertainment", "Entertain", "🎬"),
        ("Date", "Date", "💘"),
        ("Work", "Work", "💼"),
        ("Other", "Other", "📍")
    ]

    // MARK: - Filtering Logic
    var filteredAndSortedSpots: [Spot] {
        // 1. Filter by Category
        var result = spots
        
        if let category = selectedCategory {
            result = result.filter { $0.category == category }
        }
        
        // 2. Filter by Search Text
        if !searchText.isEmpty {
            result = result.filter { spot in
                spot.name.localizedStandardContains(searchText) ||
                spot.category.localizedStandardContains(searchText) ||
                spot.notes.localizedStandardContains(searchText)
            }
        }
        
        // 3. Sort
        switch sortOption {
        case .date:
            return result.sorted { $0.dateAdded > $1.dateAdded }
        case .name:
            return result.sorted { $0.name < $1.name }
        case .distance:
            guard let userLoc = locationManager.currentLocation else { return result }
            return result.sorted { spot1, spot2 in
                let dist1 = userLoc.distance(from: CLLocation(latitude: spot1.latitude, longitude: spot1.longitude))
                let dist2 = userLoc.distance(from: CLLocation(latitude: spot2.latitude, longitude: spot2.longitude))
                return dist1 < dist2
            }
        }
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                
                // MARK: - Category Filter Bar
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 10) {
                        FilterPill(
                            title: "All",
                            icon: "list.bullet",
                            isSelected: selectedCategory == nil
                        ) {
                            withAnimation { selectedCategory = nil }
                        }
                        
                        ForEach(categories, id: \.tag) { item in
                            FilterPill(
                                title: item.label,
                                icon: item.icon,
                                isEmoji: true,
                                isSelected: selectedCategory == item.tag
                            ) {
                                withAnimation {
                                    if selectedCategory == item.tag {
                                        selectedCategory = nil
                                    } else {
                                        selectedCategory = item.tag
                                    }
                                }
                            }
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                }
                .background(Color(uiColor: .systemBackground))
                .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 5)
                .zIndex(1)
                
                // MARK: - The List
                Group {
                    if spots.isEmpty {
                        ContentUnavailableView(
                            "No Spots Saved",
                            systemImage: "mappin.and.ellipse",
                            description: Text("Tap the '+' button to add your first spot.")
                        )
                    }
                    else if filteredAndSortedSpots.isEmpty {
                        ContentUnavailableView(
                            "No Results",
                            systemImage: "magnifyingglass",
                            description: Text("Try changing your search or filter.")
                        )
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
            }
            .navigationTitle("Spot Saver")
            .toolbar {
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
            .searchable(text: $searchText, placement: .navigationBarDrawer, prompt: "Search name...")
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
    
    // MARK: - Actions
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

// MARK: - Subview: Filter Pill Button
struct FilterPill: View {
    let title: String
    let icon: String
    var isEmoji: Bool = false
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                if isEmoji {
                    Text(icon)
                } else {
                    Image(systemName: icon)
                }
                Text(title)
                    .fontWeight(.medium)
            }
            .font(.subheadline)
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(isSelected ? Color.blue : Color(uiColor: .secondarySystemBackground))
            .foregroundColor(isSelected ? .white : .primary)
            .clipShape(Capsule())
            .overlay(
                Capsule()
                    .stroke(Color.secondary.opacity(0.2), lineWidth: 0.5)
            )
        }
        .buttonStyle(.plain) 
    }
}
