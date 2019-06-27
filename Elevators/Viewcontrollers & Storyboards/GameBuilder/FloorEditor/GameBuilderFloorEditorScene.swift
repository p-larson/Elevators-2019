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
    
    public override func didMove(to view: SKView) {
        // Create Floor
        floor = Floor(model, elevatorSize: elevatorSize, floorSize: frame.size)
        
        self.addChild(floor)
        
        floor.updateElevatorPositions()
    }
}
