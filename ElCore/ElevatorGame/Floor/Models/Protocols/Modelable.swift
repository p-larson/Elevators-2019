//
//  Modelable.swift
//  Elevators
//
//  Created by Peter Larson on 6/30/19.
//  Copyright © 2019 Peter Larson. All rights reserved.
//

import Foundation

public protocol Modelable {
    
    associatedtype Model
    
    func modeled() -> Model
}

fileprivate let jsonEncoder = JSONEncoder()

extension LevelModel: CustomDebugStringConvertible {
    public var debugDescription: String {
        do {
            let data = try jsonEncoder.encode(self)
            return String(data: data, encoding: .utf8)!
        } catch {
            return error.localizedDescription
        }
    }
}
extension FloorModel: CustomDebugStringConvertible {
    public var debugDescription: String {
        do {
            let data = try jsonEncoder.encode(self)
            return String(data: data, encoding: .utf8)!
        } catch {
            return error.localizedDescription
        }
    }
}
extension ElevatorModel: CustomDebugStringConvertible {
    public var debugDescription: String {
        do {
            let data = try jsonEncoder.encode(self)
            return String(data: data, encoding: .utf8)!
        } catch {
            return error.localizedDescription
        }
    }
}
