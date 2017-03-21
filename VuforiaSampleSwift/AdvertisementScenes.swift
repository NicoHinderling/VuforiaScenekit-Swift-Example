extension VuforiaViewController {
    func createPhilipsScene(with view: VuforiaEAGLView) -> SCNScene {
        return createGenericOBJModelScene(view, targetName: "philipsAd", modelFileTitle: "bulb", modelScale: 0.35)
    }
    
    func createBmwScene(with view: VuforiaEAGLView) -> SCNScene {
        return createGenericOBJModelScene(view, targetName: "bmwAd", modelFileTitle: "bmw", modelScale: 0.015)
    }

    func createIphoneScene(with view: VuforiaEAGLView) -> SCNScene {
        // This one doesn't look very great at the moment... will clean up genericDAEModel scenes later
        return createGenericDAEModelScene(view, targetName: "iphoneAd", modelFileName: "iPhone.dae")
    }
    
    func createGenericOBJModelScene(_ view: VuforiaEAGLView, targetName: String, modelFileTitle: String, modelScale: Float) -> SCNScene {
        let scene = SCNScene()
        
        guard let url = Bundle.main.url(forResource: modelFileTitle, withExtension: "obj") else {
            fatalError("Failed to find model file.")
        }
        guard let object = MDLAsset(url: url).object(at: 0) as? MDLMesh else {
            fatalError("Failed to get mesh from asset.")
        }
        
        let model = SCNNode(mdlObject: object)
        
        if let modelGeometry = model.geometry {
            for index in 0 ..< modelGeometry.materials.count {
                modelGeometry.materials[index] = modelTexture
            }
        }
        
        // Hacky way of scaling the models to a reasonable size. 
        // This won't be an issue if the target width is correctly given upon creation of the xml database file
        model.scale = SCNVector3(x: modelScale, y: modelScale, z: modelScale)

        // Rotate the model to lay on the ad facing "up"
        model.eulerAngles = SCNVector3Make(Float(M_PI_2), 0, -Float(M_PI_2))
        
        scene.rootNode.addChildNode(model)
        return scene

    }
    
    func collada2SCNNode(filepath:String) -> SCNNode {
        
        let node = SCNNode()
        let scene = SCNScene(named: filepath)
        let nodeArray = scene!.rootNode.childNodes
        
        for childNode in nodeArray {
            node.addChildNode(childNode as SCNNode)
        }
        
        return node
    }
    
    func createGenericDAEModelScene(_ view: VuforiaEAGLView, targetName: String, modelFileName: String) -> SCNScene {
        let scene = SCNScene()
    
        let model = collada2SCNNode(filepath: modelFileName)
        model.geometry?.firstMaterial = modelTexture
        
        scene.rootNode.addChildNode(model)
        return scene
    }
}
