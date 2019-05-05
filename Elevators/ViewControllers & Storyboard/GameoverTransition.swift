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

public class GameoverTransition: NSObject, UIViewControllerAnimatedTransitioning {
    
    public weak var start: UIView?
    public weak var context: UIViewControllerContextTransitioning?
    
    public init(start: UIView) {
        self.start = start
        super.init()
    }
    
    public func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.5
    }
    
    public func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        
        guard
            let from = transitionContext.viewController(forKey: .from),
            let to = transitionContext.viewController(forKey: .to),
            let snapshot = from.view.snapshotView(afterScreenUpdates: false)
        else {
            transitionContext.completeTransition(false)
            return
        }
        
        print(from, to)
        
        self.context = transitionContext
        
        let container = transitionContext.containerView
        
        
        // Replace from view with snapshot
        container.addSubview(snapshot)
        from.view.removeFromSuperview()
        
        // Animate snapshot off screen
        UIView.animate(withDuration: 0.5, delay: 0, options: [.curveEaseIn], animations: {
            snapshot.center = snapshot.center.add(x: 0, y: snapshot.frame.height)
        }, completion: nil)
        
        // Animate mask
        container.addSubview(to.view)
        animateMask(to: to.view)
    }
    
    func animateMask(to view: UIView) {
        
        guard let start: UIView = start else {
            return
        }
        
        let startPath = UIBezierPath(
            ovalIn: CGRect.init(origin: start.frame.origin, size: start.frame.size)
        )
        
        let radius: CGFloat = (view.frame.width + view.frame.height)
        
        let endPath = UIBezierPath(ovalIn: start.frame.insetBy(dx: -radius, dy: -radius))
        
        let mask = CAShapeLayer()
        mask.path = endPath.cgPath
        view.layer.mask = mask
        
        let animation = CABasicAnimation(keyPath: "path")
        animation.fromValue = startPath.cgPath
        animation.toValue = endPath.cgPath
        animation.delegate = self
        animation.duration = 0.5
        
        mask.add(animation, forKey: "path")
    }
    
}

extension GameoverTransition: CAAnimationDelegate {
    public func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        context?.completeTransition(true)
    }
}
