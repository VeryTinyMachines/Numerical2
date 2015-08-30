//
//  CalcButton.swift
//  Numerical2
//
//  Created by Andrew J Clark on 24/08/2015.
//  Copyright © 2015 Very Tiny Machines. All rights reserved.
//

import UIKit

class CalcButton: UIButton {
    
    override var enabled:Bool{
        didSet {
            updateEnabledState()
        }
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        self.addTarget(self, action: Selector("touchDown"), forControlEvents: UIControlEvents.TouchDown)
        self.addTarget(self, action: Selector("touchDown"), forControlEvents: UIControlEvents.TouchDragEnter)
        
        self.addTarget(self, action: Selector("touchUp"), forControlEvents: UIControlEvents.TouchCancel)
        self.addTarget(self, action: Selector("touchUp"), forControlEvents: UIControlEvents.TouchUpInside)
        self.addTarget(self, action: Selector("touchUp"), forControlEvents: UIControlEvents.TouchDragExit)
        
        
        
    }
    
    func updateEnabledState() {
        
        if enabled {
            setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
        } else {
            setTitleColor(UIColor.whiteColor().colorWithAlphaComponent(0.33), forState: UIControlState.Normal)
        }
        
    }
    
    func touchDown() {
        
        UIView.animateWithDuration(0.05, delay: 0.0, options: UIViewAnimationOptions.AllowUserInteraction, animations: { () -> Void in
            
            self.layer.setAffineTransform(CGAffineTransformMakeScale(0.9, 0.9))
            self.backgroundColor = UIColor.whiteColor().colorWithAlphaComponent(0.5)
            
            }) { (complete) -> Void in
                
        }
        
    }
    
    func touchUp() {
        // Add a UI View to the background, animate it, then remove it
        
//        let backgroundBox = UIView(frame: self.bounds)
        
        self.backgroundColor = UIColor.whiteColor().colorWithAlphaComponent(0.5)
        
        
//        self.addSubview(backgroundBox)
        
        UIView.animateWithDuration(0.075, delay: 0.0, options: UIViewAnimationOptions.AllowUserInteraction, animations: { () -> Void in
//            backgroundBox.alpha = 0
            self.backgroundColor = UIColor.whiteColor().colorWithAlphaComponent(0.0)
            self.layer.setAffineTransform(CGAffineTransformMakeScale(1.0, 1.0))
            self.updateEnabledState()
            }) { (complete) -> Void in
//                backgroundBox.removeFromSuperview()
        }
    }
    

    
    
    
}
