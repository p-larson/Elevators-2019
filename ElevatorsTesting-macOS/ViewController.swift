//
//  ViewController.swift
//  ElevatorsTesting-macOS
//
//  Created by Peter Larson on 5/1/19.
//  Copyright © 2019 Peter Larson. All rights reserved.
//

import Cocoa
import ElCore

public class ViewController: NSViewController {
    
    let nearbyFriends = NearbyFriendsManager()

    override public func viewDidLoad() {
        super.viewDidLoad()
        
        self.nearbyFriends.delegate = self
        
        // Do any additional setup after loading the view.
    }

    override public var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }


}

extension ViewController: NearbyFriendsManagerDelegate {
    public func discovered(advertisement data: [String : Any]) {

    }
}
