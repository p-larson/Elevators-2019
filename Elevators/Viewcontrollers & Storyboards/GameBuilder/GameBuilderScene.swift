//
//  GameBuilderScene.swift
//  Elevators
//
//  Created by Peter Larson on 6/20/19.
//  Copyright © 2019 Peter Larson. All rights reserved.
//

import Foundation
import SpriteKit
import ElCore

// For Interacting with El Core
public class GameBuilderScene: GameScene {
    
    public weak var controller: GameBuilderViewController!
    
    public func reloadScene() {
        
        if let currentFloorNumber = floorManager.currentFloor?.number, let floor = floorManager.floor(number: currentFloorNumber) {
            setSelectedFloor(to: floor, reload: true)
        } else {
            self.floorManager.setupGame()
        }
    }
    
    public func setSelectedFloor(to floor: Floor, reload: Bool = true) {
        print("selecting floor \(floor.number)")
        
        self.floorManager.setupGame(preCurrentFloorNumber: floor.number)
        
        self.floorManager.floors.forEach { (floor2) in
            floor2.setSelected(floor == floor2)
        }
        
        self.controller.updatedSelectedFloor(to: floorManager.currentFloor)
    }
}

extension GameBuilderScene {
    public override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            
            let y = touch.location(in: self).y
            
            if let selectedFloor = self.floorManager.floors.sorted(by: { (floor1, floor2) -> Bool in
                return abs(floor1.position.y - y) < abs(floor2.position.y - y)
            }).first {
                self.setSelectedFloor(to: selectedFloor)
            }
            
            
        }
    }
}

public extension GameBuilderScene {
    func appenedFloor(number: Int = -1) {
        
    }
    
    func removeFloor(number: Int) {
        
    }
    
    func addElevator(to floor: LevelModel.FloorModel) {
        
    }
}
