import Quick
import Nimble
import RealmSwift
import MapKit
@testable import TransitApp

class MapOverlayProviderSpec: TransitAppSpec {
    override func spec() {
        super.spec()

        var subject: MapOverlayProvider!

        beforeEach {
            let coordinates = [BusinessAreaCoordinate(latitude: 44.0, longitude: 62.0),
                               BusinessAreaCoordinate(latitude: 40.0, longitude: 60.0),
                               BusinessAreaCoordinate(latitude: 50.0, longitude: 70.0)]
            let businessArea = BusinessArea(coordinates: coordinates)

            try! self.realm.write {
                self.realm.add(businessArea)
            }
        }

        describe("overlays") {

            beforeEach {
                subject = MapOverlayProvider(realm: self.realm)
            }

            it("returns an overlay for each BusinessArea") {
                expect(subject.overlays).to(haveCount(1))

                let overlay = subject.overlays.first as! MKPolygon
                expect(overlay.pointCount).to(equal(3))

                let firstMapPoint = overlay.points()[0]
                let firstCoordinate = MKCoordinateForMapPoint(firstMapPoint)
                expect(firstCoordinate.latitude).to(beCloseTo(44.0))
                expect(firstCoordinate.longitude).to(beCloseTo(62.0))
            }
            
        }
    }
}
