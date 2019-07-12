//
//  PlayerManager.swift
//  ElCore
//
//  Created by Peter Larson on 2/24/19.
//  Copyright © 2019 Peter Larson. All rights reserved.
//

import Foundation
import SpriteKit

public class PlayerManager: ElevatorsGameSceneDependent {
    
    public var player: PlayerNode!
    public var elevator: Elevator? = nil
    public let scene: ElevatorsGameScene
    
    public var target: Elevator? = nil
    
    public enum Status {
        case Moving
        case Standing
        case Elevator_Entering
        case Elevator_Leaving
        case Elevator_Moving
        case Elevator_Idle
    }
    
    public func playerBase(elevator: Elevator) -> CGPoint {
        
        guard let currentFloor = scene.floorManager.currentFloor else {
            return .zero
        }
        
        return CGPoint(x: elevator.position.x, y: currentFloor.baseSize.height / 2 + player.size.height / 2)
    }
    
    public func onboard(elevator: Elevator) -> CGPoint {
        guard let currentFloor = scene.floorManager.currentFloor else {
            return .zero
        }
        
        return playerBase(elevator: elevator).add(0, currentFloor.baseSize.height / 2)
    }
    
    public var status: Status = .Standing {
        didSet {
            switch self.status {
            case .Moving, .Standing:
                player.zPosition = PlayerNode.outsideZPosition
                break
            default:
                player.zPosition = PlayerNode.insideZPosition
                break
            }
        }
    }
    
    public func move(to elevator: Elevator) -> SKAction {
        guard let currentFloor = scene.floorManager.currentFloor else {
            return SKAction()
        }
        let time = TimeInterval(difference(elevator) / currentFloor.floorSize.width) * (scene.playerSpeed)
        return SKAction.moveTo(x: elevator.position.x, duration: time)
    }
    
    public func difference(_ elevator: Elevator) -> CGFloat {
        return abs(elevator.position.x - player.position.x)
    }
    
    public var rightTarget: Elevator? {
        
        guard let currentFloor = scene.floorManager.currentFloor else {
            return nil
        }
        
        return currentFloor.baseElevators.filter({ (elevator) -> Bool in
            return elevator.position.x > player.position.x && elevator != target
        }).sorted(by: { (e1, e2) -> Bool in
            return difference(e1) < difference(e2)
        }).first
    }
    
    public var leftTarget: Elevator? {
        
        guard let currentFloor = scene.floorManager.currentFloor else {
            return nil
        }
        
        return currentFloor.baseElevators.filter({ (elevator) -> Bool in
            return elevator.position.x < player.position.x && elevator != target
        }).sorted(by: { (e1, e2) -> Bool in
            return difference(e1) < difference(e2)
        }).first
    }
    
    public static func playerSize(from floor: Floor) -> CGSize {
        return CGSize(
            width: floor.elevatorSize.width / 2,
            height: floor.elevatorSize.height / 2
        )
    }
    
    public func distance(in time: TimeInterval) -> CGFloat {
        
        guard let currentFloor = scene.floorManager.currentFloor else {
            return 0.0
        }
        // (12 inch / 1 foot) * 2 feet = 24 inches
        return
            (currentFloor.baseSize.width * CGFloat(time))
            /
            CGFloat(scene.playerSpeed)
    }
    
    public func setupPlayer() {
        
        guard let currentFloor = scene.floorManager.currentFloor else {
            return
        }
        
        player.size = PlayerManager.playerSize(from: currentFloor)
        player.zPosition = PlayerNode.outsideZPosition
        
        if let target = Bool.random() ? (rightTarget ?? leftTarget) : (leftTarget ?? rightTarget) {
            self.target = target
            self.player.position = playerBase(elevator: target)
        }
        
        currentFloor.addChild(player)
    }
    
    public init(scene: ElevatorsGameScene) {
        self.player = PlayerNode()
        
        self.scene = scene
    }
}

extension PlayerNode {
    public override var description: String {
        return "\(position) \(floor?.number ?? -1)"
    }
}
