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
    public var model: LevelModel.FloorModel!
    
    public var elevatorSize: CGSize {
        return CGSize(width: frame.width / 9, height: frame.width / 6)
    }
    
    private var floor: Floor!
    
    public func reload() {
        
        self.removeAllChildren()
        
        floor = Floor(model, elevatorSize: elevatorSize, floorSize: frame.size)
        
        floor.position.y = frame.minY / 2
        
        self.addChild(floor)
        
        floor.updateElevatorPositions()
        
        larsondebug(self.calculateAccumulatedFrame(), "loaded")
    }
    
    public override func didMove(to view: SKView) {
        // Create Floor
        self.reload()
    }
}
