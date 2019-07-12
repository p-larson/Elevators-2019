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

    public func cycle(_ count: Int = 1, completion: BlockOperation = BlockOperation()) {
        defer {
            self.cycling = false
        }
        guard !isCycling && count > 0 && count < scene.floorManager.loadedZone.count else {
            self.exitElevator()
            return
        }
        
        self.cycling = true
        
        let waveOffset: CGFloat = scene.cameraManager.position.y - scene.cameraManager.basePosition.y
        let elevatorDistance: CGFloat = scene.floorManager.floorSize.height * CGFloat(count)
        let totalDuration: TimeInterval = scene.elevatorSpeed * Double(count)
        // Move the camera count floors up minus the move it's already
        let cameraMove = scene.cameraManager.movement(dx: 0, dy: elevatorDistance - waveOffset, duration: totalDuration)
        
        let elevatorMove = scene.cameraManager.movement(dx: 0, dy: elevatorDistance, duration: totalDuration)
        
        let jostle = SKAction.sequence([
            SKAction.wait(forDuration: scene.elevatorSpeed),
            SKAction.run {
            self.scene.floorManager.jostle()
            self.scene.scoreboardManager.increment()
        }])
        
        // Update scoreboard, by incrementing it every time the elevator passes a floor.
        self.scene.run(SKAction.repeat(jostle, count: count))
        
        // Hide Player
        self.scene.playerManager.player.isHidden = true
        
        let move = SKAction.group([.wait(forDuration: scene.elevatorSpeed * Double(count)), cameraMove])
        
        self.scene.cameraManager.move(move, completion: BlockOperation(block: {
            guard let elevator = self.scene.playerManager.elevator else {
                return
            }
            // Current Floor after being jostled
            guard let currentFloor = self.scene.floorManager.currentFloor else {
                return
            }
            // Update Floor Positions
            self.scene.floorManager.updateFloors()
            // Reset camera position.
            self.scene.cameraManager.set(self.scene.cameraManager.basePosition)
            // Move the player to the floor's child hierarchy.
            self.scene.playerManager.player.move(toParent: currentFloor)
            self.scene.playerManager.elevator?.move(toParent: currentFloor)
            // After the move, reset the player's and elevator's y position
            if let target = self.scene.playerManager.target {
                self.scene.playerManager.player.position = self.scene.playerManager.playerBase(elevator: target)
                target.position.y = currentFloor.elevatorY
            }
            // Move Elevator to current floor and disable it.
            self.scene.playerManager.elevator?.isEnabled = false
            // Open Floor
            currentFloor.openElevators()
            // Open Elevator
            elevator.open(completion: BlockOperation(block: {
                // Unhide player
                self.scene.playerManager.player.isHidden = false
                // Leave elevator
                self.exitElevator()
                // Call Completion Handler
                completion.start()
            }))
        }))
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

        self.cycle(elevator.destination - (scene.floorManager.currentFloor?.number ?? 0), completion: BlockOperation(block: {
            self.scene.playerManager.status = .Elevator_Idle
        }))
    }
}

// Movement 2.0
extension MovementManager {
    @objc func moveRight() {
        guard
            [PlayerManager.Status.Moving, PlayerManager.Status.Standing].contains(scene.playerManager.status),
            let target = scene.playerManager.rightTarget
        else {
            return
        }
        
        scene.playerManager.target = target
        
        scene.playerManager.status = .Moving
        scene.playerManager.player.run(
            SKAction.sequence(
                [scene.playerManager.move(to: target),
                 SKAction.run { self.scene.playerManager.status = .Standing; }]
            ), withKey: MovementManager.right_key_move
        )
    }
    
    @objc func moveLeft() {
        guard
            [PlayerManager.Status.Moving, PlayerManager.Status.Standing].contains(scene.playerManager.status),
            let target = scene.playerManager.leftTarget
        else {
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

        if [PlayerManager.Status.Elevator_Leaving, PlayerManager.Status.Elevator_Entering, PlayerManager.Status.Elevator_Moving].contains(scene.playerManager.status) {
            return
        }
        
        if let target = scene.playerManager.target {
            
            guard target.isEnabled && target.status == .Open else {
                return
            }
            
            guard abs(target.position.x - scene.playerManager.player.position.x) < target.size.width / 2 else {
                return
            }
            
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
            self.stopMovement()
            scene.playerManager.status = .Elevator_Leaving
            scene.playerManager.player.position = scene.playerManager.onboard(elevator: elevator)
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
