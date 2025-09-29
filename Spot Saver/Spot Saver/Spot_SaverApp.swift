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
    let container: ModelContainer
    
    init() {
        do {
            let appGroupID = "group.com.rishu.Spot-Saver"
            
            guard let containerURL = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: appGroupID) else {
                fatalError("Could not create container URL for App Group.")
            }
            
            let storeURL = containerURL.appendingPathComponent("SpotSaver.sqlite")
            let configuration = ModelConfiguration("SpotSaverStore", url: storeURL)
            container = try ModelContainer(for: Spot.self, configurations: configuration)
            
        } catch {
            fatalError("Failed to create the model container: \(error.localizedDescription)")
        }
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(container)
    }
}
