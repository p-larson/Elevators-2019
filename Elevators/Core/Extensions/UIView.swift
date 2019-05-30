//
//  UIView-extensions.swift
//  Elevators
//
//  Created by Peter Larson on 5/28/19.
//  Copyright © 2019 Peter Larson. All rights reserved.
//

import UIKit

extension UIView {
    public func adjust(_ radius: CGFloat? = nil) {
        layer.cornerRadius = radius ?? 10
        clipsToBounds = true
    }
    
    var highlightedBorder: UIColor {
        return .white
    }
    
    var borderWidth: CGFloat {
        return 6
    }
    
    func highlight(duration: TimeInterval? = nil, _ on: Bool = false) {
        
        let fromColor = UIColor.clear.cgColor, toColor = highlightedBorder.cgColor
        
        layer.borderWidth = 5
        layer.borderColor = on ? toColor : fromColor
        
        guard let duration = duration else {
            return
        }
        
        let animation = CABasicAnimation(keyPath: "borderColor")
        
        animation.fromValue = on ? fromColor : toColor
        animation.toValue = on ? toColor : fromColor
        animation.duration = duration
        animation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeOut)
        
        layer.add(animation, forKey: "borderColor")
    }
}
