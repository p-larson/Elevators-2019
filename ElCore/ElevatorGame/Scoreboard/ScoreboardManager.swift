//
//  ScoreboardManager.swift
//  ElCore
//
//  Created by Peter Larson on 4/21/19.
//  Copyright © 2019 Peter Larson. All rights reserved.
//

import Foundation

public class ScoreboardManager: ElevatorsGameSceneDependent {
    
    public let scene: ElevatorsGameScene
    
    private(set) public var score: Int = 0 {
        didSet {
            scene.scoreboardLabel?.text = String(score)
            
            UIView.animate(
                withDuration: 0.1,
                delay: 0,
                options: UIView.AnimationOptions.curveEaseIn,
                animations: {
                
                guard let label = self.scene.scoreboardLabel else {
                    return
                }
                
                label.transform = CGAffineTransform(scaleX: 1.1, y: 1.1)
            }) { (success) in
                
                if success == false {
                    return
                }
                
                self.scene.movementManager.haptics.impactOccurred()
                
                UIView.animate(
                    withDuration: 0.1,
                    delay: 0,
                    options: UIView.AnimationOptions.curveEaseOut,
                    animations: {
                    guard let label = self.scene.scoreboardLabel else {
                        return
                    }
                    
                    label.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
                })
            }
        }
    }
    
    public func land(on: Floor) {
        score = on.number
    }
    
    public func increment() {
        score += 1
    }
    
    public func setupScoreboard() {
        self.score = 0
    }
    
    public init(scene: ElevatorsGameScene) {
        self.scene = scene
    }
}
