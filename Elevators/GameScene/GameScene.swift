//
//  GameScene.swift
//  Elevators
//
//  Created by Peter Larson on 1/29/19.
//  Copyright © 2019 Peter Larson. All rights reserved.
//

import SpriteKit
import GameplayKit
import ElCore

public class GameScene: ElevatorsGameScene {
    // ElevatorGame Constants
    public let maxElevatorRange = 3
    public let maxElevatorsPerFloor = 3
    public let maxElevatorsPerTrapFloor = 2
    public let maxFloorsLoaded = 12
    public let maxFloorsShown = 5
    public let maxOffhandFloors = 5
    public let maxGenerateElevatorFails = 100
    public let elevatorSpeed: TimeInterval = 0.5
    public let playerSpeed: TimeInterval = 1.0
    public let waveSpeed: TimeInterval = 5.0
    public let boardingSpeed: TimeInterval = 0.3
    public let joystickRollover: TimeInterval = 1.0 / 20.0
    public let joystickThreshhold: CGFloat = 1.0
    
    public var endGameDelegate: EndGameDelegate? = nil
    
    public let saves = UserDefaults()
    
    public var scoreboardLabel: UILabel? = nil
    
    public var gameFrame: CGRect {
        return CGRect(
            x: frame.minX + frame.width * 0.05,
            y: frame.minY + frame.height * 0.2,
            width: frame.width * 0.9,
            height: frame.height * 0.8
        )
    }
    
    public var joystickFrame: CGRect {
        return CGRect(
            x: frame.midX + frame.width * 0.05,
            y: frame.height - frame.height / 3,
            width: frame.width * 0.9,
            height: frame.height / 4
        )
    }
    
    public lazy var floorManager: FloorManager = {
        return FloorManager(scene: self)
    }()
    
    public lazy var playerManager: PlayerManager = {
        return PlayerManager(scene: self)
    }()
    
    public lazy var cameraManager: CameraManager = {
        return CameraManager(scene: self)
    }()
    
    public lazy var movementManager: MovementManager = {
        return MovementManager(scene: self)
    }()
    
    public lazy var scoreboardManager: ScoreboardManager = {
        return ScoreboardManager(scene: self)
    }()
    
    public lazy var waveManager: WaveManager = {
        return WaveManager(scene: self)
    }()
    
    public lazy var shopManager: ShopManager = {
        return ShopManager(scene: self)
    }()
    
    public lazy var preferencesManager: PreferencesManager = {
        return PreferencesManager(scene: self)
    }()
}

// MARK:    viewDidLoad
extension GameScene {
    
    public override func didMove(to view: SKView) {
        
        Larson.debugging = true
        
        larsonenter("settings")
        
        larsondebug("maxElevatorRange", maxElevatorRange)
        larsondebug("maxElevatorsPerFloor", maxElevatorsPerFloor)
        larsondebug("maxElevatorsPerTrapFloor", maxElevatorsPerTrapFloor)
        larsondebug("maxFloorsLoaded", maxFloorsLoaded)
        larsondebug("maxFloorsShown", maxFloorsShown)
        larsondebug("elevatorSpeed", elevatorSpeed)
        larsondebug("floorManager.elevatorSize", floorManager.elevatorSize)
        larsondebug("floorManager.floorSize", floorManager.floorSize)
        larsondebug("floorSize", floorManager.floorSize)
        
        larsonexit()
        
        self.floorManager.setupGame()
        self.playerManager.setupPlayer()
        self.cameraManager.setupCamera()
        self.movementManager.setupJoystick()
        self.scoreboardManager.setupScoreboard()
        
    }
}

extension GameScene {
    public func touched(elevator: Elevator) {
        return
    }
    
    public func untouched(elevator: Elevator) {
        return
    }
}

extension GameScene {
    func showGameFrame() {
        let node = SKSpriteNode()
        node.size = gameFrame.size
        node.position = gameFrame.origin
        node.anchorPoint = .zero
        
        if Larson.debugging {
            node.color = UIColor.red.withAlphaComponent(0.2)
            node.colorBlendFactor = 1
        }
        node.name = "gameframe"
        self.addChild(node)
    }
}
