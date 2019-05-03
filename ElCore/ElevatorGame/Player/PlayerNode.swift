//
//  PlayerNode.swift
//  ElCore
//
//  Created by Peter Larson on 2/24/19.
//  Copyright © 2019 Peter Larson. All rights reserved.
//

import SpriteKit

public class PlayerNode: SKSpriteNode {
    
    static let insideZPosition: CGFloat = 2.0
    static let outsideZPosition: CGFloat = 4.0
    
    public var floor: Floor? {
        return parent as? Floor
    }
    
    public init(size: CGSize) {
        super.init(texture: nil, color: .clear, size: size)
        self.updateGraphics()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        return nil
    }
    
}

extension PlayerNode: TextureGraphable {
    // TODO: Make this actually right.
    static func texture(_ this: PlayerNode) -> SKTexture {
        return Graphics.texture(of: this.size, block: { (context) in
            context.addRect(CGRect.init(origin: .zero, size: this.size))
            UIColor.red.setFill()
            context.fillPath()
        })
    }
    
    func updateGraphics() {
        self.texture = PlayerNode.texture(self)
    }
}
