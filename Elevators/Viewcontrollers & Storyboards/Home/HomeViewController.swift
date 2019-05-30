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
    
    @IBOutlet weak var lengthConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var countersView: UIStackView!
    
    @IBOutlet weak var scoresView: UIView!
    @IBOutlet weak var cell1: AttributedImageTextView!
    @IBOutlet weak var cell2: AttributedImageTextView!
    
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
    public override func viewDidLoad() {
        self.definesPresentationContext = true
        self.modalPresentationStyle = .custom
        
        [view, playAgain, cell1, cell2, elevators, characters, dailyprize, freeplayButton, levelsButton].forEach { (view) in
            view?.adjust()
        }
        
        self.setupButtons()
        self.setupGamemode()
        self.setupCounters()
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
            
            button.titleLabel?.numberOfLines = 0
            button.titleLabel?.lineBreakMode = .byWordWrapping
            
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
    
    var lengthConstraintConstant: CGFloat {
        return gamemode == .levels ? 0 : scoresView.frame.width / 4
    }
    
    func updateGamemode() {
        
        print(gamemode)
        
        let duration = 0.3
        
        self.updateGamemodeText()
        
        self.lengthConstraint.constant = lengthConstraintConstant
        
        UIView.animate(withDuration: duration) {
            let gm = self.gamemode
            let z = CGFloat(95.0 / 100.0)

            self.freeplayButton.transform = gm == .freeplay ? CGAffineTransform(scaleX: 1, y: 1) : CGAffineTransform(scaleX: z, y: z)
            self.freeplayButton.alpha = gm == .freeplay ? 1.0 : z

            self.levelsButton.transform = gm == .levels ? CGAffineTransform(scaleX: 1, y: 1) : CGAffineTransform(scaleX: z, y: z)
            self.levelsButton.alpha = gm == .levels ? 1.0 : z

            self.scoresView.layoutIfNeeded()
        }
        
        freeplayButton.highlight(duration: duration, gamemode == .freeplay)
        levelsButton.highlight(duration: duration, gamemode == .levels)
    }
    
    func updateGamemodeText() {
        if gamemode == .freeplay {
            cell1.set(text1: "Score", text2: String(score))
            cell2.set(text1: "Record", text2: "159")
        }
        
        if gamemode == .levels {
            cell1.set(text1: "Score", text2: String(score))
            cell2.set(text1: "Level", text2: "24")
        }
    }
    
    func setupGamemode() {
        
        self.updateGamemodeText()
        
        let z = CGFloat(95.0 / 100.0)
        
        switch gamemode {
        case .freeplay:
            freeplayButton.alpha = 1
            freeplayButton.highlight(duration: nil, true)
            
            levelsButton.alpha = z
            levelsButton.highlight(duration: nil, false)
            
            break
        case .levels:
            levelsButton.alpha = 1
            levelsButton.highlight(duration: nil, true)
            
            freeplayButton.alpha = z
            freeplayButton.highlight(duration: nil, false)
            
            break
        }
    }
}

extension HomeViewController {
    func setupCounters() {
        // Clear the Placeholder views from the storyboard
        countersView.subviews.forEach { (view) in
            countersView.removeArrangedSubview(view)
            view.removeFromSuperview()
        }
        
        [CounterView.Kind.coin, CounterView.Kind.gem, CounterView.Kind.heart].forEach { (kind) in
            let view = CounterView()
            view.kind = kind
            view.string = String(Int.random(in: 1 ... 1578))
            self.countersView.addArrangedSubview(view)
        }
        
        countersView.setNeedsLayout()
        countersView.layoutIfNeeded()
    }
}
