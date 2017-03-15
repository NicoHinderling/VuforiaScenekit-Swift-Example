//
//  ImageTargetParser.swift
//  VuforiaSampleSwift
//
//  Created by Nicolas Hinderling on 3/14/17.
//  Copyright © 2017 Yoshihiro Kato. All rights reserved.
//

class ImageTargetParser: NSObject {
    var parser: XMLParser
    var imageTargetSizes: [String: (CGFloat, CGFloat)] = [:]
    
    init(_ xmlFileName: String) {
        var xmlFileContents: String = ""
        let xmlFilePath = xmlFileName.characters.split{$0 == "."}.map(String.init)
        
        do {
            if let path = Bundle.main.path(forResource: xmlFilePath[0], ofType: xmlFilePath[1]) {
                xmlFileContents = try String(contentsOfFile: path)
            }
        } catch { print("error trying to read file \(xmlFileName)") }
        
        parser = XMLParser(data: xmlFileContents.data(using: String.Encoding.utf8)!)
        super.init()
        parser.delegate = self
        parser.parse()
    }
}

extension ImageTargetParser: XMLParserDelegate {
    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String] = [:]) {
        if elementName != "ImageTarget"  { return }
        
        // Get the image target values
        guard let name = attributeDict["name"] else { return }
        guard let size = attributeDict["size"] else { return }
        
        // Convert the sizes into an array of floats
        let sizeValues : [Double] = size.characters.split{$0 == " "}.map(String.init).flatMap{ Double($0) }
        
        // Make sure there are only two floats... should always be the case atm
        if sizeValues.count != 2 { return }
        
        imageTargetSizes[name] = (CGFloat(sizeValues[0]), CGFloat(sizeValues[1]))
    }
}



