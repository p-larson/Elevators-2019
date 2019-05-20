//
//  LevelModel.swift
//  Elevators
//
//  Created by Peter Larson on 5/14/19.
//  Copyright © 2019 Peter Larson. All rights reserved.
//

import Foundation

public struct LevelModel: Encodable & Decodable {
    public var number: Int
    public var name: String
    public var floors: [LevelModel.FloorModel]
    
    public struct FloorModel: Encodable & Decodable {
        public var number: Int
        public var baseElevators: [LevelModel.FloorModel.ElevatorModel]
        
        public struct ElevatorModel: Encodable & Decodable {
            public var xPercent: UInt
            public var base: Int
            public var destination: Int
            public var type: Int
        }
    }
}