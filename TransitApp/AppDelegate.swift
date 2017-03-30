import UIKit
import CoreLocation
import UIKitFringes

class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        let window = UIWindow(frame: UIScreen.main.bounds)
        self.window = window
        
        let mapViewControllerFactory = MapViewControllerFactory()
        let urlSession = URLSession(configuration: .default)
        let timerFactory = TimerFactory()
        let locationManagerFactory = CLLocationManagerFactory()
        let dispatchHandler = DispatchHandler()
        let sharedApplication = UIApplication.shared
        let coordinator = AppCoordinator(mapViewControllerFactory: mapViewControllerFactory,
                                         urlSession: urlSession,
                                         timerFactory: timerFactory,
                                         locationManagerFactory: locationManagerFactory,
                                         dispatchHandler: dispatchHandler,
                                         sharedApplication: sharedApplication)
        coordinator.didFinishLaunching(withWindow: window)
        
        window.makeKeyAndVisible()
        return true
    }

}
