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
    
    @objc func setSelected(_ value: Bool = true) {
        alpha = value ? 1.0 : 0.5
    }
}

//public extension Floor {
//    override func setSelected(_ value: Bool = true) {
//        super.setSelected(value)
//
//        let node = (childNode(withName: SKNode.selected_name) as? SKSpriteNode)
//        node?.position = .init(x: 0, y: floorSize.height / 2)
//        node?.size = floorSize
//
//    }
//}

//extension Elevator {
//    public override func setSelected(_ value: Bool = true) {
//        super.setSelected(value)
//        
//        childNode(withName: SKNode.selected_name)?.zPosition = Elevator.doorZPosition.advanced(by: 1)
//    }
//}
