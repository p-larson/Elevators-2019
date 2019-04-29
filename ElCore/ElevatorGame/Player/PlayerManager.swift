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
    
    public var floor: Floor {
        return scene.floorManager.bottomFloor!
    }
    
    public enum Status {
        case Moving
        case Standing
        case Elevator_Entering
        case Elevator_Leaving
        case Elevator_Moving
        case Elevator_Idle
    }
    
    public var playerBase: CGPoint {
        return CGPoint.zero.add(0, floor.baseSize.height / 2 + player.size.height / 2)
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
            
            larsondebug("updated player zposition to \(self.player.zPosition)")
        }
    }
    
    /// The target elevator.
    ///
    /// The closest elevator on the floor in range of the player's frame.
    public var target: Elevator? {
        return floor.baseElevators.filter ({ elevator in
            let whitelist =  (player.position.x - player.size.width)...(player.position.x + player.size.width)
            return whitelist.contains(elevator.position.x) && elevator.isEnabled
        }).sorted { (e1, e2) -> Bool in
            func difference(_ elevator: Elevator) -> CGFloat {
                return abs(elevator.position.x - player.position.x)
            }
            return difference(e1) < difference(e2)
        }.first
    }
    
    public static func playerSize(from floor: Floor) -> CGSize {
        return CGSize(width: floor.elevatorSize.width / 2, height: floor.elevatorSize.height / 2)
    }
    
    public func distance(in time: TimeInterval) -> CGFloat {
        // (12 inch / 1 foot) * 2 feet = 24 inches
        return
            (floor.baseSize.width * CGFloat(time))
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
        player.size = PlayerManager.playerSize(from: floor)
        
        floor.addChild(player)
        
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
