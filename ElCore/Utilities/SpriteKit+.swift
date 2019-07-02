//
//  SpriteKit+.swift
//  ElCore
//
//  Created by Peter Larson on 4/17/19.
//  Copyright © 2019 Peter Larson. All rights reserved.
//

import SpriteKit

public extension SKAction {
    static func withCompletionHandler(_ action: SKAction, completion: BlockOperation?) -> SKAction {
        var actions = [action]
        
        actions.append(SKAction.run {
            completion?.start()
        })
        
        return SKAction.sequence(actions)
    }
}

public extension SKNode {
    var globalZPosition: CGFloat {
        var z = zPosition
        var p = parent
        while let node = p {
            z+=node.zPosition
            p = node.parent
        }
        return z
    }
}

public extension SKNode {
    
    static let selected_name = "selected"
    
    func setSelected(_ value: Bool = true) {
        
        self.childNode(withName: SKNode.selected_name)?.removeFromParent()
        
        if value {
            let node = SKSpriteNode()
            node.color = UIColor.white.withAlphaComponent(0.25)
            node.size = calculateAccumulatedFrame().size
            node.position = .zero
            node.name = SKNode.selected_name
            self.addChild(node)
            
            print(node.size)
        }
        
        alpha = value ? 1.0 : 0.5
    }
}
