//
//  CoreGraphics+.swift
//  ElCore
//
//  Created by Peter Larson on 3/27/19.
//  Copyright © 2019 Peter Larson. All rights reserved.
//

import Foundation
import CoreGraphics

internal extension CGPoint {
    func add(_ x: CGFloat = 0, _ y: CGFloat = 0) -> CGPoint {
        return CGPoint(x: self.x + x, y: self.y + y)
    }
    
    func sub(_ x: CGFloat = 0, _ y: CGFloat = 0) -> CGPoint {
        return CGPoint(x: self.x - x, y: self.y - y)
    }
    
    func multiply(_ dx: CGFloat = 1, _ dy: CGFloat = 1) -> CGPoint {
        return CGPoint(x: self.x * dx, y: self.y * dy)
    }
    
    func divide(_ dx: CGFloat = 1, _ dy: CGFloat = 1) -> CGPoint {
        return CGPoint(x: self.x / dx, y: self.y / dy)
    }
}
