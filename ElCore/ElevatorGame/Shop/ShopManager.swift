//
//  ShopManager.swift
//  ElCore
//
//  Created by Peter Larson on 4/27/19.
//  Copyright © 2019 Peter Larson. All rights reserved.
//

import Foundation

public class ShopManager {
    
    public static private(set) var shared = ShopManager()
    
    private init () {}
    
    public var selectedElevatorSkin: Skin {
        return defaultElevator
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
        return Array(repeating: Skin(name: "default", cost: 0, atlasName: "salmon elevator", kind: .Elevator), count: 25)
    }()
}
