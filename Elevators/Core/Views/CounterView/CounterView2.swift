//
//  CounterView.swift
//  Elevators
//
//  Created by Peter Larson on 5/28/19.
//  Copyright © 2019 Peter Larson. All rights reserved.
//

import UIKit

@IBDesignable public final class CounterView: UIView {
    
    @IBInspectable public var mainColor: UIColor = #colorLiteral(red: 0.5843137503, green: 0.8235294223, blue: 0.4196078479, alpha: 1) {
        didSet {
            
        }
    }
    
    @IBInspectable public var fontColor: UIColor = #colorLiteral(red: 0.1960784346, green: 0.3411764801, blue: 0.1019607857, alpha: 1) {
        didSet {
            
        }
    }
    
    public override func awakeFromNib() {
        super.awakeFromNib()
    }
}
