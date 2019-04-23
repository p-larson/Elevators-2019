//
//  SpriteKit+.swift
//  ElCore
//
//  Created by Peter Larson on 4/17/19.
//  Copyright © 2019 Peter Larson. All rights reserved.
//

import SpriteKit

public extension SKAction {
    static func withCompletionHandler(_ action: SKAction, completion: Block?) -> SKAction {
        var actions = [action]
        
        if let block = completion {
            actions.append(SKAction.run(block))
        }
        
        return SKAction.sequence(actions)
    }
}

