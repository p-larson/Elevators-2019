//
//  HomeViewController.swift
//  Elevators
//
//  Created by Peter Larson on 4/23/19.
//  Copyright © 2019 Peter Larson. All rights reserved.
//

import UIKit
import ElCore

public class HomeViewController: UIViewController {
    
    public var score: Int = 0
    
    public var gamemode: Elevators.Gamemode = .levels {
        didSet {
            if oldValue != gamemode {
                self.updateGamemode()
            }
        }
    }
    
    @IBOutlet weak var recordboard: UIButton!
    @IBOutlet weak var scoreboard: UILabel!
    @IBOutlet weak var playAgain: UIButton!
    
    @IBOutlet weak var elevators: UIButton!
    @IBOutlet weak var characters: UIButton!
    @IBOutlet weak var dailyprize: UIButton!
    
    @IBOutlet weak var gamemodeStackView: UIStackView!
    @IBOutlet weak var freeplayButton: UIButton!
    @IBOutlet weak var levelsButton: UIButton!
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    @IBAction func freeplaySelected(_ sender: Any) {
        self.gamemode = .freeplay
    }
    
    
    @IBAction func levelsSelected(_ sender: Any) {
        self.gamemode = .levels
    }
}

extension HomeViewController {
    static let levelsSegue = "levelsSegue"
}

extension HomeViewController: ControllerIdentifiable {
    public static let id: String = "HomeViewController"
}

extension HomeViewController {
    public override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        
        if identifier == HomeViewController.levelsSegue {
            return gamemode == .levels
        }
        
        return true
    }
}

extension HomeViewController {
    @IBAction func onPlayAgainPress(_ sender: UIButton) {
        guard let vc = Storyboard.Game.instance.instantiateInitialViewController() as? GameViewController else {
            return
        }
        
        present(vc, animated: true, completion: nil)
    }
}

extension HomeViewController {
    public func attributes(frame: CGRect, font: UIFont, one: String, two: String) -> NSAttributedString {
        let attributed = NSMutableAttributedString()
        
        attributed.append(NSAttributedString(string: one, attributes: [
            NSAttributedString.Key.font:font.withSize(frame.height / 5)]
        ))
        
        attributed.append(NSAttributedString(string: "\n"))
        
        attributed.append(NSAttributedString(string: two, attributes:
            [NSAttributedString.Key.font:font.withSize(frame.height / 3)]
        ))
        
        let style = NSMutableParagraphStyle()
        
        style.alignment = .justified
        
        if let range = NSRange(attributed.string) {
            attributed.addAttribute(NSAttributedString.Key.paragraphStyle, value: style, range: range)
            attributed.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor.white, range: range)
        }
        
        
        return attributed
    }
}

extension HomeViewController {
    public override func viewDidLoad() {
        self.definesPresentationContext = true
        self.modalPresentationStyle = .custom
        self.recordboard.setTitle(String(), for: .normal)
        
        scoreboard.attributedText = self.attributes(frame: scoreboard.frame, font: scoreboard.font, one: "Score", two: String(score))
        
        recordboard.setAttributedTitle(attributes(frame: recordboard.frame, font: scoreboard.font, one: "Record", two: "159"), for: .normal)
    
        
        [view, playAgain, scoreboard, recordboard, elevators, characters, dailyprize, freeplayButton, levelsButton].forEach { (view) in
            view?.adjust()
        }
        
        self.setupButtons()
        self.setupGamemode()
    }
}

extension HomeViewController {
    func setupButtons() {
        
        let buttons = [elevators, characters, dailyprize]
        
        [UIControl.State.normal, UIControl.State.highlighted].forEach { (state) in
            elevators.setTitle("Elevators", for: state)
            characters.setTitle("Characters", for: state)
            dailyprize.setTitle("Daily Prize", for: state)
        }
        
        elevators.setImage(#imageLiteral(resourceName: "elevator iocn"), for: .normal)
        characters.setImage(#imageLiteral(resourceName: "blank character icon"), for: .normal)
        dailyprize.setImage(#imageLiteral(resourceName: "present icon"), for: .normal)
        
        buttons.forEach { (button) in
            guard let button = button else {
                return
            }
            
            let set = abs(button.frame.width - button.frame.height)
            
            button.imageEdgeInsets = UIEdgeInsets(top: 0, left: set, bottom: 0, right: set)
            
            button.setTitleColor(button.backgroundColor?.darker(by: 15), for: .normal)
            button.setTitleColor(button.backgroundColor?.darker(by: 30), for: .highlighted)
            
            button.tintColor = .white
            button.imageView?.contentMode = .scaleAspectFit
            
            button.setNeedsLayout()
            button.layoutIfNeeded()
        }
    }
}

extension HomeViewController {
    
    func updateGamemode() {
        
        print(gamemode)
        
        let duration = 0.3
        
        UIView.animate(withDuration: duration) {
            let gm = self.gamemode
            let z = CGFloat(95.0 / 100.0)
            
            self.freeplayButton.transform = gm == .freeplay ? CGAffineTransform(scaleX: 1, y: 1) : CGAffineTransform(scaleX: z, y: z)
            self.freeplayButton.alpha = gm == .freeplay ? 1.0 : z
            
            self.levelsButton.transform = gm == .levels ? CGAffineTransform(scaleX: 1, y: 1) : CGAffineTransform(scaleX: z, y: z)
            self.levelsButton.alpha = gm == .levels ? 1.0 : z
        }
        
        let animation1 = self.freeplayButton.highlightAnimation(duration: duration, reversed: gamemode != .freeplay)

        self.freeplayButton.layer.add(animation1, forKey: "switch")

        let animation2 = self.levelsButton.highlightAnimation(duration: duration, reversed: gamemode != .levels)

        self.levelsButton.layer.add(animation2, forKey: "switch")
        
        self.setupGamemode()
    }
    
    func setupGamemode() {
        
        let z = CGFloat(95.0 / 100.0)
        
        switch gamemode {
        case .freeplay:
            freeplayButton.alpha = 1
            freeplayButton.layer.borderWidth = freeplayButton.borderWidth
            freeplayButton.layer.borderColor = freeplayButton.highlightedBorder.cgColor
            
            levelsButton.alpha = z
            levelsButton.layer.borderWidth = 0
            levelsButton.layer.borderColor = UIColor.clear.cgColor
            
            break
        case .levels:
            levelsButton.alpha = 1
            levelsButton.layer.borderWidth = levelsButton.borderWidth
            levelsButton.layer.borderColor = levelsButton.highlightedBorder.cgColor
            
            freeplayButton.alpha = z
            freeplayButton.layer.borderWidth = 0
            freeplayButton.layer.borderColor = UIColor.clear.cgColor
            
            break
        }
    }
}
