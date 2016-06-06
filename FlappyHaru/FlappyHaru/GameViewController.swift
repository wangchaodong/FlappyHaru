//
//  GameViewController.swift
//  FlappyHaru
//
//  Created by devil wang on 6/4/16.
//  Copyright (c) 2016 devil wang. All rights reserved.
//

import UIKit
import SpriteKit

//struct MyNotification {
//    static let showGameSceneNoti = "showGameSceneNoti"
//}

class GameViewController: UIViewController {
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        showGameScene()
//        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(showGameScene), name: MyNotification.showGameSceneNoti, object: nil)
    }
    
    func showGameScene()
    {
        if let skview = self.view as? SKView {
            if skview.scene == nil {
                // create scene
                
                let whScale = skview.bounds.size.height / skview.bounds.size.width
                let scene = GameScene(size: CGSize(width: 320, height: 320 * whScale))
                skview.showsFPS = true
                skview.showsNodeCount = true
                skview.showsPhysics = false
                skview.ignoresSiblingOrder = true
                
                scene.scaleMode = .AspectFill
                
                skview.presentScene(scene)
                
            }
        }
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
}
