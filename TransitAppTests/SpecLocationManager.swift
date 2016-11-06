import CoreLocation
@testable import TransitApp

/*
 This class is used in place of CLLocationManager while in specs.
 It conforms to a subset of the same interface via LocationManaging.
 This allows us to test code which relies on behavior which is not
 normally under our control in CLLocationManager. It also allows us
 to document assumptions about how CLLocationManager works (based on
 documentation and experimenting with it).
*/

class SpecLocationManager {

    // this probably belongs in a Spec UIApplication
    enum Dialog {
        // "Allow "TransitApp" to access your location while you use the app?"
        // "<message you have set in Info.plist for NSLocationWhenInUseUsageDescription>"
        // [Don't Allow] [Allow]
        case requestAccessWhileInUse
        // Similar to the one above, but with different messaging.
        case requestAccessAlways
        // "Turn On Location Services to Allow "TransitApp" to Determine Your Location"
        // [Settings] [Cancel]
        case requestJumpToLocationServicesSettings
    }

    weak var delegate: CLLocationManagerDelegate? {
        didSet { sendCurrentStatus() }
    }
    fileprivate(set) var dialog: Dialog?
    fileprivate var _authorizationStatus = CLAuthorizationStatus.notDetermined {
        didSet { sendCurrentStatus() }
    }
    fileprivate var _locationServicesEnabled = true {
        didSet { sendCurrentStatus() }
    }
    fileprivate var locationServicesDialogResponseCount = 0
    fileprivate let bsFirstArg = CLLocationManager()
    fileprivate var locationRequestInProgress = false

    private func sendCurrentStatus() {
        delegate?.locationManager?(bsFirstArg, didChangeAuthorization: authorizationStatus())
    }

}

// MARK: Async callbacks
extension SpecLocationManager {

    func locationRequestSuccess() {
        if !authorizationStatus().isOneOf(.authorizedWhenInUse, .authorizedAlways) {
            fatalError("CLLocationManager would not be sending the location, since user has not authorized access.")
        }
        if !locationRequestInProgress {
            fatalError("CLLocationManager would not be sending the location, since there was no location request in progress.")
        }
        locationRequestInProgress = false
        let fakeCurrentLocation = CLLocation(latitude: 1.0, longitude: 2.0)
        delegate!.locationManager?(bsFirstArg, didUpdateLocations: [fakeCurrentLocation])
    }

}

// MARK: User taps for Location Services
extension SpecLocationManager {

    /* Both "Settings" and "Cancel" buttons have the same
     effect on the app and state in the ways we care.
     "Settings" will additionally background the app, but
     we don't care about that, at least yet.
     */
    func tapSettingsOrCancelInDialog() {
        if dialog != .requestJumpToLocationServicesSettings {
            fatalError("The dialog to jump to Location Services was not prompted.")
        }
        dialog = nil
        locationServicesDialogResponseCount += 1
    }
    
}

// MARK: User taps for authorization dialog prompts
extension SpecLocationManager {

    func tapAllowInDialog() {
        let accessLevel: CLAuthorizationStatus
        switch dialog! {
        case .requestAccessWhileInUse: accessLevel = .authorizedWhenInUse
        case .requestAccessAlways: accessLevel = .authorizedAlways
        case .requestJumpToLocationServicesSettings: fatalErrorWrongDialog(); accessLevel = .authorizedAlways
        }
        respondToAccessDialog(accessLevel)
    }
    
    func tapDoNotAllowAccessInDialog() {
        respondToAccessDialog(.denied)
    }

    private func fatalErrorWrongDialog() {
        fatalError("The requestPermission dialog was not prompted.")
    }

    private func respondToAccessDialog(_ level: CLAuthorizationStatus) {
        // the dialog must currently be one asking for authorization
        if !dialog!.isOneOf(.requestAccessWhileInUse, .requestAccessAlways) {
            fatalErrorWrongDialog()
        }
        // the authorization must be one that can come from a user tap on the dialog
        if !level.isOneOf(.denied, .authorizedWhenInUse, .authorizedAlways) {
            fatalError("This is not a valid user response from the dialog.")
        }
        dialog = nil
        _authorizationStatus = level
    }
    
}

// MARK: User's settings in the Settings app
extension SpecLocationManager {

    func setAuthorizationStatusInSettingsApp(_ status: CLAuthorizationStatus) {
        // should there be some check here to make sure that the user would even
        // have the option to be setting a (certain) status in the Settings app?
        _authorizationStatus = status
    }

    func setLocationServicesEnabledInSettingsApp(_ enabled: Bool) {
        _locationServicesEnabled = enabled
    }

}

// MARK: requestWhenInUseAuthorization outcomes
extension SpecLocationManager {
    
    fileprivate func requestWhenInUseWhileNotDetermined() {
        fatalErrorIfCurrentlyADialog()
        dialog = .requestAccessWhileInUse
    }

    fileprivate func requestWhenInUseWhileDeniedDueToLocationServices() {
        if !iOSwillPermitALocationServicesDialogToBeShown { return }
        fatalErrorIfCurrentlyADialog()
        dialog = .requestJumpToLocationServicesSettings
    }

    private var iOSwillPermitALocationServicesDialogToBeShown: Bool {
        // iOS will only ever show the user this dialog twice for this app.
        // It only counts as being shown if the user responds. For example,
        // the following things can dismiss the dialog without it counting:
        // * Locking the device.
        // * Receiving a call, accepting, and then clicking Home.
        return locationServicesDialogResponseCount < 2
    }

    private func fatalErrorIfCurrentlyADialog() {
        if dialog != nil {
            fatalError("There is already a dialog displayed. If showing another one would create a stack of dialogs, then update `dialog` to handle a stack.")
        }
    }

}

// MARK: requestLocation outcomes
extension SpecLocationManager {

    fileprivate func requestLocationWhileNotDetermined() {
        let error = NSError(domain: kCLErrorDomain, code: 0, userInfo: nil)
        delegate!.locationManager!(bsFirstArg, didFailWithError: error)
    }

    fileprivate func requestLocationWhileWhenInUse() {
        locationRequestInProgress = true
    }

}

// MARK: LocationManaging
extension SpecLocationManager: LocationManaging {

    func requestWhenInUseAuthorization() {
        switch authorizationStatus() {
        case .notDetermined: requestWhenInUseWhileNotDetermined()
        case .denied:
            // if .denied due to base status (the user having tapped "Don't Allow" before)
            if _authorizationStatus == .denied { break }
            if !isLocationServicesEnabled() {
                // or, if .denied due to Location Services being off, but user has not before denied auth.
                requestWhenInUseWhileDeniedDueToLocationServices()
            } else {
                fatalError("How is auth status .denied if not due to base status being .denied or Location Services being off?")
            }
        case .authorizedWhenInUse: break
        default: fatalError("Other authorization statuses are not supported yet.")
        }
    }

    func requestLocation() {
        switch authorizationStatus() {
        case .notDetermined: requestLocationWhileNotDetermined()
        case .authorizedWhenInUse: requestLocationWhileWhenInUse()
        default: fatalError("Other authorization statuses are not supported yet.")
        }
    }
    
    func authorizationStatus() -> CLAuthorizationStatus {
        if !isLocationServicesEnabled() { return .denied }
        return _authorizationStatus
    }

    func isLocationServicesEnabled() -> Bool {
        return _locationServicesEnabled
    }

}
