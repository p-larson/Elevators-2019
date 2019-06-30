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
