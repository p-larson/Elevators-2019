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
import ElCore

public class GameViewController: UIViewController, ControllerIdentifiable, EndGameDelegate {
    
    public func onEnd(score: Int) {
        
        guard let controller = self.storyboard?.instantiateViewController(withIdentifier: HomeViewController.id) as? HomeViewController else {
            return
        }
        
        controller.score = score
        controller.modalPresentationStyle = .custom
        
        present(controller, animated: true) {
            
        }
    }
    
    static let id: String = "GameViewController"
    
    @IBOutlet public private(set) weak var gameview: SKView!
    @IBOutlet public private(set) weak var scoreboard: UILabel!
    @IBOutlet public private(set) weak var backgroundImageView: UIImageView!
    
    public lazy var game: GameScene = {
        return self.newGameScene()
    }()
    
    public func newGameScene() -> GameScene {
        let scene = GameScene()
        scene.scaleMode = .aspectFill
        scene.size = view.frame.size
        scene.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        scene.backgroundColor = UIColor.clear
        scene.scoreboardLabel = self.scoreboard
        scene.endGameDelegate = self
        return scene
    }
    
    private func setupScoreboardLabel() {
        scoreboard.clipsToBounds = true
        scoreboard.layer.cornerRadius = scoreboard.layer.frame.height / 5
        scoreboard.layer.shadowOffset = CGSize(width: 0, height: scoreboard.layer.frame.height / 20)
        scoreboard.layer.shadowOpacity = 0.6
        scoreboard.layer.shadowRadius = 3.0
        scoreboard.layer.shadowColor = UIColor.red.cgColor
        scoreboard.adjustsFontSizeToFitWidth = true
        scoreboard.font = scoreboard.font.withSize(scoreboard.frame.height / 2)

    }
    
    private func loadBackground() {
        backgroundImageView.image = Assets.Background.GameView
    }
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        gameview.allowsTransparency = true
        gameview.presentScene(game)
        scoreboard.textColor = .white
        self.setupScoreboardLabel()
        self.loadBackground()
    }
    
    public override func viewDidAppear(_ animated: Bool) {
        
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
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}
