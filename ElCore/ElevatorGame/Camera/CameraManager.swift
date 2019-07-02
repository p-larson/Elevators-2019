//
//  CameraManager.swift
//  ElCore
//
//  Created by Peter Larson on 2/24/19.
//  Copyright © 2019 Peter Larson. All rights reserved.
//

import Foundation
import SpriteKit

public class CameraManager: ElevatorsGameSceneDependent {
    
    private let camera: SKCameraNode
    public let scene: ElevatorsGameScene
    
    public func setupCamera() {
        self.scene.addChild(self.camera)
        self.scene.camera = self.camera
    }
    
    public func zoom(out by: CGFloat) {
        camera.xScale += by
        camera.yScale += by
    }
    
    public var position: CGPoint {
        return camera.position
    }
    
    public var basePosition: CGPoint {
        return CGPoint.zero
    }
    
    public func isRunningAction(named key: String) -> Bool {
        return camera.action(forKey: key) != nil
    }
    
    public func run(action: SKAction, key: String) {
        camera.run(action, withKey: key)
    }
    
    public func stopAction(named: String) {
        camera.removeAction(forKey: named)
    }
    
    public func movement(dx: CGFloat, dy: CGFloat, duration: TimeInterval) -> SKAction {
        let move = SKAction.moveBy(x: dx, y: dy, duration: duration)
        move.timingMode = .easeInEaseOut
        return move
    }
    
    public func move(_ action: SKAction, completion: BlockOperation? = nil) {
        camera.run(SKAction.withCompletionHandler(action, completion: completion))
    }
    
    public func set(_ point: CGPoint) {
        camera.position = point
    }
    
    public var isMoving: Bool {
        return camera.hasActions()
    }

    public init(scene: ElevatorsGameScene) {
        self.camera = SKCameraNode()
        self.scene = scene
    }
}
