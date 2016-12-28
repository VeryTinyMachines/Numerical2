//
//  CustomPresentAnimationController.swift
//  CustomTransitions
//
//  Created by Joyce Echessa on 3/3/15.
//  Copyright (c) 2015 Appcoda. All rights reserved.
//

import UIKit

class CustomAnimationController: NSObject, UIViewControllerAnimatedTransitioning {
    
    var isPresenting = true
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.25
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        
        let fromViewController = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.from)!
        let toViewController = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.to)!
        
        let containerView = transitionContext.containerView
        
        if isPresenting {
            
            var finalFrameForVC = transitionContext.finalFrame(for: toViewController)
            
            if NumericalViewHelper.isDevicePad() {
                
                let width:CGFloat = 600.0
                let height:CGFloat = 700.0
                
                finalFrameForVC = CGRect(x: finalFrameForVC.midX - (width / 2), y: finalFrameForVC.midY - (height / 2), width: width, height: height)
            }
            
            // Dim the background
            
            let bounds = UIScreen.main.bounds
            toViewController.view.frame = finalFrameForVC.offsetBy(dx: 0, dy: bounds.size.height)
            containerView.addSubview(toViewController.view)
            
            UIView.animate(withDuration: transitionDuration(using: transitionContext), delay: 0.0, options: UIViewAnimationOptions.curveEaseOut, animations: {
                toViewController.view.frame = finalFrameForVC
                fromViewController.view.alpha = 0.5
            }, completion: { (complete) in
                transitionContext.completeTransition(true)
            })
            
        } else {
            
            let bounds = UIScreen.main.bounds
            
            let snapshotView = fromViewController.view.snapshotView(afterScreenUpdates: false)
            snapshotView?.frame = fromViewController.view.frame
            containerView.addSubview(snapshotView!)
            
            fromViewController.view.removeFromSuperview()
            
            UIView.animate(withDuration: transitionDuration(using: transitionContext), animations: {
                snapshotView?.frame = fromViewController.view.frame.offsetBy(dx: 0, dy: bounds.size.height)
                toViewController.view.alpha = 1.0
            }, completion: {
                finished in
                snapshotView?.removeFromSuperview()
                transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
            })
        }
        
        
        
        
    }
    
}
