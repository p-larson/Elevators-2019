//
//  Positionable.swift
//  Elevators
//
//  Created by Peter Larson on 6/30/19.
//  Copyright © 2019 Peter Larson. All rights reserved.
//

import CoreGraphics

public protocol Positionable {
    var xPosition: CGFloat { get }
}

import SpriteKit

extension SKNode: Positionable {
    public var xPosition: CGFloat {
        return position.x
    }
}
