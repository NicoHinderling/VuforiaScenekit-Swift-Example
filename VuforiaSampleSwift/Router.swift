class Router {
    let window: UIWindow
    fileprivate let navigationController = UINavigationController()
    
    init(window: UIWindow) {
        self.window = window
        
        navigationController.isNavigationBarHidden = true
        window.rootViewController = navigationController
    }
    
    func pop() -> UIViewController? {
        return navigationController.popViewController(animated: true)
    }
    
    func push(_ newRoute: Route) {
        return navigationController.pushViewController(newRoute.view, animated: true)
    }
}

extension Router {
    enum Route: Equatable {
        case landing
        case advertisements
        case stonesAndChips
    }
}

extension Router.Route {
    var view: UIViewController {
        switch self {
        case .landing:
            return LandingViewController()
        case .advertisements:
            return VuforiaViewController(.advertisements)
        case .stonesAndChips:
            return VuforiaViewController(.stonesAndChips)
        }
    }
}
