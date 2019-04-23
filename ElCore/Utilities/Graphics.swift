//
//  Graphics.swift
//  Elevators
//
//  Created by Peter Larson on 2/2/19.
//  Copyright © 2019 Peter Larson. All rights reserved.
//

import SpriteKit

// MARK:    Graphics
public struct Graphics {
    static fileprivate var context: UIGraphicsImageRenderer!

    public static func image(of size: CGSize, block: @escaping (CGContext) -> Void) -> UIImage {
        Graphics.context = UIGraphicsImageRenderer(size: size)
        return context.image(actions: { (context) in
            let cgContext = context.cgContext
            block(cgContext)
        })
    }
}
// MARK:    Graphics – SpriteKit support
public extension Graphics {
    static func texture(of size: CGSize, block: @escaping (CGContext) -> Void) -> SKTexture {
        return SKTexture(image: Graphics.image(of: size, block: block))
    }
}

// MARK:    Graphic Protocols

protocol UpdatableGraphics {
    func updateGraphics()
}

protocol TextureGraphable: UpdatableGraphics {
    static func texture(_ this: Self) -> SKTexture
}

protocol ImageGraphable: UpdatableGraphics {
    static func image(_ this: Self) -> UIImage
}
