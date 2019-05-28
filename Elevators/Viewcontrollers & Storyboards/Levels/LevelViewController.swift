//
//  LevelViewController.swift
//  Elevators
//
//  Created by Peter Larson on 5/14/19.
//  Copyright © 2019 Peter Larson. All rights reserved.
//

import Foundation
import UIKit
import ElCore

public class LevelViewController: UIViewController {
    public private(set) var playButtonFontSize: CGFloat!
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var pageControl: UIPageControl!
    
    public let rows: Int = 5, columns = 5
    public let margin: CGFloat = 6.0

    public lazy var futureMedium: UIFont? = _futureMedium()
    public lazy var futureMediumItalic: UIFont? = _futureMediumItalic()
    
    public var models: [LevelModel] = [] {
        didSet {
            collectionView.reloadData()
        }
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}

extension LevelViewController {
    public var cellsPerPage: Int {
        return rows * columns
    }
}

extension LevelViewController {
    private func _futureMedium() -> UIFont? {
        return UIFont(name: "Futura-Medium", size: self.playButtonFontSize)
    }
    
    private func _futureMediumItalic() -> UIFont? {
        return UIFont(name: "Futura-MediumItalic", size: self.playButtonFontSize)
    }
}

extension LevelViewController {
    private func translated(index: IndexPath) -> Int {
        return (index.item % rows) * columns + (index.item / columns) + (index.section * cellsPerPage)
    }
}

extension LevelViewController: UICollectionViewDelegate {
    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        guard let cell = collectionView.cellForItem(at: indexPath) as? LevelCell else {
            return
        }
        
        guard let vc = storyboard?.instantiateViewController(withIdentifier: LevelSelectedViewController.id) else {
            return
        }
        
//        navigationController?.pushViewController(vc, animated: true)
        navigationController?.present(vc, animated: true, completion: {
            print("done")
        })

        UIView.animate(withDuration: 0.2, animations: {
            cell.insetBox.transform = LevelCell.selectedTransform
            
            cell.insetBox.backgroundColor = LevelCell.selected
            
        }) { (succes) in
            if cell.model.state == .locked {
                self.collectionView.deselectItem(at: indexPath, animated: true)
            } else {

            }
        }
    }
    
    public func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        
        guard let cell = collectionView.cellForItem(at: indexPath) as? LevelCell else {
            return
        }
        
        UIView.animate(withDuration: 0.2) {
            
            cell.insetBox.transform = LevelCell.normalTransform
            
            cell.insetBox.backgroundColor = cell.boxColor
        }
    }
}

extension LevelViewController: UICollectionViewDataSource {
    // Delegate
    
    public func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        self.pageControl.currentPage = indexPath.section
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: LevelCell.reuseIdentifier, for: indexPath) as? LevelCell {
            
            let index = translated(index: indexPath)
            
            if models.indices.contains(index) {
                cell.model = models[index]
            }
            
            cell.isHidden = index >= models.count
            
            return cell
        }
        return LevelCell()
    }
}

extension LevelViewController: UICollectionViewDelegateFlowLayout {
    
    public func numberOfSections(in collectionView: UICollectionView) -> Int {
        return Int((Double(models.count) / Double(rows * columns)).rounded(.up))
    }
    
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return cellsPerPage
    }
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: margin, left: margin, bottom: margin, right: margin)
    }
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let insets: UIEdgeInsets = self.collectionView(collectionView, layout: collectionViewLayout, insetForSectionAt: indexPath.section)
        
        let insetFrame = collectionView.frame.inset(by: insets)
        
        let width = (insetFrame.width) / CGFloat(rows)
        let height = (insetFrame.height) / CGFloat(columns)
        
        return CGSize(width: width, height: height)
    }
}

extension LevelViewController {
    public override func viewDidLoad() {
        collectionView.allowsMultipleSelection = false
        
        collectionView.delegate = self
        collectionView.dataSource = self
        
        let levelCellNib = UINib(nibName: "LevelCell", bundle: Bundle.main)
        
        collectionView.register(levelCellNib, forCellWithReuseIdentifier: LevelCell.reuseIdentifier)
        
        print(pageControl.center, collectionView.center)
        print(pageControl.frame.size, collectionView.frame.size)
        
        models = (1...100).map({ (number) -> LevelModel in
            // The optional initializer is only to warn it's for testing use only
            return LevelModel(number: number, name: String(number), state: number < 20 ? .unlocked:.locked)!
        })
    }
}
