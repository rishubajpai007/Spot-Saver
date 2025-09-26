//
//  Spot_SaverApp.swift
//  Spot Saver
//
//  Created by Rishu Bajpai on 24/09/25.
//

import SwiftUI
import SwiftData

@main
struct Spot_SaverApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        // This modifier explicitly sets up the data container
        // for ContentView and ALL views inside it. This is the key fix.
        .modelContainer(for: Spot.self)
    }
}
