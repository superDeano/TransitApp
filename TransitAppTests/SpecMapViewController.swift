import UIKit
import SpecUIKitFringes
import MapKit
@testable import TransitApp

protocol SpecMapViewInterating {
    
    // MARK: Input

    func tapCurrentLocationButton()
    func drag()

    // MARK: Output

    var showCurrentLocation: Bool! { get }
    var userTrackingMode: MKUserTrackingMode! { get }
    var mapRegion: MKCoordinateRegion? { get }
    var mapOverlays: [MKOverlay] { get }
    var businessAreaOverlays: [MKPolygon] { get }
    var mapAnnotations: [MKAnnotation] { get }
    var scooterAnnotations: [CoupMapAnnotation] { get }
    var currentLocationButtonState: CurrentLocationViewModel.ButtonState! { get }
    var shownAlert: MapViewModel.Alert! { get }
    func scooterAnnotationView(for: MKAnnotation) -> CoupMapAnnotationView?
    func polygonRenderer(for overlay: MKOverlay) -> MKPolygonRenderer?
}

class SpecMapViewController: SpecViewController, MapViewControlling, SpecMapViewInterating {

    var showCurrentLocation: Bool!
    var userTrackingMode: MKUserTrackingMode!
    var mapRegion: MKCoordinateRegion?
    var mapOverlays = [MKOverlay]()
    var mapAnnotations = [MKAnnotation]()
    var currentLocationButtonState: CurrentLocationViewModel.ButtonState!
    var shownAlert: MapViewModel.Alert!

    private let mapView = SpecMKMapView()

    var viewModel: MapViewModel!

    func scooterAnnotationView(for annotation: MKAnnotation) -> CoupMapAnnotationView? {
        return mapView.delegate?.mapView?(mapView, viewFor: annotation) as? CoupMapAnnotationView
    }
    
    func polygonRenderer(for overlay: MKOverlay) -> MKPolygonRenderer? {
        return mapView.delegate?.mapView?(mapView, rendererFor: overlay) as? MKPolygonRenderer
    }

    override func viewDidLoad() {
        viewModel.delegate = self
        viewModel.viewDidLoad(mapViewDelegateHaving: mapView)
    }

    func tapCurrentLocationButton() {
        viewModel.tapCurrentLocationButton()
    }

    func drag() {
        mapView.drag()
    }
    
    var scooterAnnotations: [CoupMapAnnotation] {
        return mapAnnotations.flatMap { $0 as? CoupMapAnnotation }
    }
    
    var businessAreaOverlays: [MKPolygon] {
        return mapOverlays.flatMap { $0 as? MKPolygon }
    }
}

extension SpecMapViewController : MapViewModelDelegate {

    func setShowCurrentLocation(_ enabled: Bool) {
        showCurrentLocation = enabled
    }

    func setUserTracking(mode: MKUserTrackingMode) {
        userTrackingMode = mode
    }

    func setRegion(_ region: MKCoordinateRegion) {
        mapRegion = region
    }

    func setOverlays(_ overlays: [MKOverlay]) {
        mapOverlays = overlays
    }
    
    func add(annotations: [MKAnnotation]) {
        mapAnnotations = annotations
    }

    func removeAllAnnotations() {
        mapAnnotations = []
    }

    func setCurrentLocationButtonState(_ state: CurrentLocationViewModel.ButtonState) {
        currentLocationButtonState = state
    }
    
    func showAlert(_ alert: MapViewModel.Alert) {
        shownAlert = alert
    }
}

class SpecMapViewFactory : MapViewFactory {

    func create() -> MapViewControlling {
        return SpecMapViewController()
    }
}
