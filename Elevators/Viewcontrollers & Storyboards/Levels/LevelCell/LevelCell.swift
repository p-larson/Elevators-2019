//
//  LevelCell.swift
//  Elevators
//
//  Created by Peter Larson on 5/28/19.
//  Copyright © 2019 Peter Larson. All rights reserved.
//

import UIKit
import ElCore

class LevelCell: UICollectionViewCell {
    
    static let selected: UIColor = #colorLiteral(red: 0.9764705896, green: 0.850980401, blue: 0.5490196347, alpha: 1)
    static let reuseIdentifier = "LevelCell"
    
    @IBOutlet weak var insetBox: UIView!
    @IBOutlet weak var lockedImage: UIImageView!
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var starsContainer: UIStackView!
    
    public var stars: [UIImageView] {
        return starsContainer.subviews.compactMap({ (view) -> UIImageView? in
            return view as? UIImageView
        }).sorted(by: { (image1, image2) -> Bool in
            return image1.tag < image2.tag
        })
    }
    
    class var normalTransform: CGAffineTransform {
        return .init(scaleX: 9 / 10, y: 9 / 10)
    }
    
    class var selectedTransform: CGAffineTransform {
        return .init(scaleX: 95 / 100, y: 95 / 100)
    }
    
    public var model: LevelModel! {
        didSet {
            self.label.text = model.name
        }
    }
    
    public var boxColor: UIColor {
        switch model.state {
        case .unlocked:
            return #colorLiteral(red: 0.9254901961, green: 0.662745098, blue: 0.1803921569, alpha: 1)
        case .locked:
            return #colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 1)
        }
    }
    
    private func setupView() {
        self.insetBox.layer.cornerRadius = 10
        self.insetBox.clipsToBounds = true
        self.insetBox.backgroundColor = boxColor
        self.lockedImage.isHidden = model.state != .locked
        self.label.isHidden = model.state == .locked
        self.transform = LevelCell.normalTransform
        self.label.numberOfLines = 0
        self.label.minimumScaleFactor = 0.25
        self.label.lineBreakMode = .byClipping
        self.label.adjustsFontSizeToFitWidth = true
        self.starsContainer.isHidden = model.state == .locked
        
        let completed = Int.random(in: 0...2)
        
        self.stars.forEach { (imageView) in
            if imageView.tag <= completed {
                imageView.image = #imageLiteral(resourceName: "gold star")
            } else {
                imageView.image = #imageLiteral(resourceName: "gray star")
            }
        }
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    public override func layoutSubviews() {
        self.setupView()
        super.layoutSubviews()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

}
