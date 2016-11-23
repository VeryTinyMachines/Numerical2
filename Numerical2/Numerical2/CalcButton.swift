//
//  CalcButton.swift
//  Numerical2
//
//  Created by Andrew J Clark on 24/08/2015.
//  Copyright © 2015 Very Tiny Machines. All rights reserved.
//

import UIKit
import AudioToolbox

class CalcButton: UIButton {
    
    var keyStyle:KeyStyle = KeyStyle.Available
    
    var baseColor:UIColor = UIColor(red: 255 / 255, green: 255 / 255, blue: 255 / 255, alpha: 0.1) {
        didSet {
            updateEnabledState()
        }
    }
    
    var highlightColor:UIColor = UIColor(red: 255 / 255, green: 255 / 255, blue: 255 / 255, alpha: 0.5)
    
    var lockView:UIImageView?
    
    override var isEnabled:Bool{
        didSet {
            updateEnabledState()
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.updateLockViewPosition()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        self.addTarget(self, action: #selector(CalcButton.touchDown), for: UIControlEvents.touchDown)
        self.addTarget(self, action: #selector(CalcButton.touchDown), for: UIControlEvents.touchDragEnter)
        
        self.addTarget(self, action: #selector(CalcButton.touchUp), for: UIControlEvents.touchCancel)
        self.addTarget(self, action: #selector(CalcButton.touchUp), for: UIControlEvents.touchUpInside)
        self.addTarget(self, action: #selector(CalcButton.touchUp), for: UIControlEvents.touchDragExit)
        
        // Add lock button
        let imageView = UIImageView()
        self.addSubview(imageView)
        self.lockView = imageView
        
        self.updateEnabledState()
        
        self.updateLockViewPosition()
    }
    
    func updateEnabledState() {
        
        if isEnabled {
            setTitleColor(UIColor.white, for: UIControlState())
            self.backgroundColor = baseColor
        } else {
            setTitleColor(UIColor.white.withAlphaComponent(0.33), for: UIControlState())
            self.backgroundColor = baseColor.withAlphaComponent(0.0)
        }
        
        titleLabel?.font = StyleFormatter.preferredFontForButtonOfSize(self.frame.size, keyStyle: keyStyle)
        
        updateLockViewStyle()
    }
    
    func updateLockViewStyle() {
        
        switch keyStyle {
        case .Available:
            // Hide the entire lockView.
            lockView?.image = nil
        case .AvailablePremium:
            lockView?.image = UIImage(named: "PremiumBug_3")
        case .PremiumRequired:
            // Premium is required
            lockView?.image = UIImage(named: "PremiumBug_3")
        }
        
        if self.isEnabled {
            lockView?.alpha = 0.50
        } else {
            lockView?.alpha = 0.20
        }
        
        updateLockViewPosition()
    }
    
    func updateLockViewPosition() {
        let border:CGFloat = 0
        let width:CGFloat = ((self.frame.width + self.frame.height) / 2) / 7
        
//        lockView?.frame = CGRect(x: self.bounds.width - border - width, y: self.bounds.height - border - width, width: width, height: width)
        
        lockView?.frame = CGRect(x: border, y: border, width: width, height: width)
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
            self.layer.setAffineTransform(CGAffineTransform(scaleX: 1.0, y: 1.0))
            self.updateEnabledState()
            }) { (complete) -> Void in
        }
    }
}
