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
    
    init(_ desiredTarget: imageTargets) {
        targetFile = desiredTarget.fileName
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    var vuforiaManager: VuforiaManager? = nil
    let boxMaterial = SCNMaterial()
    
    fileprivate var lastSceneName: String? = nil
    fileprivate var imageTargetSizes: [String: (CGFloat, CGFloat)] = [:]
    
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
            
            print("\(result?.trackable.identifier)")
            print("\(result?.trackable.name)")
            
            let trackerableName = result?.trackable.name
            if trackerableName == "stones" {
                boxMaterial.diffuse.contents = UIColor.red
                
                if lastSceneName != "stones" {
                    manager.eaglView.setNeedsChangeSceneWithUserInfo(["scene" : "stones"])
                    lastSceneName = "stones"
                }
            } else if trackerableName == "Philips_ad_single_image_test" {
                if lastSceneName != "philips" {
                    manager.eaglView.setNeedsChangeSceneWithUserInfo(["scene" : "philips"])
                    lastSceneName = "philips"
                }
            } else {
                //                boxMaterial.diffuse.contents = UIColor.blue
                //                boxMaterial.diffuse.contents = UIColor.black
                
                if lastSceneName != "chips" {
                    manager.eaglView.setNeedsChangeSceneWithUserInfo(["scene" : "chips"])
                    lastSceneName = "chips"
                }
            }
            
        }
    }
}

extension VuforiaViewController: VuforiaEAGLViewSceneSource, VuforiaEAGLViewDelegate {
    
    func collada2SCNNode(filepath:String) -> SCNNode {
        
        let node = SCNNode()
        let scene = SCNScene(named: filepath)
        let nodeArray = scene!.rootNode.childNodes
        
        for childNode in nodeArray {
            node.addChildNode(childNode as SCNNode)
        }
        
        return node
    }
    
    func scene(for view: VuforiaEAGLView!, userInfo: [String : Any]?) -> SCNScene! {
        guard let userInfo = userInfo else {
            print("default scene")
            return createStonesScene(with: view)
        }
        
        guard let sceneName = userInfo["scene"] as? String else {
            fatalError("Scene got messed up yo...")
        }
        
        // Turn this into a switch statement later
        if sceneName == "stones" {
            print("stones scene")
            return createStonesScene(with: view)
        } else if sceneName == "chips" {
            print("chips scene")
            return createChipsScene(with: view)
        } else {
            print("philips scene")
            return createAdvertisementScene(with: view)
        }
    }
    
    fileprivate func createStonesScene(with view: VuforiaEAGLView) -> SCNScene {
        let scene = SCNScene()
        
        let lightNode = SCNNode()
        lightNode.light = SCNLight()
        lightNode.light?.type = .omni
        lightNode.light?.color = UIColor.lightGray
        lightNode.position = SCNVector3(x:0, y:10, z:10)
        scene.rootNode.addChildNode(lightNode)
        
        let ambientLightNode = SCNNode()
        ambientLightNode.light = SCNLight()
        ambientLightNode.light?.type = .ambient
        ambientLightNode.light?.color = UIColor.darkGray
        scene.rootNode.addChildNode(ambientLightNode)
        
        let planeNode = SCNNode()
        planeNode.name = "plane"
        
        if let stoneSize = imageTargetSizes["stones"] {
            planeNode.geometry = SCNPlane(width: stoneSize.0/view.objectScale, height: stoneSize.1/view.objectScale)
        }
        // Set size of plane to cover the whole marker; marker dimensions according to marker XML file
        
        
        planeNode.position = SCNVector3Make(0, 0, -15)
        let planeMaterial = SCNMaterial()
        planeMaterial.diffuse.contents = UIColor.green
        planeMaterial.transparency = 0.6
        planeNode.geometry?.firstMaterial = planeMaterial
        scene.rootNode.addChildNode(planeNode)
        
        let boxNode = SCNNode()
        boxNode.name = "box"
        boxNode.geometry = SCNBox(width:1, height:1, length:1, chamferRadius:0.0)
        boxNode.geometry?.firstMaterial = boxMaterial
        //        boxNode.position = SCNVector3Make(0, 0, -15);
        scene.rootNode.addChildNode(boxNode)
        
        return scene
    }
    
