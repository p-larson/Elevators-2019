//
//  LevelManagerTests.swift
//  ElevatorsTests
//
//  Created by Peter Larson on 2/25/19.
//  Copyright © 2019 Peter Larson. All rights reserved.
//

import XCTest
import Foundation
import SpriteKit
@testable import Elevators
@testable import ElCore

class LevelManagerTests: XCTestCase {
    
    var gamescene: GameScene!
    
    override func setUp() {
        Larson.debugging = true
        gamescene = GameScene()
        self.gamescene.floorManager.setupGame()
        print("setup.")
    }
    
    override func tearDown() {
        return
    }
    
    func testFloorGeneration() {
        self.gamescene.floorManager.debugPrint()
    }
    
    func testJostle() {
        self.gamescene.floorManager.jostle(count: Int.random(in: 1 ... 5))
    }
    
    
}
