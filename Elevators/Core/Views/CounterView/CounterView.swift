//
//  CounterView.swift
//  Elevators
//
//  Created by Peter Larson on 5/29/19.
//  Copyright © 2019 Peter Larson. All rights reserved.
//

import Foundation
import UIKit

public class CounterView: UIView {
    
    public var string: String? = nil {
        didSet {
            label.text = self.string
        }
    }
    
    private lazy var imageView: UIImageView! = {
        return UIImageView()
    }()
    
    private lazy var label: UILabel = {
        let label = UILabel()
        
        label.font = UIFont.init(name: "FiraSans-Medium", size: 10)
        label.textAlignment = .center
        
        return label
    }()
    
    private lazy var verticleSpace: NSLayoutConstraint = {
        return NSLayoutConstraint(
            item: label,
            attribute: .top,
            relatedBy: .equal,
            toItem: imageView,
            attribute: .centerY,
            multiplier: 1,
            constant: 0
        )
    }()
    
    private lazy var imageWidth: NSLayoutConstraint = {
        return NSLayoutConstraint(
            item: imageView!,
            attribute: .width,
            relatedBy: .equal,
            toItem: self,
            attribute: .width,
            multiplier: 4.0 / 5.0,
            constant: 0
        )
    }()
    
    @IBInspectable
    public var kind: Kind = .coin {
        didSet {
            updateKind()
        }
    }
    
    public func updateKind() {
        imageView.image = kind.image
        label.backgroundColor = kind.color
        label.textColor = kind.color.darker()
    }
    
    @objc
    public enum Kind: Int {
        case coin, gem, heart
        
        var color: UIColor {
            switch self {
            case .coin:
                return #colorLiteral(red: 0.9843137255, green: 0.9294117647, blue: 0.7568627451, alpha: 1)
            case .gem:
                return #colorLiteral(red: 0.7960784314, green: 0.9960784314, blue: 0.862745098, alpha: 1)
            case .heart:
                return #colorLiteral(red: 0.8901960784, green: 0.6196078431, blue: 0.7294117647, alpha: 1)
            }
        }
        
        var image: UIImage {
            switch self {
            case .coin:
                return #imageLiteral(resourceName: "coin-backdrop")
            case .gem:
                return #imageLiteral(resourceName: "gem-backdrop")
            case .heart:
                return #imageLiteral(resourceName: "heart-backdrop")
            }
        }
    }
    
    public override init(frame: CGRect) {
        
        super.init(frame: frame)
        self.updateKind()
        self.setupViews()
        self.setupConstraints()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.updateKind()
        self.setupViews()
        self.setupConstraints()
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        
        verticleSpace.constant = imageView.frame.height / 3
        label.font = label.font.withSize(label.frame.height * (2.0 / 3.0))
        label.layer.cornerRadius = label.frame.height / 4
        label.layer.masksToBounds = true
    }
    
    private func setupViews() {
        self.addSubview(imageView)
        self.insertSubview(label, aboveSubview: imageView)
        
        label.translatesAutoresizingMaskIntoConstraints = false
        imageView.translatesAutoresizingMaskIntoConstraints = false
        
        self.autoresizingMask = [.flexibleWidth, .flexibleHeight]
    }
    
    private func setupConstraints() {
        let constraints = [
            
            imageWidth,
            
            NSLayoutConstraint(
                item: imageView!,
                attribute: .height,
                relatedBy: .equal,
                toItem: imageView!,
                attribute: .width,
                multiplier: 1,
                constant: 0
            ),
            
            NSLayoutConstraint(
                item: imageView!,
                attribute: .centerX,
                relatedBy: .equal,
                toItem: self,
                attribute: .centerX,
                multiplier: 1,
                constant: 0
            ),
            
            NSLayoutConstraint(
                item: imageView!,
                attribute: .top,
                relatedBy: .equal,
                toItem: self,
                attribute: .top,
                multiplier: 1,
                constant: 0
            ),
            
            NSLayoutConstraint(
                item: label,
                attribute: .centerX,
                relatedBy: .equal,
                toItem: self,
                attribute: .centerX,
                multiplier: 1,
                constant: 0
            ),
            
            NSLayoutConstraint(
                item: label,
                attribute: .width,
                relatedBy: .equal,
                toItem: imageView,
                attribute: .width,
                multiplier: 4.0 / 5.0,
                constant: 0
            ),
            
            NSLayoutConstraint(
                item: label,
                attribute: .height,
                relatedBy: .equal,
                toItem: imageView,
                attribute: .height,
                multiplier: 3.0 / 10.0,
                constant: 0
            ),
            
            verticleSpace
        ]
        
        NSLayoutConstraint.activate(constraints)
    }
}
