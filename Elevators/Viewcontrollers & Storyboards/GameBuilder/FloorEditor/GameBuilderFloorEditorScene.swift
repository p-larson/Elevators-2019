//
//  GameBuilderFloorEditorScene.swift
//  Elevators
//
//  Created by Peter Larson on 6/24/19.
//  Copyright © 2019 Peter Larson. All rights reserved.
//

import Foundation
import SpriteKit
import ElCore

public final class GameBuilderFloorEditorScene: SKScene {
    public var model: FloorModel!
    public weak var controller: GameBuilderFloorEditorViewController!
    
    public var elevatorSize: CGSize {
        return CGSize(width: frame.width / 9, height: frame.width / 6)
    }
    
    public func load(from model: FloorModel) {
        self.floor = Floor(model, elevatorSize: elevatorSize, floorSize: frame.size)
        
        floor.position.y = frame.minY / 2
        
        floor.updateElevatorPositions()
        
        self.addChild(floor)
    }
    
    public private(set) var floor: Floor!
    
    public var selected: Positionable? = nil
    
    public func select(select: SKNode) {
        
        self.selected = select
        
        for node in floor.baseElevators {
            print(node == select)
            node.setSelected(node == select)
        }
        
        controller.updateViews()
    }
    
    public func add() {
        let elevator = floor.addBroken()
            
        elevator.position.y = floor.elevatorY
        
        self.select(select: elevator)
    }
    
    public func remove() {
        if let node = selected as? SKNode {
            node.removeFromParent()
        }
        
        floor.updateElevatorPositions()
    }
}

extension GameBuilderFloorEditorScene {
    public override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            for case let elevator as Elevator in nodes(at: touch.location(in: self)) {
                self.select(select: elevator)
                print("selected", elevator)
            }
        }
    }
}
