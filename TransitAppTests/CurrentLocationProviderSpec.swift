import Quick
import Nimble
import CoreLocation
import FakeLocationManager
@testable import TransitApp

class CurrentLocationProviderSpec: TransitAppSpec {
    override func spec() {
        super.spec()

        var subject: CurrentLocationProvider!
        var locationManager: FakeLocationManager!
        var delegate: SpecDelegate!

        beforeEach {
            locationManager = FakeLocationManager()
            subject = CurrentLocationProvider(locationManager: locationManager)
            delegate = SpecDelegate()
            subject.delegate = delegate
        }

        context("when user has never been asked for location authorization before") {

            beforeEach {
                expect(locationManager.authorizationStatus()).to(equal(CLAuthorizationStatus.notDetermined))
            }

            describe("startUpdatingLocation") {

                beforeEach {
                    subject.startUpdatingLocation()
                }

                it("will prompt the user for access") {
                    expect(locationManager.dialog).to(equal(FakeLocationManager.Dialog.requestAccessWhileInUse))
                }

                context("when the user allows access") {
                    
                    beforeEach {
                        locationManager.tapAllowInDialog()
                    }

                    it("will dismiss the dialog") {
                        expect(locationManager.dialog).to(beNil())
                    }

                    it("will update the delegate with the current location") {
                        locationManager.locationRequestSuccess()
                        expect(delegate.receivedCurrentLocation).to(beAnInstanceOf(CLLocation.self))
                    }

                    it("will set the authorization status to authorizedWhenInUse") {
                        expect(locationManager.authorizationStatus()).to(equal(CLAuthorizationStatus.authorizedWhenInUse))
                    }
                }

                context("when the user does not allow access") {
                    
                    beforeEach {
                        locationManager.tapDoNotAllowAccessInDialog()
                    }

                    it("will dismiss the dialog") {
                        expect(locationManager.dialog).to(beNil())
                    }

                    it("will not update the delegate with the current location") {
                        expect(delegate.receivedCurrentLocation).to(beNil())
                    }

                    it("will set the authorization status to authorizedWhenInUse") {
                        expect(locationManager.authorizationStatus()).to(equal(CLAuthorizationStatus.denied))
                    }
                }
            }
        }

        context("when the user has already denied access") {

            beforeEach {
                locationManager.setAuthorizationStatusInSettingsApp(.denied)
            }

            describe("startUpdatingLocation") {

                beforeEach {
                    subject.startUpdatingLocation()
                }

                it("will not prompt the user for access") {
                    expect(locationManager.dialog).to(beNil())
                }

                it("will not update the delegate with the current location") {
                    expect(delegate.receivedCurrentLocation).to(beNil())
                }
            }
        }

        context("when the user has already permitted access") {

            beforeEach {
                locationManager.setAuthorizationStatusInSettingsApp(.authorizedWhenInUse)
            }

            describe("startUpdatingLocation") {

                beforeEach {
                    subject.startUpdatingLocation()
                }

                it("will not prompt the user for access") {
                    expect(locationManager.dialog).to(beNil())
                }
            }

            context("if there is no location already available") {

                describe("startUpdatingLocation") {

                    beforeEach {
                        subject.startUpdatingLocation()
                    }

                    it("will update the delegate with the current location") {
                        locationManager.locationRequestSuccess()
                        expect(delegate.receivedCurrentLocation).to(beAnInstanceOf(CLLocation.self))
                    }
                }
            }
        }

        context("when Location Services are disabled") {

            beforeEach {
                locationManager.setLocationServicesEnabledInSettingsApp(false)
            }

            describe("startUpdatingLocation") {

                beforeEach {
                    subject.startUpdatingLocation()
                }

                it("will prompt the user to turn on Location Services") {
                    expect(locationManager.dialog).to(equal(FakeLocationManager.Dialog.requestJumpToLocationServicesSettings))
                }

                context("when the user taps any response") {
                    
                    beforeEach {
                        locationManager.tapSettingsOrCancelInDialog()
                    }

                    it("will dismiss the dialog") {
                        expect(locationManager.dialog).to(beNil())
                    }
                }
            }
        }

        context("when the user was prompted to enable Location Services and obliged") {
            
            beforeEach {
                locationManager.setLocationServicesEnabledInSettingsApp(false)
                subject.startUpdatingLocation()
                locationManager.tapSettingsOrCancelInDialog()
                locationManager.setLocationServicesEnabledInSettingsApp(true)
            }


            it("will prompt the user for access") {
                expect(locationManager.dialog).to(equal(FakeLocationManager.Dialog.requestAccessWhileInUse))
            }
        }
        
        context("when already authorized, but Location Services are now disabled") {

            beforeEach {
                locationManager.setAuthorizationStatusInSettingsApp(.authorizedWhenInUse)
                locationManager.setLocationServicesEnabledInSettingsApp(false)
            }

            describe("startUpdatingLocation") {

                beforeEach {
                    subject.startUpdatingLocation()
                }

                context("when the user dismisses the dialog and turns it on") {
                    
                    beforeEach {
                        locationManager.tapSettingsOrCancelInDialog()
                        locationManager.setLocationServicesEnabledInSettingsApp(true)
                    }

                    it("will update the delegate with the current location") {
                        locationManager.locationRequestSuccess()
                        expect(delegate.receivedCurrentLocation).to(beAnInstanceOf(CLLocation.self))
                    }
                }
            }
        }
        
        context("when already denied authorization, but Location Services are now disabled") {

            beforeEach {
                locationManager.setAuthorizationStatusInSettingsApp(.denied)
                locationManager.setLocationServicesEnabledInSettingsApp(false)
            }

            describe("startUpdatingLocation") {

                beforeEach {
                    subject.startUpdatingLocation()
                }

                it("will not prompt the user to turn on Location Services") {
                    expect(locationManager.dialog).to(beNil())
                }
            }
        }

        context("when the user has already responded to the Location Services dialog twice") {

            beforeEach {
                locationManager.setLocationServicesEnabledInSettingsApp(false)
                // first time
                subject.startUpdatingLocation()
                expect(locationManager.dialog).to(equal(FakeLocationManager.Dialog.requestJumpToLocationServicesSettings))
                locationManager.tapSettingsOrCancelInDialog()
                // second time
                subject.startUpdatingLocation()
                expect(locationManager.dialog).to(equal(FakeLocationManager.Dialog.requestJumpToLocationServicesSettings))
                locationManager.tapSettingsOrCancelInDialog()
            }

            describe("startUpdatingLocation") {

                beforeEach {
                    subject.startUpdatingLocation()
                }
                
                it("will not prompt the user anymore to turn on Location Services") {
                    expect(locationManager.dialog).to(beNil())
                }

                // If all attempts have been exhausted, it's still possible to ask the user with a
                // manual dialog and to direct them to the "Settings" page, but not specifically
                // The "Location Services" page, which is of course not great.
                // UIApplication.shared.openURL(URL(string: UIApplicationOpenSettingsURLString)!)
            }
        }
    }
}

private class SpecDelegate {

    var receivedCurrentLocation: CLLocation?

}

extension SpecDelegate: CurrentLocationProviderDelegate {

    func currentLocation(_ location: CLLocation) {
        receivedCurrentLocation = location
    }
    
}
