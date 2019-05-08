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

    public let scene: ElevatorsGameScene
    public let lightHaptics: UIImpactFeedbackGenerator
    public let mediumHaptics: UIImpactFeedbackGenerator
    
    public lazy var leftSwipe: UISwipeGestureRecognizer = {
        let swipe = UISwipeGestureRecognizer(target: self, action: #selector(moveLeft))
        swipe.direction = UISwipeGestureRecognizer.Direction.left
        return swipe
    }()
    public lazy var rightSwipe: UISwipeGestureRecognizer = {
        let swipe = UISwipeGestureRecognizer(target: self, action: #selector(moveRight))
        swipe.direction = UISwipeGestureRecognizer.Direction.right
        return swipe
    }()
    public lazy var upSwipe: UISwipeGestureRecognizer = {
        let swipe = UISwipeGestureRecognizer(target: self, action: #selector(enterElevator))
        swipe.direction = UISwipeGestureRecognizer.Direction.up
        return swipe
    }()

    private var cycling: Bool = false
    
    public var isCycling: Bool {
        return cycling
    }

    public func cycle(_ count: Int = 1, completion: @escaping Block = {}) {
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
        
        // Hide Player
        self.scene.playerManager.player.isHidden = true
        
        self.scene.cameraManager.move(cameraMove, completion: {
            guard let elevator = self.scene.playerManager.elevator else {
                larsondebug("Could not finish elevator move: elevator does not exist")
                return
            }
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
            // Open Floor
            self.scene.floorManager.bottomFloor.openElevators()
            // Open Elevator
            elevator.open(completion: {
                // Unhide player
                self.scene.playerManager.player.isHidden = false
                // Leave elevator
                self.exitElevator()
                // Call Completion Handler
                completion()
                // Debug
                larsondebug("Moved back. Done with cycle.")
                
            })
        })
        // Apply same action to the Elevator and Player.
        self.scene.playerManager.player.run(elevatorMove)
        self.scene.playerManager.elevator?.run(elevatorMove)
        
    }
    
    public init(scene: ElevatorsGameScene) {
        self.scene = scene
        self.lightHaptics = UIImpactFeedbackGenerator(style: .light)
        self.mediumHaptics = UIImpactFeedbackGenerator(style: .medium)
        
        [leftSwipe, rightSwipe, upSwipe].forEach {
            swipe in self.scene.view?.addGestureRecognizer(swipe)
        }
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

// Movement 2.0
extension MovementManager {
    @objc func moveRight() {
        larsonenter(#function)
        // Prepare for deinit of function.
        defer {
            larsonexit()
        }
        guard
            [PlayerManager.Status.Moving, PlayerManager.Status.Standing].contains(scene.playerManager.status),
            let target = scene.playerManager.rightTarget
        else {
            larsondebug("failed \(scene.playerManager.rightTarget == nil)")
            return
        }
        
        scene.playerManager.target = target
        
        larsondebug("## target \(target)")
        
        scene.playerManager.status = .Moving
        larsondebug("RUNNING")
        scene.playerManager.player.run(
            SKAction.sequence(
                [scene.playerManager.move(to: target),
                 SKAction.run { self.scene.playerManager.status = .Standing; }]
            ), withKey: MovementManager.right_key_move
        )
    }
    
    @objc func moveLeft() {
        larsonenter(#function)
        // Prepare for deinit of function.
        defer {
            larsonexit()
        }
        guard
            [PlayerManager.Status.Moving, PlayerManager.Status.Standing].contains(scene.playerManager.status),
            let target = scene.playerManager.leftTarget
        else {
            larsondebug("failed \(scene.playerManager.leftTarget == nil)")
            return
        }
        
        scene.playerManager.target = target
        scene.playerManager.status = .Moving
        
        scene.playerManager.player.run(
            SKAction.sequence(
                [scene.playerManager.move(to: target),
                 SKAction.run { self.scene.playerManager.status = .Standing; }]
            ), withKey: MovementManager.left_key_move
        )
    }
    
    @objc func enterElevator() {
        // Set up debug
        larsonenter(#function)
        // Prepare for deinit of function.
        defer {
            larsonexit()
        }
        
        if [PlayerManager.Status.Elevator_Leaving, PlayerManager.Status.Elevator_Entering, PlayerManager.Status.Elevator_Moving].contains(scene.playerManager.status) {
            return
        }
        
        if let target = scene.playerManager.target {
            
            guard target.isEnabled && target.status == .Open else {
                larsondebug("elevator is disabled or not open, cannot enter.")
                return
            }
            
            guard abs(target.position.x - scene.playerManager.player.position.x) < target.size.width / 2 else {
                larsondebug("player is too far away from the elevator to enter.")
                return
            }
            
            larsondebug("player entered elevator on floor \(target.base.number) to floor \(target.destination.number)")
            larsondebug("entered elevator: \(target)")
            
            self.stopMovement()
            self.scene.waveManager.stop()
            
            scene.playerManager.status = .Elevator_Entering
            scene.playerManager.elevator = target
            
            target.close()
            
            self.scene.playerManager.player.run(
                SKAction.sequence(
                    [SKAction.group(
                        [SKAction.move(to: self.scene.playerManager.onboard(elevator: target), duration: self.scene.boardingSpeed),
                         SKAction.scale(to: 0.8, duration: self.scene.boardingSpeed)]
                        )]
                ), withKey: MovementManager.up_key_move
            )
            self.elevatorMove()
        }
    }
    
    @objc func exitElevator() {
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
                            // Close elevator
                            self.scene.playerManager.target?.close()
                            // Push haptics to inform the player they left an elevator.
                            self.scene.playerManager.elevator = nil
                            self.mediumHaptics.impactOccurred()
                            self.scene.waveManager.start()
                        }]
                ), withKey: MovementManager.down_key_move
            )
        }
    }
}