    fileprivate func createChipsScene(with view: VuforiaEAGLView) -> SCNScene {
        let scene = SCNScene()
        
        boxMaterial.diffuse.contents = UIColor.lightGray
        
        let lightNode = SCNNode()
        lightNode.light = SCNLight()
        lightNode.light?.type = .omni
        lightNode.light?.color = UIColor.lightGray
        lightNode.position = SCNVector3(x:0, y:10, z:10)
        scene.rootNode.addChildNode(lightNode)
        
        let ambientLightNode = SCNNode()
        ambientLightNode.light = SCNLight()
        ambientLightNode.light?.type = .ambient
        ambientLightNode.light?.color = UIColor.darkGray
        scene.rootNode.addChildNode(ambientLightNode)
        
        let planeNode = SCNNode()
        planeNode.name = "plane"
        if let chipSize = imageTargetSizes["chips"] {
            planeNode.geometry = SCNPlane(width: chipSize.0/view.objectScale, height: chipSize.1/view.objectScale)
        }
        
        planeNode.geometry = SCNPlane(width: 0.247/view.objectScale, height: 0.173/view.objectScale)
        planeNode.position = SCNVector3Make(0, 0, -1)
        let planeMaterial = SCNMaterial()
        planeMaterial.diffuse.contents = UIColor.red
        planeMaterial.transparency = 0.6
        planeNode.geometry?.firstMaterial = planeMaterial
        scene.rootNode.addChildNode(planeNode)
        
        let boxNode = SCNNode()
        boxNode.name = "box"
        boxNode.geometry = SCNBox(width:1, height:1, length:1, chamferRadius:0.0)
        boxNode.geometry?.firstMaterial = boxMaterial
        scene.rootNode.addChildNode(boxNode)
        
        return scene
    }
    
    fileprivate func createAdvertisementScene(with view: VuforiaEAGLView) -> SCNScene {
        let scene = SCNScene()
        
        boxMaterial.diffuse.contents = UIColor.darkGray
        
        //        let iphoneNode = collada2SCNNode(filepath: "iPhone.dae")
        //        iphoneNode.geometry?.firstMaterial = boxMaterial
        //        scene.rootNode.addChildNode(iphoneNode)
        
        // Load the .OBJ file
        guard let url = Bundle.main.url(forResource: "bulb", withExtension: "obj") else { fatalError("Failed to find model file.") }
        //        guard let url = Bundle.main.url(forResource: "bmw", withExtension: "obj") else { fatalError("Failed to find model file.") }
        guard let object = MDLAsset(url: url).object(at: 0) as? MDLMesh else { fatalError("Failed to get mesh from asset.") }
        
        let car = SCNNode(mdlObject: object)
        
        if let carGeometry = car.geometry {
            for index in 0 ..< carGeometry.materials.count {
                carGeometry.materials[index] = boxMaterial
            }
        }
        
        //        car.position = SCNVector3Make(0, 0, -200)
        //        let modelScale: Float = 0.01
        let modelScale: Float = 0.5 // 0.005
        car.scale = SCNVector3(x: modelScale, y: modelScale, z: modelScale)
        car.eulerAngles = SCNVector3Make(Float(M_PI_2), 0, 0)
        
        
        scene.rootNode.addChildNode(car)
        
        return scene
    }
    
    func vuforiaEAGLView(_ view: VuforiaEAGLView!, didTouchDownNode node: SCNNode!) {
        print("touch down \(node.name)\n")
        boxMaterial.transparency = 0.7
        boxMaterial.diffuse.contents = UIColor.white
    }
    
    func vuforiaEAGLView(_ view: VuforiaEAGLView!, didTouchUp node: SCNNode!) {
        print("touch up \(node.name)\n")
        boxMaterial.transparency = 1.0
        boxMaterial.diffuse.contents = UIColor.darkGray
    }
    
    func vuforiaEAGLView(_ view: VuforiaEAGLView!, didTouchCancel node: SCNNode!) {
        print("touch cancel \(node.name)\n")
        boxMaterial.transparency = 1.0
        boxMaterial.diffuse.contents = UIColor.darkGray
    }
}

