//
//  Preferences.swift
//  ElCore
//
//  Created by Peter Larson on 4/27/19.
//  Copyright © 2019 Peter Larson. All rights reserved.
//

import Foundation

public class PreferencesManager: ElevatorsGameSceneDependent {
    
    public let scene: ElevatorsGameScene
    
    public init(scene: ElevatorsGameScene) {
        self.scene = scene
    }
    
    public var selectedElevatorSkin: Skin {
        return scene.shopManager.defaultElevator
    }
}

