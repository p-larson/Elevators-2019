//
//  Storyboard.swift
//  Elevators
//
//  Created by Peter Larson on 5/27/19.
//  Copyright © 2019 Peter Larson. All rights reserved.
//

import UIKit

internal enum Storyboard: String {
    case Main, Levels, Game
    
    internal var instance: UIStoryboard {
        return UIStoryboard.init(name: rawValue, bundle: Bundle.main)
    }
}
