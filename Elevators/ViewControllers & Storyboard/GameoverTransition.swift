//
//  GameoverTransition.swift
//  Elevators
//
//  Created by Peter Larson on 5/5/19.
//  Copyright © 2019 Peter Larson. All rights reserved.
//

import Foundation
import UIKit
import CoreGraphics

public class BubbleTransition: NSObject, UIViewControllerAnimatedTransitioning, CAAnimationDelegate {
    
    public var startView: UIView
    public var duration = 2.5
    public var mode: Mode = .present
    public var reversed: Bool = false
    fileprivate var context: UIViewControllerContextTransitioning? = nil
    
    fileprivate func animation(frame: CGRect) -> CABasicAnimation {
        let a = CABasicAnimation(keyPath: "path")
        
        let radius = sqrt(pow(startView.center.y - frame.height, 2) + pow(startView.center.y - frame.height, 2))
        
        a.toValue = UIBezierPath(ovalIn: startView.frame.insetBy(dx: -radius, dy: -radius)).cgPath
        a.fromValue = UIBezierPath(ovalIn: startView.frame).cgPath
        a.duration = self.duration
        a.delegate = self
        
        
        return a
    }
    
    public init(start: UIView) {
        self.startView = start
    }
    
    public enum Mode {
        case present, dismiss, pop
    }
    public func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return duration
    }
    
    public func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        
        let container = transitionContext.containerView
        
        self.context = transitionContext
        
        guard let fromSnapshot = transitionContext.viewController(forKey: .from)?.view.snapshotView(afterScreenUpdates: false) else {
            fatalError()
        }
        
        transitionContext.viewController(forKey: .from)?.view.isHidden = true
        
        guard let to = transitionContext.viewController(forKey: .to)?.view else {
            fatalError()
        }
        
        to.isHidden = false
        
        container.addSubview(to)
        container.bringSubviewToFront(to)
        container.insertSubview(fromSnapshot, belowSubview: to)
        
        to.layer.mask = CAShapeLayer()
        to.layer.mask?.add(animation(frame: to.frame), forKey: "path")
        
    }
    
    public func animationEnded(_ transitionCompleted: Bool) {
        
    }
    
    public func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        
        
        guard let from = self.context?.viewController(forKey: .from), let to = self.context?.viewController(forKey: .to) else {
            fatalError()
        }
        
        
        
        
        
        self.context?.containerView.removeFromSuperview()
        self.context?.completeTransition(flag)
        self.context = nil
    }
    
}

private extension BubbleTransition {
    func frameForBubble(_ originalCenter: CGPoint, size originalSize: CGSize, start: CGPoint) -> CGRect {
        let lengthX = fmax(start.x, originalSize.width - start.x)
        let lengthY = fmax(start.y, originalSize.height - start.y)
        let offset = sqrt(lengthX * lengthX + lengthY * lengthY) * 2
        let size = CGSize(width: offset, height: offset)
        
        return CGRect(origin: CGPoint.zero, size: size)
    }
}
