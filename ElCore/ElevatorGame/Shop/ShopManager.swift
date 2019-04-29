//
//  ShopManager.swift
//  ElCore
//
//  Created by Peter Larson on 4/27/19.
//  Copyright © 2019 Peter Larson. All rights reserved.
//

import Foundation

public class ShopManager {
    
    public let scene: ElevatorsGameScene
    
    public init(scene: ElevatorsGameScene) {
        self.scene = scene
    }
    
    public var defaultElevator: Skin {
        return unlockables.first as! Skin
    }
    
    public func unlockables(by kind: Skin.Kind) -> [Skin] {
        return unlockables.compactMap({ (unlockable) -> Skin? in
            return unlockable as? Skin
        }).filter({ (unlockable) -> Bool in
            return unlockable.kind == kind
        })
    }
    
    public private(set) lazy var unlockables: [Unlockable] = {
        return [
            Skin(name: "default", cost: 0, atlasName: "salmon elevator", kind: .Elevator)
        ]
    }()
}
