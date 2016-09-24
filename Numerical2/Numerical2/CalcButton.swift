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
    
    
    override var isEnabled:Bool{
        didSet {
            updateEnabledState()
        }
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        self.addTarget(self, action: #selector(CalcButton.touchDown), for: UIControlEvents.touchDown)
        self.addTarget(self, action: #selector(CalcButton.touchDown), for: UIControlEvents.touchDragEnter)
        
        self.addTarget(self, action: #selector(CalcButton.touchUp), for: UIControlEvents.touchCancel)
        self.addTarget(self, action: #selector(CalcButton.touchUp), for: UIControlEvents.touchUpInside)
        self.addTarget(self, action: #selector(CalcButton.touchUp), for: UIControlEvents.touchDragExit)
        
        self.updateEnabledState()
        
        
    }
    
    func updateEnabledState() {
        
        if isEnabled {
            setTitleColor(UIColor.white, for: UIControlState())
            self.backgroundColor = baseColor
        } else {
            setTitleColor(UIColor.white.withAlphaComponent(0.33), for: UIControlState())
            self.backgroundColor = baseColor.withAlphaComponent(0.0)
        }
        
    }
    
    func touchDown() {
        
        UIView.animate(withDuration: 0.05, delay: 0.0, options: UIViewAnimationOptions.allowUserInteraction, animations: { () -> Void in
            
            self.layer.setAffineTransform(CGAffineTransform(scaleX: 0.9, y: 0.9))
            self.backgroundColor = self.highlightColor
            
            }) { (complete) -> Void in
                
        }
        
    }
    
    func touchUp() {
        UIView.animate(withDuration: 0.075, delay: 0.0, options: UIViewAnimationOptions.allowUserInteraction, animations: { () -> Void in
//            backgroundBox.alpha = 0
            self.layer.setAffineTransform(CGAffineTransform(scaleX: 1.0, y: 1.0))
            self.updateEnabledState()
            }) { (complete) -> Void in
//                backgroundBox.removeFromSuperview()
        }
    }
    

    
    
    
}
