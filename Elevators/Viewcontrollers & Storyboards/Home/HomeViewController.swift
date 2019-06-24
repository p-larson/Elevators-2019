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
    
    fileprivate weak static var current: HomeViewController? = nil
    
    public var score: Int = 0
    
    public var gamemode: Elevators.Gamemode = .levels
    
    @IBOutlet weak var lengthConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var countersView: UIStackView!
    
    @IBOutlet weak var cell1: AttributedImageTextView!
    @IBOutlet weak var cell2: AttributedImageTextView!
    
    @IBOutlet public weak var freeplay: LarsonView!
    @IBOutlet public weak var levels: LarsonView!
    
    @IBOutlet weak var scoreView: LarsonView!
    @IBOutlet weak var recordView: LarsonView!
    
    @IBOutlet weak var dailyPrizeView: LarsonView!
    
    @IBOutlet weak var recordWidthConstraint: NSLayoutConstraint!
    
    public let recordWidthConstantLevels: CGFloat = -10
    
    public var recordWidthConstantFreeplay: CGFloat {
        return recordWidthConstantLevels - view.frame.width / 8
    }
    
    public var haptics: UIImpactFeedbackGenerator!
    
    public var switchLevels: LarsonView.LarsonInteraction = { (larsonview) in
        
        guard larsonview.state == .unselected else {
            return
        }
        
        // Stupid stupid stupid
        guard let controller: HomeViewController = HomeViewController.current else {
            return
        }
        
        switch controller.gamemode {
        case .freeplay:

            controller.freeplay.setState(to: .unselected, animated: true)
            controller.freeplay.isPressable = true
            controller.levels.setState(to: .selected, animated: true)
            controller.levels.isPressable = false
            
            controller.gamemode = .levels
            
            break
        case .levels:

            controller.freeplay.setState(to: .selected, animated: true)
            controller.freeplay.isPressable = false
            controller.levels.setState(to: .unselected, animated: true)
            controller.levels.isPressable = true

            controller.gamemode = .freeplay
            break
        }
        
        
        UIView.animate(withDuration: 0.125, delay: 0.0, options: .curveEaseOut, animations: {
            [controller.recordView, controller.scoreView].forEach({ (view) in
                view?.subviews.forEach({ (subview) in
                    subview.alpha = 0.0
                })
            })
        }) { (success) in
            
            controller.recordWidthConstraint.constant = controller.recordWidthConstantFreeplay
            
            switch controller.gamemode {
            case .freeplay:
                controller.recordWidthConstraint.constant = controller.recordWidthConstantFreeplay
                break
            case .levels:
                controller.recordWidthConstraint.constant = controller.recordWidthConstantLevels
                break
            }
            
            controller.updateBoards()
            
            UIView.animate(withDuration: 0.125, delay: 0.0, options: .curveEaseOut, animations: {
                controller.view.layoutIfNeeded()
            }) {
                (success) in
                
                [controller.recordView, controller.scoreView].forEach({ (view) in
                    UIView.animate(withDuration: 0.125, delay: 0.0, options: .curveEaseOut, animations: {
                        view?.subviews.forEach({ (subview) in
                            subview.alpha = 1.0
                        })
                    }, completion: nil)
                })
            }
        }
    }
    
    
    @IBOutlet weak var playAgain: LarsonView!
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
    }
}

extension HomeViewController {
    public func updateBoards() {
        switch gamemode {
        case .freeplay:
            
            scoreView.header = "Score"
            scoreView.body = "82"
            
            recordView.header = "Record"
            recordView.body = "99"
            
            break
        case .levels:
            
            scoreView.header = "Score"
            scoreView.body = "0"
            
            recordView.header = "Level"
            recordView.body = "12"
            
            break
        }
        
        scoreView.updateText()
        recordView.updateText()
    }
}

extension HomeViewController {
    public func jitterDailyPrize(continuos: Bool = true) {
        self.dailyPrizeView.imageView?.transform = CGAffineTransform(translationX: 0, y: CGFloat.random(in: 1.0 ... 5.0))
        
        UIView.animate(withDuration: 0.25, delay: TimeInterval(CGFloat.random(in: 0.0 ... 5.0)), usingSpringWithDamping: 0.4, initialSpringVelocity: 1.0, options: .curveEaseInOut, animations: {
            self.dailyPrizeView.imageView?.transform = CGAffineTransform.identity
        }) { (success) in
            if success {
                self.jitterDailyPrize()
            }
        }
    }
}

extension HomeViewController {
    public func updateLengthConstraint() {
        recordWidthConstraint.constant = recordWidthConstantFreeplay
        
        switch gamemode {
        case .freeplay:
            recordWidthConstraint.constant = recordWidthConstantFreeplay
            break
        case .levels:
            recordWidthConstraint.constant = recordWidthConstantLevels
            break
        }
        
        
        UIView.animate(withDuration: 5.0, delay: 0.0, options: .curveEaseOut, animations: {
            [self.recordView, self.scoreView].forEach({ (view) in
                view?.subviews.forEach({ (subview) in
                    subview.alpha = 0.0
                })
            })
            
            self.view.layoutIfNeeded()
        }) { (success) in
            
            self.updateBoards()
            
            [self.recordView, self.scoreView].forEach({ (view) in
                UIView.animate(withDuration: 5.0, delay: 0.0, options: .curveEaseOut, animations: {
                    view?.subviews.forEach({ (subview) in
                        subview.alpha = 1.0
                    })
                }, completion: nil)
            })
        }
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
        
        HomeViewController.current = self
        
        levels.text = "Levels"
        freeplay.text = "Free Play"
        playAgain.text = "Play Again"
        recordView.attributedText = LarsonView.headedBodyAttributedText
        recordView.header = "Record"
        recordView.body = "159"
        scoreView.attributedText = LarsonView.headedBodyAttributedText
        scoreView.header = "Score"
        scoreView.body = "0"
        
        self.jitterDailyPrize()
        
        self.haptics = UIImpactFeedbackGenerator.init(style: .heavy)
        
        self.setupCounters()
        
        
        [freeplay, levels].forEach { (larsonview) in
            larsonview?.endTouch = self.switchLevels
            larsonview?.onTouch = { _ in
                HomeViewController.current?.haptics.prepare()
            }
        }
        self.freeplay.endTouch = self.switchLevels
        self.levels.endTouch = self.switchLevels
    }
}

extension HomeViewController {
    
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
