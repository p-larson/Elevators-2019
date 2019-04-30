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
    
    public var playerBase: CGPoint {
        return CGPoint.zero.add(0, scene.floorManager.bottomFloor.baseSize.height / 2 + player.size.height / 2)
    }
    
    public func playerBase(elevator: Elevator) -> CGPoint {
        return CGPoint(x: elevator.position.x, y: playerBase.y)
    }
    
    public func onboard(elevator: Elevator) -> CGPoint {
        return CGPoint(x: elevator.position.x, y: playerBase.y)
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
        let time = TimeInterval(difference(elevator) / scene.floorManager.bottomFloor.floorSize.width) * (scene.playerSpeed)
        return SKAction.moveTo(x: elevator.position.x, duration: time)
    }
    
    public func difference(_ elevator: Elevator) -> CGFloat {
        return abs(elevator.position.x - player.position.x)
    }
    
    public var rightTarget: Elevator? {
        return scene.floorManager.bottomFloor.baseElevators.filter({ (elevator) -> Bool in
            return elevator.position.x > player.position.x && elevator.isEnabled && elevator != target
        }).sorted(by: { (e1, e2) -> Bool in
            return difference(e1) < difference(e2)
        }).first
    }
    
    public var leftTarget: Elevator? {
        print(scene.floorManager.bottomFloor.baseElevators.count)
        return scene.floorManager.bottomFloor.baseElevators.filter({ (elevator) -> Bool in
            return elevator.position.x < player.position.x && elevator.isEnabled && elevator != target
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
        // (12 inch / 1 foot) * 2 feet = 24 inches
        return
            (scene.floorManager.bottomFloor.baseSize.width * CGFloat(time))
            /
            CGFloat(scene.playerSpeed)
    }
    
    public func setupPlayer() {
        // Set up debug
        larsonenter(#function)
        
        // Prepare for deinit of function.
        defer {
            larsonexit()
        }
        
        player.position = self.playerBase
        player.size = PlayerManager.playerSize(from: scene.floorManager.bottomFloor)
        player.zPosition = PlayerNode.outsideZPosition
        
        scene.floorManager.bottomFloor.addChild(player)
        
        larsondebug("finished player setup. \(player.debugDescription)")
    }
    
    public init(scene: ElevatorsGameScene) {
        // Scene must have loaded it's floor manager
        guard let bottomFloor = scene.floorManager.bottomFloor else {
            fatalError("\(scene) has not loaded the floorManager before initializing the playerManager")
        }

        self.player = PlayerNode(size: PlayerManager.playerSize(from: bottomFloor))
        
        self.scene = scene
    }
}
