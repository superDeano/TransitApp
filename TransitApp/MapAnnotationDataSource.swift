import RealmSwift

// NOTE: This class is untested!
//
// It's a slim wrapper around async Realm code.
// Be sure to manually test any changes you make.

class MapAnnotationDataSource: MapAnnotationDataSourcing {
    
    weak var delegate: MapAnnotationProvider?
    private(set) var results: Results<Scooter>
    private var token: NotificationToken?

    init(results: Results<Scooter>) {
        self.results = results
        self.token = results.addNotificationBlock { [weak self] results in
            self?.delegate?.dataUpdated()
        }
    }

    deinit {
        self.token?.stop()
    }

}

protocol MapAnnotationDataSourcing {

    weak var delegate: MapAnnotationProvider? { get set }
    var results: Results<Scooter> { get }

}
