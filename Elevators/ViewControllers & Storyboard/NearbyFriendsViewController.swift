//
//  NearbyFriendsViewController.swift
//  Elevators
//
//  Created by Peter Larson on 5/1/19.
//  Copyright © 2019 Peter Larson. All rights reserved.
//

import Foundation
import UIKit
import CoreBluetooth
import ElCore

public class NearbyFriendsViewController: UIViewController, ControllerIdentifiable {
    
    let nearbyFriends = NearbyFriendsManager()
    
    static var id: String {
        return "NearbyFriendsViewController"
    }
    
    public override func viewDidLoad() {
        self.nearbyFriends.delegate = self
    }
}

extension NearbyFriendsViewController: NearbyFriendsManagerDelegate {
    public func discovered(advertisement data: [String : Any]) {
        print(data)
    }
}
