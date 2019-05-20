//
//  ShopViewController.swift
//  Elevators
//
//  Created by Peter Larson on 5/14/19.
//  Copyright © 2019 Peter Larson. All rights reserved.
//

import Foundation
import UIKit
import ElCore

public class ShopViewController: UIViewController, ControllerIdentifiable {
    public static let id = "ShopViewController"
    public var game: GameScene!
    public var kind: Skin.Kind = Skin.Kind.Elevator
    @IBOutlet weak var shopView: UICollectionView!
    public let cellsPerSection = 16
    
    public var items: [Skin] {
        return game.shopManager.unlockables(by: kind)
    }
}

extension ShopViewController {
    
    public override func viewDidLoad() {
        shopView.register(UINib(nibName: "ShopViewCell", bundle: Bundle.main), forCellWithReuseIdentifier: ShopViewCell.reuseIdentifier)
        
        shopView.dataSource = self
        
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        
        let margin = CGFloat(2)
        
        layout.sectionInset = UIEdgeInsets(top: margin, left: margin, bottom: margin, right: margin)
        layout.itemSize = CGSize(width: shopView.frame.width / 4, height: shopView.frame.width / 4)
        layout.minimumInteritemSpacing = margin
        layout.minimumLineSpacing = margin
        
        shopView.collectionViewLayout = layout
        shopView.backgroundColor = .red
    }
    
    public override func viewDidAppear(_ animated: Bool) {
        
    }
}


extension ShopViewController {
    public func image(for index: Int) -> UIImage? {
        print("image", index)
        let skins = game.shopManager.unlockables(by: kind)
        
        if skins.indices.contains(index) {
            let skin: Skin = skins[index]
            if kind == .Elevator {
                return skin.preview
            } else if kind == .Player {
                return skin.preview
            }
        }
        
        return nil
    }
}

extension ShopViewController: UICollectionViewDataSource {
    
    public func numberOfSections(in collectionView: UICollectionView) -> Int {
        return game.shopManager.unlockables(by: kind).count / cellsPerSection
    }
    
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return section + 1 == items.count / cellsPerSection ? items.count % cellsPerSection : cellsPerSection
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ShopViewCell.reuseIdentifier, for: indexPath) as! ShopViewCell
        
        cell.imageView.image = self.image(for: indexPath.item)
        
        return cell
    }
    
}

extension ShopViewController: UICollectionViewDelegate {
    
}
