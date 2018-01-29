//
//  ViewController.swift
//  SnakeGameiOS
//
//  Created by AdnanZahid on 1/29/18.
//  Copyright © 2018 AdnanZahid. All rights reserved.
//

import UIKit
import CoreML
import SpriteKit

class ViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let scene = GameScene(size: view.bounds.size)
        let skView = view as! SKView
        skView.showsFPS = true
        skView.showsNodeCount = true
        skView.ignoresSiblingOrder = true
        scene.scaleMode = .resizeFill
        skView.presentScene(scene)
    }
}
