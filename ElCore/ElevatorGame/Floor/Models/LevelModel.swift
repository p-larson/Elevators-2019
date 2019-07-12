//
//  LevelModel.swift
//  Elevators
//
//  Created by Peter Larson on 5/14/19.
//  Copyright © 2019 Peter Larson. All rights reserved.
//

import Foundation

public class LevelModel: Encodable & Decodable {
    public var number: Int
    public var name: String
    public var floors: [FloorModel]
    public var state: State
    public var firstFloor: Int
    
    public enum State: Int, Encodable & Decodable {
        case locked, unlocked, build
    }
    
    public init?(number: Int, name: String, state: State) {
        self.number = number
        self.name = name
        self.state = state
        self.floors = []
        self.firstFloor = 1
    }
    
    public init() {
        self.number = -1
        self.name = "Untitled"
        self.state = .build
        self.floors = []
        self.firstFloor = 0
    }
    
    public init(name: String) {
        self.number = -1
        self.name = name
        self.state = .build
        self.floors = []
        self.firstFloor = 0
    }
    
    public func floorWith(number: Int) -> FloorModel? {
        return floors.first { (floor) -> Bool in
            return floor.number == number
        }
    }
    
    public static var empty: LevelModel {
        return .init()
    }
}
