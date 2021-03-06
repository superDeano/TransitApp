import XCTest
import CoreLocation
@testable import TransitApp

class MapOverlayFeature: TransitAppFeature {

    func testIsSeeded() {
        tapAppIconAndSkipToMap()
        XCTAssertEqual(mapUI.businessAreaOverlays.count, 3)
        let first = mapUI.businessAreaOverlays.first!
        let coordinates = first.coordinates
        XCTAssertEqual(coordinates.count, 9)
        XCTAssertEqual(coordinates.first,
                       CLLocationCoordinate2D(latitude: 52.4982496804861, longitude: 13.354353904724121))
        let renderer = mapUI.polygonRenderer(for: first)!
        XCTAssertEqual(renderer.strokeColor, UIColor(rgb: 0x7DD5DE))
        XCTAssertEqual(renderer.lineWidth, 2)
        XCTAssertEqual(renderer.fillColor, UIColor(rgb: 0x2B354A, alpha: 0.09))
    }
}
