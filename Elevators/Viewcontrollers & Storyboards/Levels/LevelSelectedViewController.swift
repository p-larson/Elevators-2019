//
//  LevelSelectedViewController.swift
//  Elevators
//
//  Created by Peter Larson on 5/25/19.
//  Copyright © 2019 Peter Larson. All rights reserved.
//

import Foundation
import ElCore
import UIKit

public class LevelSelectedViewController: UIViewController {
    @IBOutlet weak var box: UIView!
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}

extension LevelSelectedViewController: ControllerIdentifiable {
    static let id: String = "LevelSelectedViewController"
}
