//
//  ViewController.swift
//  AR Shop
//
//  Created by Kohinoor on 14/08/19.
//  Copyright © 2019 Kohinoor. All rights reserved.
//

import UIKit
import ARKit

class ViewController: UIViewController, UICollectionViewDataSource {

    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var sceneView: ARSCNView!
    
    let config = ARWorldTrackingConfiguration()
    
    let itemsArray = ["cup", "vase", "boxing", "table"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.collectionView.dataSource = self
        sceneView.debugOptions = [.showWorldOrigin, .showFeaturePoints]
        self.sceneView.session.run(config)
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return itemsArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "item", for: indexPath)
        return cell
    }

}

