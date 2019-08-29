//
//  ViewController.swift
//  AR Shop
//
//  Created by Kohinoor on 14/08/19.
//  Copyright © 2019 Kohinoor. All rights reserved.
//

import UIKit
import ARKit

class ViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, ARSCNViewDelegate {

    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var sceneView: ARSCNView!
    @IBOutlet weak var planeDetectionLabel: UILabel!
    
    let config = ARWorldTrackingConfiguration()
    
    let itemsArray = ["cup", "vase", "boxing", "table"]
    var selectedItem : String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.collectionView.dataSource = self
        self.collectionView.delegate = self
        self.sceneView.delegate = self
        
        self.registerGestureRecognizers()
        
        self.sceneView.autoenablesDefaultLighting = true
        self.config.planeDetection = .horizontal
        sceneView.debugOptions = [.showWorldOrigin, .showFeaturePoints]
        self.sceneView.session.run(config)
    }
    
    func registerGestureRecognizers() {
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(tapped))
        let pinchGestureRecognizer = UIPinchGestureRecognizer(target: self, action: #selector(pinched))
        let longPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(longPressed))
        longPressGestureRecognizer.minimumPressDuration = 0.1
        self.sceneView.addGestureRecognizer(tapGestureRecognizer)
        self.sceneView.addGestureRecognizer(pinchGestureRecognizer)
        self.sceneView.addGestureRecognizer(longPressGestureRecognizer)
    }
    
    @objc func tapped(sender : UITapGestureRecognizer) {
        let sceneView = sender.view as? ARSCNView
        let tapLocation = sender.location(in: sceneView)
        guard let hitTest = sceneView?.hitTest(tapLocation, types: .existingPlaneUsingExtent) else {return}
        if !hitTest.isEmpty {
            self.addItem(hitTestResult: hitTest.first!)
            print("touched a horizontal surface!")
        } else {
            print("no match")
        }
    }
    
    @objc func pinched (sender : UIPinchGestureRecognizer) {
        let sceneView = sender.view as? ARSCNView
        let pinchLocation = sender.location(in: sceneView)
        guard let hitTest = sceneView?.hitTest(pinchLocation) else {return}
        
        if !hitTest.isEmpty {
            let result = hitTest.first
            let node = result?.node
            let pinchAction = SCNAction.scale(by: sender.scale, duration: 0)
            node?.runAction(pinchAction)
            sender.scale = 1.0
        }
        
    }
    
    @objc func longPressed(sender : UILongPressGestureRecognizer) {
        let sceneView = sender.view as? ARSCNView
        let longPressLocation = sender.location(in: sceneView)
        guard let hitTest = sceneView?.hitTest(longPressLocation) else {return}
        
        if !hitTest.isEmpty {
            let result = hitTest.first
            let node = result?.node
            if sender.state == .began {
                let action = SCNAction.rotateBy(x: 0, y: CGFloat(360.degreeToRadians), z: 0, duration: 1)
                let forever = SCNAction.repeatForever(action)
                node?.runAction(forever)
            } else if sender.state == .ended {
                node?.removeAllActions()
            }
        }
    }
    
    func addItem (hitTestResult : ARHitTestResult) {
        if let selectedItem = self.selectedItem {
            let scene = SCNScene(named: "Models.scnassets/\(selectedItem).scn")
            guard let node = scene?.rootNode.childNode(withName: selectedItem, recursively: false) else {return}
            let transform = hitTestResult.worldTransform
            let thirdColumn = transform.columns.3
            node.position = SCNVector3(thirdColumn.x, thirdColumn.y, thirdColumn.z)
            if selectedItem == "table" {
                self.centerPivot(for: node)
            }
            self.sceneView.scene.rootNode.addChildNode(node)
        }
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        guard anchor is ARPlaneAnchor else {return}
        DispatchQueue.main.async {
            self.planeDetectionLabel.isHidden = false
            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                self.planeDetectionLabel.isHidden = true
            }
        }
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return itemsArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "item", for: indexPath) as! itemCell
        cell.itemLabel.text = self.itemsArray[indexPath.row]
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath)
        self.selectedItem = self.itemsArray[indexPath.row]
        cell?.backgroundColor = UIColor.green
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath)
        cell?.backgroundColor = UIColor(red: 0, green: 130, blue: 255, alpha: 1)
    }
    
    func centerPivot(for node: SCNNode) {
        let min = node.boundingBox.min
        let max = node.boundingBox.max
        node.pivot = SCNMatrix4MakeTranslation(
            min.x + (max.x - min.x)/2,
            min.y + (max.y - min.y)/2,
            min.z + (max.z - min.z)/2
        )
    }

}

extension Int {
    var degreeToRadians : Float {return Float(self) * .pi/180}
}
