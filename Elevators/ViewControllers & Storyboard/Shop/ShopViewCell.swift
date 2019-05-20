//
//  ShopViewCell.swift
//  Elevators
//
//  Created by Peter Larson on 5/14/19.
//  Copyright © 2019 Peter Larson. All rights reserved.
//

import UIKit

class ShopViewCell: UICollectionViewCell {
    
    public static let reuseIdentifier = "ShopView"
    
    @IBOutlet weak var imageView: UIImageView!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.backgroundColor = .darkGray
    }

}
