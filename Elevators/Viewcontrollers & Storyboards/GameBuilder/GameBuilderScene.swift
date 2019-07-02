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
    
    public var model: LevelModel {
        return controller.model
    }
    
    public func reloadScene() {
        
        if let currentFloorNumber = floorManager.currentFloor?.number, let floorModel = model.floorWith(number: currentFloorNumber) {
            setSelectedFloor(to: floorModel, reload: true)
        } else {
            self.floorManager.setupGame()
        }
    }
    
    public func setSelectedFloor(to floor: FloorModel, reload: Bool = true) {
        
        print("selecting", floor.number)
        
        if reload {
            self.floorManager.setupGame(preCurrentFloorNumber: floor.number)
        }
        
        self.floorManager.floors.forEach { (floor2) in
            floor2.setSelected(floor.number == floor2.number)
        }
    }
}

extension GameBuilderScene {
    public override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            
            let point = touch.location(in: self)
            
            let selected = floorManager.floors.first(where: { (floor) -> Bool in
                return floor.container.contains(point)
            })
            
            
            if let selected = selected, let model = model.floorWith(number: selected.number) {
                self.setSelectedFloor(to: model, reload: true)
            }
            
        }
    }
}

public extension GameBuilderScene {
    func addFloor() {
        let newFloor = FloorModel(number: controller.model.floors.count + 1)
        controller.model.floors.append(newFloor)
        self.setSelectedFloor(to: newFloor, reload: true)
    }
    
    func deleteFloor() {
        
        guard let selectedFloor = floorManager.currentFloor else {
            return
        }
        
        // Remove from model
        model.floors = model.floors.filter({ (floorModel) -> Bool in
            return floorModel.number != selectedFloor.number
        })
        
        // Readjust any floor numbers that were above the floor
        controller.model.floors.forEach({ (floor) in
            if selectedFloor.number < floor.number {
                floor.number = floor.number - 1
            }
        })
        
        self.reloadScene()
    }
}
