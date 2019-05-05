//
//  HomeViewController.swift
//  Elevators
//
//  Created by Peter Larson on 4/23/19.
//  Copyright © 2019 Peter Larson. All rights reserved.
//

import UIKit

public class HomeViewController: UIViewController, ControllerIdentifiable {
    
    static let id: String = "HomeViewController"
    
    public var score: Int = 0
    public weak var gameview: GameViewController? = nil
    
    @IBOutlet weak var scoreboard: UILabel!
    @IBOutlet weak var playAgain: UIButton!
    
    public override func viewDidLoad() {
        scoreboard.text = "Score: \(score)"
        self.transitioningDelegate = self
    }
    
    @IBAction func onPlayAgainPress(_ sender: UIButton) {
        if let gameview = gameview {
            gameview.game = gameview.newGameScene()
            gameview.viewDidLoad()
            self.dismiss(animated: true)
        }
        
        print("play again")
    }
    
}

extension HomeViewController: UIViewControllerTransitioningDelegate {
    public func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        print("@home 1")
        return GameoverTransition(start: playAgain)
    }
    
    public func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        
        print("@home 2")
        
        return GameoverTransition(start: playAgain)
        
    }
}
