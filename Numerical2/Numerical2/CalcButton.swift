//
//  CalcButton.swift
//  Numerical2
//
//  Created by Andrew J Clark on 24/08/2015.
//  Copyright © 2015 Very Tiny Machines. All rights reserved.
//

import UIKit

class CalcButton: UIButton {
    
    var baseColor:UIColor = UIColor(red: 255 / 255, green: 255 / 255, blue: 255 / 255, alpha: 0.1) {
        didSet {
            updateEnabledState()
        }
    }
    
    var highlightColor:UIColor = UIColor(red: 255 / 255, green: 255 / 255, blue: 255 / 255, alpha: 0.5)
    
    
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
        
        self.updateEnabledState()
        
        
    }
    
    func updateEnabledState() {
        
        if enabled {
            setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
            self.backgroundColor = baseColor
        } else {
            setTitleColor(UIColor.whiteColor().colorWithAlphaComponent(0.33), forState: UIControlState.Normal)
            self.backgroundColor = baseColor.colorWithAlphaComponent(0.0)
        }
        
    }
    
    func touchDown() {
        
        UIView.animateWithDuration(0.05, delay: 0.0, options: UIViewAnimationOptions.AllowUserInteraction, animations: { () -> Void in
            
            self.layer.setAffineTransform(CGAffineTransformMakeScale(0.9, 0.9))
            self.backgroundColor = self.highlightColor
            
            }) { (complete) -> Void in
                
        }
        
    }
    
    func touchUp() {
        UIView.animateWithDuration(0.075, delay: 0.0, options: UIViewAnimationOptions.AllowUserInteraction, animations: { () -> Void in
//            backgroundBox.alpha = 0
            self.layer.setAffineTransform(CGAffineTransformMakeScale(1.0, 1.0))
            self.updateEnabledState()
            }) { (complete) -> Void in
//                backgroundBox.removeFromSuperview()
        }
    }
    

    
    
    
}
