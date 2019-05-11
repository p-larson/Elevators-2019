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

public class BubbleTransition: NSObject, UIViewControllerAnimatedTransitioning {
    
    open var startView: UIView
    open var duration = 2.5
    open var mode: Mode = .present
    fileprivate var context: UIViewControllerContextTransitioning? = nil
    
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
        
        let fromVC = transitionContext.viewController(forKey: .from), toVC = transitionContext.viewController(forKey: .to)
        
        
        fromVC?.beginAppearanceTransition(false, animated: true)
        
        if toVC?.modalPresentationStyle == .custom {
            toVC?.beginAppearanceTransition(true, animated: true)
        }
        
        if self.mode == .present {
            
            guard let to = transitionContext.view(forKey: .to) else {
                return
            }
            
            container.addSubview(to)
            
            let animation: CABasicAnimation = {
                let a = CABasicAnimation(keyPath: "path")
                
                let radius = sqrt(pow(startView.center.y - to.frame.height, 2) + pow(startView.center.y - to.frame.height, 2))
                
                a.toValue = UIBezierPath(ovalIn: startView.frame.insetBy(dx: -radius, dy: -radius)).cgPath
                a.fromValue = UIBezierPath(ovalIn: startView.frame).cgPath
                a.duration = self.duration
                a.delegate = self
                
                return a
            }()
            
            to.layer.add(animation, forKey: "path")
        } else {
            
            guard let view = (mode == .pop) ? transitionContext.view(forKey: .to) : transitionContext.view(forKey: .from) else {
                return
            }
            
            container.addSubview(view)
            
            let animation: CABasicAnimation = {
                let a = CABasicAnimation(keyPath: "path")
                
                let radius = sqrt(pow(startView.center.y - view.frame.height, 2) + pow(startView.center.y - view.frame.height, 2))
                
                a.toValue = UIBezierPath(ovalIn: startView.frame.insetBy(dx: -radius, dy: -radius)).cgPath
                a.fromValue = UIBezierPath(ovalIn: startView.frame).cgPath
                a.duration = self.duration
                a.delegate = self
                
                return a
            }()
            
            view.layer.add(animation, forKey: "path")
        }
        
        
        //        let containerView = transitionContext.containerView
        //
        //        let fromViewController = transitionContext.viewController(forKey: .from)
        //        let toViewController = transitionContext.viewController(forKey: .to)
        //
        //
        //        if transitionMode == .present {
        //            fromViewController?.beginAppearanceTransition(false, animated: true)
        //            if toViewController?.modalPresentationStyle == .custom {
        //                toViewController?.beginAppearanceTransition(true, animated: true)
        //            }
        //
        //            let presentedControllerView = transitionContext.view(forKey: .to)!
        //            let originalCenter = presentedControllerView.center
        //            let originalSize = presentedControllerView.frame.size
        //
        //            bubble = UIView()
        //
        //            bubble.frame = frameForBubble(originalCenter, size: originalSize, start: startingPoint)
        //            bubble.layer.cornerRadius = bubble.frame.size.height / 2
        //            bubble.center = startingPoint
        //            bubble.transform = CGAffineTransform(scaleX: 0.001, y: 0.001)
        //            bubble.backgroundColor = bubbleColor
        //            containerView.addSubview(bubble)
        //
        //            presentedControllerView.center = startingPoint
        //            presentedControllerView.transform = CGAffineTransform(scaleX: 0.001, y: 0.001)
        //            presentedControllerView.alpha = 0
        //            containerView.addSubview(presentedControllerView)
        //
        //            UIView.animate(withDuration: duration, animations: {
        //                self.bubble.transform = CGAffineTransform.identity
        //                presentedControllerView.transform = CGAffineTransform.identity
        //                presentedControllerView.alpha = 1
        //                presentedControllerView.center = originalCenter
        //            }, completion: { (_) in
        //                transitionContext.completeTransition(true)
        //                self.bubble.isHidden = true
        //                if toViewController?.modalPresentationStyle == .custom {
        //                    toViewController?.endAppearanceTransition()
        //                }
        //                fromViewController?.endAppearanceTransition()
        //            })
        //        } else {
        //            // dismiss
        //
        //            if fromViewController?.modalPresentationStyle == .custom {
        //                fromViewController?.beginAppearanceTransition(false, animated: true)
        //            }
        //            toViewController?.beginAppearanceTransition(true, animated: true)
        //
        //            guard let returningControllerView = (transitionMode == .pop) ? toViewController?.view : fromViewController?.view else {
        //                return
        //            }
        //            let originalCenter = returningControllerView.center
        //            let originalSize = returningControllerView.frame.size
        //
        //            bubble.frame = frameForBubble(originalCenter, size: originalSize, start: startingPoint)
        //            bubble.layer.cornerRadius = bubble.frame.size.height / 2
        //            bubble.backgroundColor = bubbleColor
        //            bubble.center = startingPoint
        //            bubble.isHidden = false
        //
        //            let animation = CABasicAnimation(keyPath: "path")
        //
        //            UIBezierPath(ovalIn: )
        //
        //            /*
        //             // 1
        //             let fullHeight = toView.bounds.height
        //             let extremePoint = CGPoint(x: triggerButton.center.x,
        //             y: triggerButton.center.y - fullHeight)
        //             // 2
        //             let radius = sqrt((extremePoint.x*extremePoint.x) +
        //             (extremePoint.y*extremePoint.y))
        //             // 3
        //             let circleMaskPathFinal = UIBezierPath(ovalIn: triggerButton.frame.insetBy(dx: -radius,
        //             dy: -radius))
        //
        //             */
        //
        //            UIView.animate(withDuration: duration, animations: {
        //                self.bubble.transform = CGAffineTransform(scaleX: 0.001, y: 0.001)
        //                returningControllerView.transform = CGAffineTransform(scaleX: 0.001, y: 0.001)
        //                returningControllerView.center = self.startingPoint
        //                returningControllerView.alpha = 0
        //
        //                if self.transitionMode == .pop {
        //                    containerView.insertSubview(returningControllerView, belowSubview: returningControllerView)
        //                    containerView.insertSubview(self.bubble, belowSubview: returningControllerView)
        //                }
        //            }, completion: { (completed) in
        //                transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
        //
        //                if !transitionContext.transitionWasCancelled {
        //                    returningControllerView.center = originalCenter
        //                    returningControllerView.removeFromSuperview()
        //                    self.bubble.removeFromSuperview()
        //
        //                    if fromViewController?.modalPresentationStyle == .custom {
        //                        fromViewController?.endAppearanceTransition()
        //                    }
        //                    toViewController?.endAppearanceTransition()
        //                }
        //            })
        // }
    }
}

extension BubbleTransition: CAAnimationDelegate {
    public func animationEnded(_ transitionCompleted: Bool) {
        print("animation ended")
        context?.completeTransition(!(context?.transitionWasCancelled ?? false))
        
        //        if context?.transitionWasCancelled {
        //            returningControllerView.center = originalCenter
        //            returningControllerView.removeFromSuperview()
        //            self.bubble.removeFromSuperview()
        
        if context?.viewController(forKey: .from)?.modalPresentationStyle == .custom {
            context?.viewController(forKey: .from)?.endAppearanceTransition()
        }
        context?.viewController(forKey: .to)?.endAppearanceTransition()
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
