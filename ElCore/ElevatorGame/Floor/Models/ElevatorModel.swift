//
//  ElevatorModel.swift
//  Elevators
//
//  Created by Peter Larson on 6/30/19.
//  Copyright © 2019 Peter Larson. All rights reserved.
//

import Foundation

public class ElevatorModel: Encodable & Decodable & Positionable {
    public var number: Int
    public var xPosition: CGFloat
    public var base: Int
    public var destination: Int
    public var type: Elevator.Kind
    
    public init(xPosition: CGFloat, base: Int, destination: Int, type: Elevator.Kind, number: Int) {
        self.xPosition = xPosition
        self.base = base
        self.destination = destination
        self.type = type
        self.number = number
    }
}
