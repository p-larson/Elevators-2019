//
//  LarsonSegmentControl.swift
//  Elevators
//
//  Created by Peter Larson on 7/28/19.
//  Copyright © 2019 Peter Larson. All rights reserved.
//

import UIKit

class LarsonSegmentControl: UIControl {
    
    var buttons = [UIButton]()
    var selector: UIView!
    var selectedSegmentIndex = 0
    var onSelectionChange: ((_ rawValue: Int) -> Void)? = nil
    var buttonTitles = [String]()
    var textColor: UIColor = .lightGray
    var selectorColor: UIColor = .darkGray
    var selectorTextColor: UIColor = .green
    var font = UIFont.systemFont(ofSize: 12.0)
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        updateView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        fatalError("init(coder:) has not been implemented")
    }
    
    
    func updateView() {
        buttons.removeAll()
        
        subviews.forEach { (view) in
            view.removeFromSuperview()
        }
        
        for buttonTitle in buttonTitles {
            
            let button = UIButton(type: .system)
            
            button.setTitle(buttonTitle, for: .normal)
            button.setTitleColor(textColor, for: .normal)
            button.titleLabel?.font = font
            button.addTarget(self, action: #selector(buttonTapped(button:)), for: .touchUpInside)
            buttons.append(button)
        }
        
        
        buttons.first?.setTitleColor(selectorTextColor, for: .normal)
        
        let selectorWidth = frame.width / CGFloat(buttonTitles.count)
        
        let y =    (self.frame.maxY - self.frame.minY) - 3.0
        
        selector = UIView.init(frame: CGRect.init(x: 0, y: y, width: selectorWidth, height: 3.0))
        //selector.layer.cornerRadius = frame.height/2
        selector.backgroundColor = selectorColor
        self.addSubview(selector)
        
        let stackView = UIStackView(arrangedSubviews: buttons)
        
        stackView.axis = .horizontal
        stackView.alignment = .fill
        stackView.distribution = .fillEqually
        stackView.spacing = 0.0
        
        self.addSubview(stackView)
        
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        stackView.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        stackView.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
        stackView.leftAnchor.constraint(equalTo: self.leftAnchor).isActive = true
        stackView.rightAnchor.constraint(equalTo: self.rightAnchor).isActive = true
        
        
    }
    
    @objc func buttonTapped(button: UIButton) {
        for (index, enumeratedButton) in buttons.enumerated() {
            enumeratedButton.setTitleColor(textColor, for: .normal)
            if enumeratedButton == button {
                selectedSegmentIndex = index
                let selectorStartPosition = frame.width / CGFloat(buttons.count) * CGFloat(index)
                UIView.animate(withDuration: 0.3, animations: {
                    self.selector.frame.origin.x = selectorStartPosition
                })
                enumeratedButton.setTitleColor(selectorTextColor, for: .normal)
                self.onSelectionChange?(index)
            }
        }
        
        self.sendActions(for: .valueChanged)
    }
    
    
    func updateSegmentedControlSegs(index: Int) {
        for btn in buttons {
            btn.setTitleColor(textColor, for: .normal)
        }
        let  selectorStartPosition = frame.width / CGFloat(buttons.count) * CGFloat(index)
        
        UIView.animate(withDuration: 0.3, animations: {
            self.selector.frame.origin.x = selectorStartPosition
        })
        
        buttons[index].setTitleColor(selectorTextColor, for: .normal)
    }
}
