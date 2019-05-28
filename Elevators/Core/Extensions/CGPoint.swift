//
//  extensions-CGPoint.swift
//  Elevators
//
//  Created by Peter Larson on 2/13/19.
//  Copyright © 2019 Peter Larson. All rights reserved.
//

import SpriteKit

public extension CGPoint {
    func add(x: CGFloat = 0, y: CGFloat = 0) -> CGPoint {
        return .init(x: self.x + x, y: self.y + y)
    }
    
    func subtract(x: CGFloat = 0, y: CGFloat = 0) -> CGPoint {
        return .init(x: self.x - x, y: self.y - y)
    }
    
    func distance(to point: CGPoint) -> CGFloat {
        return sqrt(pow(x - point.x, 2) + pow(y - point.y, 2))
    }
}
