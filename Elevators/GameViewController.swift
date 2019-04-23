//
//  GameViewController.swift
//  Elevators
//
//  Created by Peter Larson on 1/29/19.
//  Copyright © 2019 Peter Larson. All rights reserved.
//

import UIKit
import SpriteKit
import GameplayKit

public class GameViewController: UIViewController {
    
    @IBOutlet public weak var gameview: SKView!
    @IBOutlet public weak var scoreboard: UILabel!
    
    public lazy var game: GameScene = {
        let scene = GameScene()
        scene.scaleMode = .aspectFill
        scene.size = view.frame.size
        scene.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        scene.backgroundColor = UIColor.clear
        scene.scoreboardLabel = self.scoreboard
        return scene
    }()
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        gameview.allowsTransparency = true
        gameview.presentScene(game)
        scoreboard.textColor = .white
    }
    
    override public var shouldAutorotate: Bool {
        return false
    }
    
    override public var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        if UIDevice.current.userInterfaceIdiom == .phone {
            return .allButUpsideDown
        } else {
            return .all
        }
    }
    
    override public var prefersStatusBarHidden: Bool {
        return true
    }
}
