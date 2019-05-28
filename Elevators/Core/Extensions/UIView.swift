//
//  UIView-extensions.swift
//  Elevators
//
//  Created by Peter Larson on 5/28/19.
//  Copyright © 2019 Peter Larson. All rights reserved.
//

import UIKit

extension UIView {
    public func adjust() {
        layer.cornerRadius = 12
        clipsToBounds = true
    }
    
    var highlightedBorder: UIColor {
        return .white
    }
    
    var borderWidth: CGFloat {
        return 6
    }
    
    func highlightAnimation(duration: TimeInterval, reversed: Bool = false) -> CAAnimation {
        
        let animation = CABasicAnimation(keyPath: "borderColor")
        
        let fromColor = backgroundColor?.cgColor ?? UIColor.clear.cgColor, toColor = highlightedBorder.cgColor
        
        animation.fromValue = !reversed ? fromColor : toColor
        animation.toValue = !reversed ? toColor : fromColor
        animation.duration = duration
        animation.timingFunction = CAMediaTimingFunction.init(name: CAMediaTimingFunctionName.easeOut)
        
        return animation
    }
}
