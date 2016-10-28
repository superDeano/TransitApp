import Quick
import Nimble
@testable import TransitApp

class SegmentedControlSourceSpec: TransitAppSpec {
    override func spec() {
        super.spec()

        let subject = SegmentedControlSource()

        describe("segments") {
            it("returns all Segment structs") {
                let segments = subject.segments

                expect(segments.count).to(equal(2))

                let first = segments.first!
                expect(first.index).to(equal(0))
                expect(first.title).to(equal("COUP"))

                let second = segments[1]
                expect(second.index).to(equal(1))
                expect(second.title).to(equal("Door2Door"))
            }
        }

        describe("selectedIndex") {
            it("returns the currently selectedIndex") {
                let selectedIndex = subject.selectedIndex

                expect(selectedIndex).to(equal(0))
            }
        }
    }
}