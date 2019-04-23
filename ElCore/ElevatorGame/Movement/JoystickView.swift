//
//  JoystickView.swift
//  ElCore
//
//  Created by Peter Larson on 4/10/19.
//  Copyright © 2019 Peter Larson. All rights reserved.
//

import Foundation
import UIKit
import SpriteKit

public protocol JoystickDelegate {
    func moveLeft(_ view: JoystickView)
    func moveRight(_ view: JoystickView)
    func moveUp(_ view: JoystickView)
    func moveDown(_ view: JoystickView)
}

public class JoystickView: UIView, ElevatorsGameSceneDependent {
    
    public enum Move {
        case Left
        case Right
        case Up
        case Down
    }
    
    public let scene: ElevatorsGameScene
    
    public private(set) var lastMove: Move? = nil
    
    public var delegate: JoystickDelegate? = nil
    
    public var origin: CGPoint? = nil
    
    public var compare: CGPoint? = nil
    
    private var timer: Timer? = nil
    
    private func setupTimer() {
        self.timer = Timer.scheduledTimer(withTimeInterval: scene.joystickRollover, repeats: true, block: check)
    }
    
    private func startTimer() {
        self.setupTimer()
    }
    
    private func stopTimer() {
        self.timer?.invalidate()
    }
    
    public override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        origin = touches.first?.location(in: self)
        self.startTimer()
    }
    
    public override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        origin = nil
        compare = nil
        lastMove = nil
        self.stopTimer()
    }
    
    public override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        compare = touches.first?.location(in: self)
    }
    
    public func check(_ timer: Timer) {
        guard let origin = origin, let compare = compare else {
            return
        }
        
        let dx = origin.x - compare.x
        let dy = origin.y - compare.y
        
        if let lastMove = lastMove {
            if dx < scene.joystickThreshhold && dy < scene.joystickThreshhold {
                switch lastMove {
                case .Left:
                    delegate?.moveLeft(self)
                    return
                case .Right:
                    delegate?.moveRight(self)
                    return
                case .Up:
                    delegate?.moveUp(self)
                    return
                case .Down:
                    delegate?.moveDown(self)
                    return
                }
            }
        }
        // Test if dx is major else dy
        if abs(dx) > abs(dy) {
            // Check if compare is left else right
            if compare.x < origin.x {
                delegate?.moveLeft(self)
                lastMove = .Left
            } else {
                delegate?.moveRight(self)
                lastMove = .Right
            }
        } else {
            // Check if compare is up else down
            if compare.y < origin.y {
                delegate?.moveUp(self)
                lastMove = .Up
            } else {
                delegate?.moveDown(self)
                lastMove = .Down
            }
        }
        
        self.origin = compare
    }
    
    public init(scene: ElevatorsGameScene, frame: CGRect) {
        self.scene = scene
        super.init(frame: frame)
        self.isUserInteractionEnabled = true
    }
    
    public required init?(coder aDecoder: NSCoder) {
        return nil
    }
}
