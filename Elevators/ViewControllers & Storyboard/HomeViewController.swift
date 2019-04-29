//
//  HomeViewController.swift
//  Elevators
//
//  Created by Peter Larson on 4/23/19.
//  Copyright © 2019 Peter Larson. All rights reserved.
//

import UIKit

public class HomeViewController: UIViewController, ControllerIdentifiable {
    
    static let id: String = "HomeViewController"
    
    public var score: Int = 0
    
    @IBAction func onPlayAgainPress(_ sender: UIButton) {
        
        self.dismiss(animated: true, completion: nil)
    }
    
}
