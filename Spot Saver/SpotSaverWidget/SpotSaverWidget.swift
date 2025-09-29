// SpotSaverWidget.swift
import WidgetKit
import SwiftUI
import SwiftData

let sharedContainer: ModelContainer = {
    let appGroupID = "group.com.rishu.Spot-Saver"
    guard let containerURL = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: appGroupID) else {
        fatalError("Could not create container URL for App Group.")
    }
    let storeURL = containerURL.appendingPathComponent("SpotSaver.sqlite")
    let configuration = ModelConfiguration("SpotSaverStore", url: storeURL)

    do {
        return try ModelContainer(for: Spot.self, configurations: configuration)
    } catch {
        fatalError("Failed to create the model container: \(error.localizedDescription)")
    }
}()

struct Provider: TimelineProvider {
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: Date(), spot: nil)
    }

    func getSnapshot(in context: Context, completion: @escaping (SimpleEntry) -> ()) {
        // Create a Task to perform the async work
        Task {
            let entry = SimpleEntry(date: Date(), spot: await fetchLatestSpot())
            completion(entry)
        }
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        Task {
            let entry = SimpleEntry(date: Date(), spot: await fetchLatestSpot())
            let nextUpdate = Calendar.current.date(byAdding: .hour, value: 1, to: Date())!
            let timeline = Timeline(entries: [entry], policy: .after(nextUpdate))
            completion(timeline)
        }
    }
    
    @MainActor
    private func fetchLatestSpot() async -> Spot? {
        let descriptor = FetchDescriptor<Spot>(sortBy: [SortDescriptor(\.dateAdded, order: .reverse)])
        do {
            let spots = try sharedContainer.mainContext.fetch(descriptor)
            return spots.first
        } catch {
            print("Failed to fetch latest spot: \(error.localizedDescription)")
            return nil
        }
    }
}

struct SimpleEntry: TimelineEntry {
    let date: Date
    let spot: Spot?
}

struct SpotSaverWidgetEntryView : View {
    var entry: Provider.Entry

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            if let spot = entry.spot {
                HStack {
                    Image(systemName: "mappin.and.ellipse")
                        .font(.title3)
                        .foregroundStyle(.white)
                        .padding(8)
                        .background(Color.blue.gradient)
                        .clipShape(Circle())
                    Text("Latest Spot")
                        .font(.subheadline)
                        .fontWeight(.bold)
                        .foregroundStyle(.secondary)
                }
                
                Spacer()
                
                Text(spot.name)
                    .font(.headline)
                    .fontWeight(.bold)
                
                Text(spot.category)
                    .font(.caption)
                    .foregroundStyle(.blue)

            } else {
                Image(systemName: "sparkles")
                    .font(.largeTitle)
                    .foregroundStyle(Color.blue.gradient)
                Text("Add a Spot!")
                    .font(.headline)
                    .foregroundStyle(.secondary)
            }
        }
        .padding()
    }
}

struct SpotSaverWidget: Widget {
    let kind: String = "SpotSaverWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            SpotSaverWidgetEntryView(entry: entry)
                .containerBackground(.fill.tertiary, for: .widget)
        }
        .configurationDisplayName("Latest Spot")
        .description("Displays the most recently saved spot.")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}

#Preview(as: .systemSmall) {
    SpotSaverWidget()
} timeline: {
    SimpleEntry(date: .now, spot: nil)
}
