//
//  ContentView.swift
//  Spot Saver
//
//  Created by Rishu Bajpai on 24/09/25.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            NavigationStack {
                SpotsListView()
            }
            .tabItem {
                Label("All Spots", systemImage: "mappin.and.ellipse")
            }
            
            NavigationStack {
                FavoritesListView()
            }
            .tabItem {
                Label("Favorites", systemImage: "star.fill")
            }
        }
    }
}

#Preview {
    ContentView()
}

