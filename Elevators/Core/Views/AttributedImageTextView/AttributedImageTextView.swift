//
//  AttributedImageTextView.swift
//  Elevators
//
//  Created by Peter Larson on 5/29/19.
//  Copyright © 2019 Peter Larson. All rights reserved.
//

import Foundation
import UIKit
import ElCore

public class AttributedImageTextView: UIImageView {
    
    private var string1: String = "string1", string2: String = "string2"
    
    func set(text1: String, text2: String) {
        self.string1 = text1
        self.string2 = text2
        self.setNeedsLayout()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    override init(image: UIImage?) {
        super.init(image: image)
    }
    
    override init(image: UIImage?, highlightedImage: UIImage?) {
        super.init(image: image, highlightedImage: highlightedImage)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    public override func layoutSubviews() {
        contentMode = .scaleAspectFit
        image = Graphics.image(of: frame.size) { (context) in
            
            let attributed = self.attributes(
                frame: self.frame,
                one: self.string1,
                two: self.string2
            )
            
            attributed.0.draw(in: CGRect.init(origin: .init(x: 0, y: attributed.1), size: self.frame.size))
        }
    }
    
    public var font1 = UIFont(name: "FiraSans-Medium", size: 12) ?? UIFont.systemFont(ofSize: 10)
    public var font2 = UIFont(name: "FiraSans-Bold", size: 10) ?? UIFont.systemFont(ofSize: 10)
    
    private func attributes(frame: CGRect, one: String, two: String) -> (NSAttributedString, CGFloat) {
        let attributed = NSMutableAttributedString()
        
        attributed.append(NSAttributedString(string: one, attributes: [
            NSAttributedString.Key.font:font1.withSize(frame.height / 5)]
        ))
        
        attributed.append(NSAttributedString(string: "\n"))
        
        attributed.append(NSAttributedString(string: two, attributes:
            [NSAttributedString.Key.font:font2.withSize(frame.height / 3)]
        ))
        
        let style = NSMutableParagraphStyle()
        
        style.alignment = .center
        
        let range = attributed.mutableString.range(of: attributed.string)
        
        attributed.addAttribute(NSAttributedString.Key.paragraphStyle, value: style, range: range)
        attributed.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor.white, range: range)
        
        return (attributed, (frame.height / 5 + frame.height / 8) / 2)
    }
}
