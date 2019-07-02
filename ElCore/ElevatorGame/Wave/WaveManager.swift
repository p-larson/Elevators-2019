//
//  WaveManager.swift
//  ElCore
//
//  Created by Peter Larson on 4/22/19.
//  Copyright © 2019 Peter Larson. All rights reserved.
//

import Foundation
import SpriteKit

public class WaveManager: ElevatorsGameSceneDependent {
    
    public let scene: ElevatorsGameScene
    
    public static let wave_move = "wave_move"
    
    public var isMoving: Bool {
        return scene.cameraManager.isRunningAction(named: WaveManager.wave_move)
    }
    
    public func stop() {
        guard isMoving else {
            return
        }
        scene.cameraManager.stopAction(named: WaveManager.wave_move)
    }
    
    public func start() {// Set up debug
        guard isMoving == false else {
            return
        }
        
        scene.cameraManager.run(action: .sequence([action, .run(end)]), key: WaveManager.wave_move)
    }
    
    public func end() {
        scene.endGameDelegate?.onEnd(score: scene.floorManager.currentFloorNumber)
    }
    
    public var action: SKAction {
        
        let distance = scene.frame.height - scene.gameFrame.height
        
        let destination = scene.cameraManager.basePosition.add(0, distance)
        
        let move = SKAction.move(to: destination, duration: scene.waveSpeed)
        
        return move
    }
    
    public init(scene: ElevatorsGameScene) {
        self.scene = scene
    }
}
