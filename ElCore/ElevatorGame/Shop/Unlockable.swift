//
//  Unlockable.swift
//  ElCore
//
//  Created by Peter Larson on 4/27/19.
//  Copyright © 2019 Peter Larson. All rights reserved.
//

import Foundation

public protocol Unlockable {
    var name: String { get }
    var cost: Int { get }
}
