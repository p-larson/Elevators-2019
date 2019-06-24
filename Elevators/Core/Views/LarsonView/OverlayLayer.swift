//
//  OverlayLayer.swift
//  LarsonViewDemo
//
//  Created by Peter Larson on 6/14/19.
//  Copyright © 2019 Peter Larson. All rights reserved.
//

import UIKit

final public class OverlayLayer: CALayer {
    
    public var animating: Bool = false
    
    @objc weak var view: LarsonView? {
        didSet {
            self.setNeedsDisplay()
        }
    }
    
    @objc public var defaultShadowHeight: CGFloat = 12.0
    
    @objc public var shadowHeight: CGFloat = 12.0
    
    public var shadowBackground: CGRect {
        return CGRect(origin: .zero, size: CGSize(width: frame.width, height: frame.height))
    }
    
    public var fillBackground: CGRect {
        return CGRect(origin: CGPoint.zero, size: CGSize(width: frame.width, height: frame.height - shadowHeight))
    }
    
    init(frame: CGRect, view: LarsonView) {
        super.init()
        
        self.frame = frame
        self.view = view
        
        self.common()
    }
    
    public override init(layer: Any) {
        super.init(layer: layer)
        
        guard let overlay = layer as? OverlayLayer else {
            return
        }
        
        self.defaultShadowHeight = overlay.defaultShadowHeight
        self.shadowHeight = overlay.shadowHeight
        self.view = overlay.view
        self.animating = overlay.animating
        
        self.common()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.common()
    }
    
    public override init() {
        super.init()
        self.common()
    }
    
    private func common() {
        self.drawsAsynchronously = true
        self.masksToBounds = false
        self.shouldRasterize = false
        self.setNeedsDisplay()
    }
    
    public func animate(pressed: Bool, duration: TimeInterval = 0.125) {
        self.removeAllAnimations()
        
        self.sublayers?.forEach({ (sublayer) in
            sublayer.removeAllAnimations()
        })
        
        let animation = CABasicAnimation(keyPath: #keyPath(OverlayLayer.shadowHeight))
        
        animation.toValue = pressed ? 0.0 : defaultShadowHeight
        animation.fromValue = pressed ? shadowHeight : 0.0
        animation.timingFunction = CAMediaTimingFunction(name: .easeOut)
        animation.duration = duration
        
        self.shadowHeight = animation.toValue as! CGFloat
        
        self.add(animation, forKey: "press")
        
        self.animating = true
        
        self.view?.topConstraint?.constant = LarsonView.marginFromTop + (pressed ? self.defaultShadowHeight : 0)
        
        UIView.animate(withDuration: duration, delay: 0, options: .curveEaseOut, animations: {
            self.view?.layoutIfNeeded()
        }) { (success) in
            self.animating = false
        }
    }
    
    override public class func needsDisplay(forKey key: String) -> Bool {
        if key == #keyPath(OverlayLayer.shadowHeight) {
            return true
        }
        
        return super.needsDisplay(forKey: key)
    }
    
    public override func draw(in ctx: CGContext) {
        
        guard let color = view?.color else {
            return
        }
        
        ctx.setFillColor(color.darker().cgColor)
        ctx.addPath(CGPath(rect: shadowBackground, transform: nil))
        ctx.fillPath()
        ctx.setFillColor(color.cgColor)
        
        ctx.addPath(UIBezierPath(roundedRect: fillBackground, byRoundingCorners: [.bottomLeft, .bottomRight], cornerRadii: CGSize(width: cornerRadius, height: cornerRadius)).cgPath)
        
        ctx.fillPath()
        
        super.draw(in: ctx)
    }
}
