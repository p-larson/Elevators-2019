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
    
    public override func viewDidLoad() {
        scoreboard.text = "Score: \(score)"
    }
    
    @IBAction func onPlayAgainPress(_ sender: UIButton) {
        if let gameview = gameview {
            gameview.game = gameview.newGameScene()
            gameview.viewDidLoad()
        }
        self.dismiss(animated: true, completion: nil)
    }
    
}
