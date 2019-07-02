//
//  FloorModel.swift
//  Elevators
//
//  Created by Peter Larson on 6/30/19.
//  Copyright © 2019 Peter Larson. All rights reserved.
//

import Foundation
import CoreGraphics

public class FloorModel: Encodable & Decodable {
    public var number: Int
    public var baseElevators: [ElevatorModel]
    public var coins: [CoinModel]
    
    public init(number: Int) {
        self.number = number
        self.baseElevators = []
        self.coins = []
    }
}
