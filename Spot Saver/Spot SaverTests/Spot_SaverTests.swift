import XCTest
import SwiftData
@testable import Spot_Saver

final class Spot_SaverTests: XCTestCase {

    func testSpotInitialization() throws {
        let name = "Best Pizza"
        let category = "Food"
        let lat = 40.7128
        let long = -74.0060
        
        let spot = Spot(
            name: name,
            notes: "Great cheese slice",
            category: category,
            latitude: lat,
            longitude: long,
            photos: []
        )
        
        XCTAssertEqual(spot.name, name)
        XCTAssertEqual(spot.category, category)
        XCTAssertEqual(spot.latitude, lat)
        XCTAssertNotNil(spot.dateAdded)
        XCTAssertTrue(spot.photos.isEmpty)
    }
}

