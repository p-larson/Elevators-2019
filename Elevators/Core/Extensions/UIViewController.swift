//
//  UIViewController.swift
//  Elevators
//
//  Created by Peter Larson on 6/20/19.
//  Copyright © 2019 Peter Larson. All rights reserved.
//

import Foundation
import UIKit

extension UIViewController {
    
    public static let background_image_tag = 8715
    
    private var background: UIImageView {
        get {
            let imageView = self.view.viewWithTag(UIViewController.background_image_tag) as? UIImageView ?? UIImageView()
            
            imageView.tag = UIViewController.background_image_tag
            imageView.translatesAutoresizingMaskIntoConstraints = false
            
            if imageView.superview == nil {
                view.insertSubview(imageView, at: 0)
            }
            
            return imageView
        }
    }
    
    public func setBackground(image: UIImage) {
        
        background.image = image
        background.contentMode = .scaleAspectFill
        
        background.removeConstraints(background.constraints)
        
        background.frame = view.bounds
    }
}
