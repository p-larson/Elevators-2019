//
//  LevelInfoEditorViewController.swift
//  Elevators
//
//  Created by Peter Larson on 7/12/19.
//  Copyright © 2019 Peter Larson. All rights reserved.
//

import Foundation
import UIKit
import Eureka

public final class LevelInfoEditorViewController: FormViewController {
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        form +++ Section("Section1")
            <<< TextRow(){ row in
                row.title = "Text Row"
                row.placeholder = "Enter text here"
            }
            <<< PhoneRow(){
                $0.title = "Phone Row"
                $0.placeholder = "And numbers here"
            }
            +++ Section("Section2")
            <<< DateRow(){
                $0.title = "Date Row"
                $0.value = Date(timeIntervalSinceReferenceDate: 0)
        }
    }
}
