//
//  ElevatorsGame.swift
//  ElCore
//
//  Created by Peter Larson on 2/24/19.
//  Copyright © 2019 Peter Larson. All rights reserved.
//

import Foundation

public protocol ElevatorsGame: ElevatorDelegate {
    var maxElevatorRange: Int { get }
    var maxElevatorsPerFloor: Int { get }
    var maxElevatorsPerTrapFloor: Int { get }
    var maxFloorsLoaded: Int { get }
    var maxFloorsShown: Int { get }
    var maxOffhandFloors: Int { get }
    var maxGenerateElevatorFails: Int { get }
    var elevatorSpeed: TimeInterval { get }
    var playerSpeed: TimeInterval { get }
    var boardingSpeed: TimeInterval { get }
    var waveSpeed: TimeInterval { get }
    var joystickRollover: TimeInterval { get }
    var joystickThreshhold: CGFloat { get }
    var floorManager: FloorManager { get }
    var playerManager: PlayerManager { get }
    var cameraManager: CameraManager { get }
    var movementManager: MovementManager { get }
    var scoreboardManager: ScoreboardManager { get }
    var waveManager: WaveManager { get 	}
    var gameFrame: CGRect { get }
    var joystickFrame: CGRect { get }
    var scoreboardLabel: UILabel? { get }
}
