//
//  MovementManager.swift
//  ElCore
//
//  Created by Peter Larson on 3/24/19.
//  Copyright © 2019 Peter Larson. All rights reserved.
//

import Foundation
import UIKit
import SpriteKit

public class MovementManager: ElevatorsGameSceneDependent {

    public var joystickView: JoystickView? = nil
    public let scene: ElevatorsGameScene
    public let haptics: UIImpactFeedbackGenerator
    
    public func setupJoystick() {
        // Set up debug
        larsonenter(#function)
        // Prepare for deinit of function.
        defer {
            larsonexit()
        }
        guard let view = scene.view else {
            larsondebug("could not setup joystick: view does not exist")
            return
        }
        
        joystickView = JoystickView.init(scene: scene, frame: scene.joystickFrame)
        
        joystickView!.delegate = self
        
        larsondebug("added joystick")
        
        view.addSubview(joystickView!)
    }
    
    private var cycling: Bool = false
    
    public var isCycling: Bool {
        return cycling
    }

    public func cycle(_ count: Int = 1, completion: (() -> ())? = nil) {
        // Set up debug
        larsonenter(#function)
        // Prepare for deinit of function.
        defer {
            larsonexit()
            self.cycling = false
        }
        guard !isCycling && count > 0 && count < scene.maxFloorsLoaded else {
            larsondebug("failed cycle attempt, leaving elevator.")
            self.exitElevator()
            return
        }
        
        larsondebug("cycling \(count) floors")
        
        self.cycling = true
        
        let waveOffset: CGFloat = scene.cameraManager.position.y - scene.cameraManager.basePosition.y
        let elevatorDistance: CGFloat = scene.floorManager.floorSize.height * CGFloat(count)
        let totalDuration: TimeInterval = scene.elevatorSpeed * Double(count)
        // Move the camera count floors up minus the move it's already
        let cameraMove = scene.cameraManager.movement(dx: 0, dy: elevatorDistance - waveOffset, duration: totalDuration)
        
        let elevatorMove = scene.cameraManager.movement(dx: 0, dy: elevatorDistance, duration: totalDuration)
        
        let scoreboardUpdate = SKAction.sequence([
            SKAction.wait(forDuration: scene.elevatorSpeed),
            SKAction.run {
            // Scoreboard update
            self.scene.scoreboardManager.increment()
        }])
        
        // Update scoreboard, by incrementing it every time the elevator passes a floor.
        self.scene.run(SKAction.repeat(scoreboardUpdate, count: count))
        
        self.scene.cameraManager.move(cameraMove, completion: {
            // Jostle the floors.
            self.scene.floorManager.jostle(count: count)
            // Reset camera position.
            self.scene.cameraManager.set(self.scene.cameraManager.basePosition)
            // Move the player to the floor's child hierarchy.
            self.scene.playerManager.player.move(toParent: self.scene.floorManager.bottomFloor)
            self.scene.playerManager.elevator?.move(toParent: self.scene.floorManager.bottomFloor)
            // After the move, reset the player's and elevator's y position
            self.scene.playerManager.player.position.y = self.scene.playerManager.playerBase.y
            self.scene.playerManager.elevator?.position.y = self.scene.floorManager.bottomFloor.elevatorY
            // Move Elevator to current floor and disable it.
            self.scene.playerManager.elevator?.isEnabled = false
            // Leave elevator
            self.exitElevator() 
            // Completion
            if let completionHandler = completion {
                completionHandler()
            }
            // Debug
            larsondebug("Moved back. Done with cycle.")
        })
        
//        // Move the Boarded Elevator to the Scene's child tree.
//        self.scene.playerManager.elevator?.move(toParent: scene)
        // Apply same action to the Elevator and Player.
        self.scene.playerManager.player.run(elevatorMove)
        self.scene.playerManager.elevator?.run(elevatorMove)
        
    }
    
    public init(scene: ElevatorsGameScene) {
        self.scene = scene
        self.haptics = UIImpactFeedbackGenerator(style: UIImpactFeedbackGenerator.FeedbackStyle.light)
    }
    
    public static let left_key_move = "move_left_key"
    public static let right_key_move = "move_right_key"
    public static let up_key_move = "move_up_key"
    public static let down_key_move = "move_down_key"
    
    public func stopMovement() {
        scene.playerManager.player.removeAction(forKey: MovementManager.left_key_move)
        scene.playerManager.player.removeAction(forKey: MovementManager.right_key_move)
        scene.playerManager.player.removeAction(forKey: MovementManager.up_key_move)
        scene.playerManager.player.removeAction(forKey: MovementManager.down_key_move)
    }
}

extension MovementManager {
    func exitElevator() {
        if let elevator = scene.playerManager.elevator {
            larsondebug("exiting elevator \(elevator)")
            self.stopMovement()
            scene.playerManager.status = .Elevator_Leaving
            scene.playerManager.player.run(
                SKAction.sequence(
                    [SKAction.group(
                        [SKAction.move(to: scene.playerManager.playerBase(elevator: elevator), duration: scene.boardingSpeed),
                         SKAction.scale(to: 1, duration: scene.boardingSpeed)]
                        ), SKAction.run {
                            self.scene.playerManager.status = .Standing;
                            // Push haptics to inform the player they left an elevator.
                            self.scene.playerManager.elevator = nil
                            self.haptics.impactOccurred()
                            self.scene.waveManager.start()
                        }]
                ), withKey: MovementManager.down_key_move
            )
        }
    }
    
    private func move(left: Bool, _ distance: CGFloat) {
        scene.playerManager.status = .Moving
        scene.playerManager.player.run(
            SKAction.sequence(
                [SKAction.moveBy(x: distance * (left ? -1.0 as CGFloat:1.0 as CGFloat), y: 0, duration: scene.joystickRollover),
                 SKAction.run { self.scene.playerManager.status = .Standing }]
            ), withKey: MovementManager.left_key_move
        )
    }
    
    func enterElevator() {// Set up debug
        larsonenter(#function)
        // Prepare for deinit of function.
        defer {
            larsonexit()
        }
        if let target = scene.playerManager.target {
            larsondebug("player entered elevator on floor \(target.base.number) to floor \(target.destination.number)")
            larsondebug("entered elevator: \(target)")
            self.stopMovement()
            self.scene.waveManager.stop()
            scene.playerManager.status = .Elevator_Entering
            scene.playerManager.elevator = target
            scene.playerManager.player.run(
                SKAction.sequence(
                    [SKAction.group(
                        [SKAction.move(to: scene.playerManager.onboard(elevator: target), duration: scene.boardingSpeed),
                         SKAction.scale(to: 0.8, duration: scene.boardingSpeed)]
                        ), SKAction.run {
                            self.elevatorMove()
                            // Push haptics to inform the player they entered an elevator.
                            // self.haptics.impactOccurred()
                            // Removed 
                        }]
                ), withKey: MovementManager.up_key_move
            )
        }
    }
}

extension MovementManager {
    func elevatorMove() {
        guard let elevator = scene.playerManager.elevator else {
            return
        }
        
        scene.playerManager.status = .Elevator_Moving
        
        self.cycle(elevator.destination.number - (scene.floorManager.bottomFloor?.number ?? 0)) {
            self.scene.playerManager.status = .Elevator_Idle
        }
    }
}

extension MovementManager: JoystickDelegate {
    public func moveLeft(_ view: JoystickView) {
        let distance = scene.playerManager.distance(in: scene.joystickRollover)
        
        if scene.playerManager.player.position.x - distance < -scene.floorManager.bottomFloor.baseSize.width / 2 {
            return
        }
        
        if [PlayerManager.Status.Moving, PlayerManager.Status.Standing].contains(scene.playerManager.status) {
            move(left: true, distance)
        }
    }
    
    public func moveRight(_ view: JoystickView) {
        
        let distance = scene.playerManager.distance(in: scene.joystickRollover)
        
        if scene.playerManager.player.position.x + distance > scene.floorManager.bottomFloor.baseSize.width / 2 {
            return
        }
        
        if [PlayerManager.Status.Moving, PlayerManager.Status.Standing].contains(scene.playerManager.status) {
            move(left: false, distance)
        }
    }
    
    public func moveUp(_ view: JoystickView) {
        if ![PlayerManager.Status.Elevator_Leaving, PlayerManager.Status.Elevator_Entering, PlayerManager.Status.Elevator_Moving].contains(scene.playerManager.status) {
            self.enterElevator()
        }
    }
    
    public func moveDown(_ view: JoystickView) {
        if [PlayerManager.Status.Elevator_Idle, PlayerManager.Status.Elevator_Entering].contains(scene.playerManager.status) {
            self.exitElevator()
        }
    }
}
