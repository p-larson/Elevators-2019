//
//  LevelModel.swift
//  Elevators
//
//  Created by Peter Larson on 5/14/19.
//  Copyright © 2019 Peter Larson. All rights reserved.
//

import Foundation

public protocol Positionable {
    var xPosition: CGFloat { get }
}

public class LevelModel: Encodable & Decodable {
    public var number: Int
    public var name: String
    public var floors: [LevelModel.FloorModel]
    public var state: State
    public var maxElevatorRange: Int
    
    public class FloorModel: Encodable & Decodable {
        public var number: Int
        public var baseElevators: [LevelModel.FloorModel.ElevatorModel]
        public var coins: [CoinModel]
        
        public class CoinModel: Encodable & Decodable & Positionable {
            public var xPosition: CGFloat
        }
        
        public class ElevatorModel: Encodable & Decodable & Positionable {
            public var number: Int
            public var xPosition: CGFloat
            public var base: Int
            public var destination: Int
            public var type: Elevator.Kind
            
            public init(xPosition: CGFloat, base: Int, destination: Int, type: Elevator.Kind) {
                self.xPosition = xPosition
                self.base = base
                self.destination = destination
                self.type = type
            }
        }
        
        public init(number: Int) {
            self.number = number
            self.baseElevators = []
            self.coins = []
        }
        
        public func elevatorAt(x: CGFloat) -> ElevatorModel? {
            return baseElevators.sorted(by: { (elevator1, elevator2) -> Bool in
                return abs(elevator1.xPosition - x) < abs(elevator2.xPosition - x)
            }).first
        }
    }
    
    public enum State: Int, Encodable & Decodable {
        case locked, unlocked, build
    }
    
    public init?(number: Int, name: String, state: State) {
        self.number = number
        self.name = name
        self.state = state
        self.floors = []
        self.maxElevatorRange = 3
    }
    
    public init() {
        self.number = -1
        self.name = "Untitled"
        self.state = .build
        self.floors = []
        self.maxElevatorRange = 3
    }
    
    public func floorWith(number: Int) -> FloorModel? {
        return floors.first { (floor) -> Bool in
            return floor.number == number
        }
    }
}


fileprivate let jsonEncoder = JSONEncoder()

extension LevelModel: CustomStringConvertible {
    public var description: String {
        
        do {
            let data = try jsonEncoder.encode(self)
            return String(data: data, encoding: .utf8)!
        } catch {
            return error.localizedDescription
        }
    }
}
