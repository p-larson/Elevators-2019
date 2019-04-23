//
//  ElevatorTouchHandler.swift
//  ElCore
//
//  Created by Peter Larson on 3/14/19.
//  Copyright © 2019 Peter Larson. All rights reserved.
//

public protocol ElevatorDelegate {
    func touched(elevator: Elevator)
    func untouched(elevator: Elevator)
}
