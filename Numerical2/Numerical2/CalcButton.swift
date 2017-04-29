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
        
        NotificationCenter.default.addObserver(self, selector: #selector(WorkPanelViewController.themeChanged), name: Notification.Name(rawValue: PremiumCoordinatorNotification.themeChanged), object: nil)
    }
    
    func themeChanged() {
        updateEnabledState()
    }
    
    func updateEnabledState() {
        
        let color = ThemeCoordinator.shared.foregroundColorForCurrentTheme()
        
        if isEnabled {
            setTitleColor(color, for: UIControlState())
            // self.backgroundColor = color.withAlphaComponent(0.1)
            self.backgroundColor = UIColor.clear // Enabled buttons have a clear background
            self.titleLabel?.numberOfLines = 1
            self.titleLabel?.adjustsFontSizeToFitWidth = true
            self.titleLabel?.lineBreakMode = NSLineBreakMode.byClipping
            
        } else {
            setTitleColor(color.withAlphaComponent(0.33), for: UIControlState())
            // self.backgroundColor = UIColor.clear
            //self.backgroundColor = UIColor(white: 0.0, alpha: 0.02)
            self.backgroundColor = UIColor.clear // Enabled buttons have a clear background
        }
        
        self.layer.borderWidth = 0.5
        self.layer.borderColor = color.withAlphaComponent(0.25).cgColor
        
        updateLockViewStyle()
    }
    
    func updateLockViewStyle() {
        
        switch keyStyle {
        case .Available:
            // Hide the entire lockView.
            lockView?.image = nil
        case .AvailablePremium:
            lockView?.image = UIImage(named: "PremiumBug_3")?.withRenderingMode(UIImageRenderingMode.alwaysTemplate)
        case .PremiumRequired:
            // Premium is required
            lockView?.image = UIImage(named: "PremiumBug_3")?.withRenderingMode(UIImageRenderingMode.alwaysTemplate)
        }
        
        if self.isEnabled {
            lockView?.alpha = 0.50
        } else {
            lockView?.alpha = 0.20
        }
        
        lockView?.tintColor = ThemeCoordinator.shared.foregroundColorForCurrentTheme()
        
        updateLockViewPosition()
    }
    
    func updateLockViewPosition() {
        let border:CGFloat = 0
        let width:CGFloat = ((self.frame.width + self.frame.height) / 2) / 12
        
        lockView?.frame = CGRect(x: border, y: border, width: width, height: width)
    }
    
    func touchDown() {
        self.backgroundColor = self.highlightColor
    }
    
    func touchUp() {
        
        self.updateEnabledState()
        /*
        // Make a UIView, add it, and then fade it out really quickly
        let whiteView = UIView(frame: CGRect(x: 0, y: 0, width: self.frame.width, height: self.frame.height))
        whiteView.backgroundColor = self.highlightColor
        self.addSubview(whiteView)
        
        UIView.animate(withDuration: 0.1, delay: 0.0, options: UIViewAnimationOptions.allowUserInteraction, animations: { () -> Void in
            whiteView.alpha = 0.0
            }) { (complete) -> Void in
                whiteView.removeFromSuperview()
        }
        */
    }
}
