import MapKit
import SwiftUI

struct SearchCompletions: Identifiable {
    let id = UUID()
    let title: String
    let subTitle: String
    let result: MKLocalSearchCompletion
}

struct SearchResult: Identifiable, Hashable {
    let id = UUID()
    let location: CLLocationCoordinate2D
    let url: URL?
    
    static func == (lhs: SearchResult, rhs: SearchResult) -> Bool {
        lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

@Observable
class LocationService: NSObject, MKLocalSearchCompleterDelegate {
    private let completer: MKLocalSearchCompleter
    var completions = [SearchCompletions]()
    
    init(completer: MKLocalSearchCompleter) {
        self.completer = completer
        super.init()
        self.completer.delegate = self
    }
    
    func update(queryFragment: String) {
        completer.resultTypes = .pointOfInterest
        completer.queryFragment = queryFragment
    }
    
    // MARK: - Safe Public API Delegate
    func completerDidUpdateResults(_ completer: MKLocalSearchCompleter) {
        completions = completer.results.map { completion in
            .init(
                title: completion.title,
                subTitle: completion.subtitle,
                result: completion
            )
        }
    }
    
    // MARK: - Search Logic
    
    func search(with query: String) async throws -> [SearchResult] {
        let mapKitRequest = MKLocalSearch.Request()
        mapKitRequest.naturalLanguageQuery = query
        mapKitRequest.resultTypes = .pointOfInterest
        
        let search = MKLocalSearch(request: mapKitRequest)
        let response = try await search.start()
        
        return response.mapItems.compactMap { mapItem in
            guard let location = mapItem.placemark.location?.coordinate else { return nil }
            return .init(location: location, url: mapItem.url)
        }
    }
    
    func search(using completion: MKLocalSearchCompletion) async throws -> [SearchResult] {
        let mapKitRequest = MKLocalSearch.Request(completion: completion)
        let search = MKLocalSearch(request: mapKitRequest)
        let response = try await search.start()
        
        return response.mapItems.compactMap { mapItem in
            guard let location = mapItem.placemark.location?.coordinate else { return nil }
            return .init(location: location, url: mapItem.url)
        }
    }
}
