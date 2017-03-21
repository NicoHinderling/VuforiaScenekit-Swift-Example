import UIKit

import ModelIO
import SceneKit
import SceneKit.ModelIO

enum imageTargets {
    case advertisements
    case stonesAndChips
}

extension imageTargets {
    var fileName: String {
        switch self {
        case .advertisements:
            return "Advertisements.xml"
        case .stonesAndChips:
            return "StonesAndChips.xml"
        }
    }
}

class VuforiaViewController: UIViewController {
    
    var targetFile: String
    var imageTargetSizes: [String: (CGFloat, CGFloat)] = [:]
    
    init(_ desiredTarget: imageTargets) {
        targetFile = desiredTarget.fileName
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    var vuforiaManager: VuforiaManager? = nil
    let modelTexture = SCNMaterial()
    
    fileprivate var lastSceneName: String? = nil
    
    deinit { NotificationCenter.default.removeObserver(self) }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let path = Bundle.main.path(forResource: "Keys", ofType: "plist") else {
            fatalError("You're missing Keys.plist which contains the Vuforia License Key")
        }
        guard let vuforiaLicenseKey = NSDictionary(contentsOfFile: path)?["vuforiaLicenseKey"] as? String else {
            fatalError("\"vuforiaLicenseKey\" seems to be missing from your Keys.plist")
        }
        
        prepare(vuforiaLicenseKey, vuforiaDataSetFile: targetFile)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        do {
            try vuforiaManager?.stop()
        }catch let error {
            print("\(error)")
        }
    }
}

private extension VuforiaViewController {
    @objc func swipedRight(_ gesture: UIGestureRecognizer) {
        router.pop()
    }

    func prepare(_ vuforiaLicenseKey: String, vuforiaDataSetFile: String) {
        // Get Image Target Sizes
        imageTargetSizes = ImageTargetParser(vuforiaDataSetFile).imageTargetSizes
        
        vuforiaManager = VuforiaManager(licenseKey: vuforiaLicenseKey, dataSetFile: vuforiaDataSetFile)
        if let manager = vuforiaManager {
            manager.delegate = self
            manager.eaglView.sceneSource = self
            manager.eaglView.delegate = self
            manager.eaglView.setupRenderer()
            self.view = manager.eaglView
            
            let swipedRight = UISwipeGestureRecognizer(target: self, action: #selector(swipedRight(_:)))
            swipedRight.direction = UISwipeGestureRecognizerDirection.right
            self.view.addGestureRecognizer(swipedRight)
        }
        
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(didRecieveWillResignActiveNotification),
                                       name: NSNotification.Name.UIApplicationWillResignActive, object: nil)
        
        notificationCenter.addObserver(self, selector: #selector(didRecieveDidBecomeActiveNotification),
                                       name: NSNotification.Name.UIApplicationDidBecomeActive, object: nil)
        
        vuforiaManager?.prepare(with: .portrait)
    }
    
    func pause() {
        do {
            try vuforiaManager?.pause()
        }catch let error {
            print("\(error)")
        }
    }
    
    func resume() {
        do {
            try vuforiaManager?.resume()
        }catch let error {
            print("\(error)")
        }
    }
}

extension VuforiaViewController {
    func didRecieveWillResignActiveNotification(_ notification: Notification) {
        pause()
    }
    
    func didRecieveDidBecomeActiveNotification(_ notification: Notification) {
        resume()
    }
}

extension VuforiaViewController: VuforiaManagerDelegate {
    func vuforiaManagerDidFinishPreparing(_ manager: VuforiaManager!) {
        print("did finish preparing\n")
        
        do {
            try vuforiaManager?.start()
            vuforiaManager?.setContinuousAutofocusEnabled(true)
        }catch let error {
            print("\(error)")
        }
    }
    
    func vuforiaManager(_ manager: VuforiaManager!, didFailToPreparingWithError error: Error!) {
        print("Error attempting to prepare scene: \(error)\n")
    }
    
    func vuforiaManager(_ manager: VuforiaManager!, didUpdateWith state: VuforiaState!) {
        for index in 0 ..< state.numberOfTrackableResults {
            let result = state.trackableResult(at: index)
            
            guard let trackableResult = result else {
                print("Result with no trackable detected...")
                return
            }

            if lastSceneName != trackableResult.trackable.name {
                modelTexture.transparency = 0.9

                switch trackableResult.trackable.name {
                case "stones":
                    modelTexture.diffuse.contents = UIColor.red
                case "chips":
                    modelTexture.diffuse.contents = UIColor.yellow
                default:
                    // Default the ad models to darkGray for now
                    modelTexture.diffuse.contents = (trackableResult.trackable.name == "bmwAd" ? UIColor.red : UIColor.darkGray)
                }
                
                manager.eaglView.setNeedsChangeSceneWithUserInfo(["scene" : trackableResult.trackable.name])
                lastSceneName = trackableResult.trackable.name
            }
        }
    }
}

extension VuforiaViewController: VuforiaEAGLViewSceneSource, VuforiaEAGLViewDelegate {
    func scene(for view: VuforiaEAGLView!, userInfo: [String : Any]?) -> SCNScene! {
        guard let userInfo = userInfo else {
            print("default scene")
            return createStonesScene(with: view)
        }
        
        guard let sceneName = userInfo["scene"] as? String else {
            fatalError("Scene got messed up yo...")
        }
        
        // Turn this into a switch statement later
        switch sceneName {
        case "stones":
            return createStonesScene(with: view)
        case "chips":
            return createChipsScene(with: view)
        case "bmwAd":
            return createBmwScene(with: view)
        case "iphoneAd":
            return createIphoneScene(with: view)
        case "philipsAd":
            return createPhilipsScene(with: view)
        default:
            fatalError("Foreign sceneName detected...")
        }
    }
    
    func vuforiaEAGLView(_ view: VuforiaEAGLView!, didTouchDownNode node: SCNNode!) {
        // Touch up down
        modelTexture.transparency = 0.6
        guard let sceneName = lastSceneName else { return }
        
        if ["philipsAd", "bmwAd", "iphoneAd"].contains(sceneName) {
            modelTexture.diffuse.contents = UIColor.white
        }
    }
    
    func vuforiaEAGLView(_ view: VuforiaEAGLView!, didTouchUp node: SCNNode!) {
        // Touch up
        modelTexture.transparency = 0.9
        
        guard let sceneName = lastSceneName else { return }
        if ["philipsAd", "bmwAd", "iphoneAd"].contains(sceneName) {
            modelTexture.diffuse.contents = (sceneName == "bmwAd" ? UIColor.red : UIColor.darkGray)
        }
    }
    
    func vuforiaEAGLView(_ view: VuforiaEAGLView!, didTouchCancel node: SCNNode!) {
        // Touch canceled
        modelTexture.transparency = 0.9

        guard let sceneName = lastSceneName else { return }
        if ["philipsAd", "bmwAd", "iphoneAd"].contains(sceneName) {
            modelTexture.diffuse.contents = (sceneName == "bmwAd" ? UIColor.red : UIColor.darkGray)
        }
    }
}

