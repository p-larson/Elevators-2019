//
//  Unlockable.swift
//  ElCore
//
//  Created by Peter Larson on 4/27/19.
//  Copyright © 2019 Peter Larson. All rights reserved.
//

import Foundation

public protocol Unlockable {
    var name: String { get }
    var cost: Int { get }
}

import SpriteKit

public class Skin: Unlockable {
    public let name: String
    public let cost: Int
    public let atlasName: String
    public let kind: Kind
    
    public enum Kind {
        case Elevator
        case Player
    }
    
    public init(name: String, cost: Int, atlasName: String, kind: Kind) {
        self.name = name
        self.cost = cost
        self.atlasName = atlasName
        self.kind = kind
    }
    
    public private(set) lazy var textures: [SKTexture] = {
        let atlas = SKTextureAtlas(named: atlasName)
        return atlas.textureNames.sorted().map { (name) -> SKTexture in
            return atlas.textureNamed(name)
        }
    }()
    
    public var base: SKTexture? {
        return textures.first
    }
    
    public var frames: ArraySlice<SKTexture> {
        return textures.dropFirst()
    }
    
    public var frames1: ArraySlice<SKTexture> {
        let f = frames
        return f[f.startIndex ... f.endIndex - f.count / 2]
    }
    
    public var frames2: ArraySlice<SKTexture> {
        let f = frames
        return f[f.endIndex - f.count / 2 ... f.endIndex]
    }
    
    
}
