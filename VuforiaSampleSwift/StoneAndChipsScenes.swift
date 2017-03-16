extension VuforiaViewController {
    func createStonesScene(with view: VuforiaEAGLView) -> SCNScene {
        return createGenericDemoScene(view, targetName: "stones", planeColor: .green)
    }
    
    func createChipsScene(with view: VuforiaEAGLView) -> SCNScene {
        return createGenericDemoScene(view, targetName: "chips", planeColor: .blue)
    }
    
    func createGenericDemoScene(_ view: VuforiaEAGLView, targetName: String, planeColor: UIColor) -> SCNScene {
        let scene = SCNScene()

        // Shading for the sides of the box
        let lightNode = SCNNode()
        lightNode.light = SCNLight()
        lightNode.light?.type = .omni
        lightNode.light?.color = UIColor.lightGray
        lightNode.position = SCNVector3(x:0, y:10, z:10)
        scene.rootNode.addChildNode(lightNode)

        // General node lighting
        let ambientLightNode = SCNNode()
        ambientLightNode.light = SCNLight()
        ambientLightNode.light?.type = .ambient
        ambientLightNode.light?.color = UIColor.darkGray
        scene.rootNode.addChildNode(ambientLightNode)
        
        let planeNode = SCNNode()
        planeNode.name = "plane"

        // Set size of plane to cover the whole marker; marker dimensions according to marker XML file
        if let imageTargetSize = imageTargetSizes[targetName] {
            planeNode.geometry = SCNPlane(width: imageTargetSize.0/view.objectScale, height: imageTargetSize.1/view.objectScale)
        }
        
        // Plane that lays upon the images
        let planeMaterial = SCNMaterial()
        planeMaterial.diffuse.contents = planeColor
        planeMaterial.transparency = 0.6
        planeNode.geometry?.firstMaterial = planeMaterial
        scene.rootNode.addChildNode(planeNode)
        
        // Box node
        let boxNode = SCNNode()
        boxNode.name = "box"
        boxNode.geometry = SCNBox(width:1, height:1, length:1, chamferRadius:0.0)
        boxNode.geometry?.firstMaterial = modelTexture
        scene.rootNode.addChildNode(boxNode)
        
        return scene
    }
}
