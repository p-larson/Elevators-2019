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
    
    public func update(label: UILabel!, one: String, two: String) {
        let attributed = NSMutableAttributedString()
        
        attributed.append(NSAttributedString(string: one, attributes: [
            NSAttributedString.Key.font:label.font.withSize(label.frame.height / 5)]
        ))
        
        attributed.append(NSAttributedString(string: "\n"))
        
        attributed.append(NSAttributedString(string: two, attributes:
            [NSAttributedString.Key.font:label.font.withSize(label.frame.height / 3)]
        ))
        
        let style = NSMutableParagraphStyle()
        
        style.alignment = .justified
        
        if let range = NSRange(attributed.string) {
            attributed.addAttribute(NSAttributedString.Key.paragraphStyle, value: style, range: range)
        }
        
        label.numberOfLines = 0
        
        label.attributedText = attributed
    }
    
    public func adjust(_ view: UIView!) {
        view.layer.cornerRadius = view.frame.width / 25
        
        view.clipsToBounds = true
    }
    
    public weak var gameview: GameViewController? = nil
    
    @IBOutlet weak var recordboard: UILabel!
    @IBOutlet weak var scoreboard: UILabel!
    @IBOutlet weak var playAgain: UIButton!
    
    @IBOutlet weak var elevators: UILabel!
    @IBOutlet weak var skins: UILabel!
    @IBOutlet weak var dailyprize: UILabel!
    
    
    
    public override func viewDidLoad() {
        self.definesPresentationContext = true
        self.modalPresentationStyle = .custom
        self.update(label: scoreboard, one: "Score", two: String(self.score))
        self.update(label: recordboard, one: "Record", two: "159")
        
        [view, playAgain, scoreboard, recordboard, elevators, skins, dailyprize].forEach { (view) in
            if let view = view {
                self.adjust(view)
            }
        }
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
