import UIKit

class ViewController: UIViewController {
}

// creation
extension ViewController {
    
    class var storyboardName: String { return "ViewController" }

    // Using a Storyboard, rather than a NIB, allows us access
    // to top/bottom layout guides in Interface Builder
    class func createFromStoryboard() -> ViewController {
        return UIStoryboard(name: storyboardName, bundle: nil)
            .instantiateInitialViewController() as! ViewController
    }
    
}

