import Quick
import Nimble
import RealmSwift
@testable import TransitApp

class RouteParserSpec: QuickSpec {
    override func spec() {
        describe("parse") {

            var realm: Realm!
            var vbbTransitProvider: TransitProvider!
            var googleTransitProvider: TransitProvider!
            var result: [Route]!
            
            beforeEach {
                Realm.Configuration.defaultConfiguration.inMemoryIdentifier = NSUUID().uuidString
                realm = try! Realm()
                
                vbbTransitProvider = TransitProvider(name: "vbb", iconURL: "", disclaimer: "")
                googleTransitProvider = TransitProvider(name: "google", iconURL: "", disclaimer: "")
                try! realm.write {
                    realm.add([vbbTransitProvider, googleTransitProvider])
                }
                
                let subject = RouteParser(realm: realm)
                let json = JSONParser().parse(filename: "TestRouteJSON")
                result = subject.parse(json: json)
            }

            it("parses Routes from JSON") {
                expect(result.count).to(equal(2))

                let first = result.first!
                expect(first.provider.name).to(equal("vbb"))
                expect(first.type).to(equal("public_transport"))

                let second = result[1]
                expect(second.provider.name).to(equal("google"))
                expect(second.type).to(equal("private_bike"))
            }

            it("parses Segments from JSON") {
                let firstRoute = result.first!
                let segments = firstRoute.segments

                expect(segments.count).to(equal(2))

                let first = segments.first!
                expect(first.name).to(beNil())

                let second = segments[1]
                expect(second.name).to(equal("U2"))
            }

            it("parses Segments from JSON") {
                let firstRoute = result.first!
                let firstSegment = firstRoute.segments.first!
                let stops = firstSegment.stops

                expect(stops.count).to(equal(2))

                let first = stops.first!
                expect(first.name).to(beNil())
                expect(first.latitude).to(beCloseTo(52.530227))
                expect(first.longitude).to(beCloseTo(13.403356))

                let second = stops[1]
                expect(second.name).to(equal("U Rosa-Luxemburg-Platz"))
                expect(second.latitude).to(beCloseTo(52.528187))
                expect(second.longitude).to(beCloseTo(13.410404))
            }

        }
    }
}
