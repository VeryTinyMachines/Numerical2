//
//  WatchCalculatorButtonTableController.swift
//  Numerical2
//
//  Created by Kevin Enax on 10/8/15.
//  Copyright © 2015 Very Tiny Machines. All rights reserved.
//

import WatchKit

class WatchCalculatorThreeButtonRow: NSObject {

    @IBOutlet var leftButton: WKInterfaceButton!
    var leftString : String?
    @IBOutlet var middleButton: WKInterfaceButton!
    var middleString : String?
    @IBOutlet var rightButton: WKInterfaceButton!
    var rightString : String?
    
    let defaultColor = UIColor(red:0.2, green:0.2, blue:0.2, alpha:1)
    let highlightedColor = UIColor(red:0.4, green:0.4, blue:0.4, alpha:1)
    
    var delegate : WatchButtonDelegate?
    
    func configureButtons(leftString:String, middleString:String, rightString:String) {
        self.leftString = leftString
        leftButton.setTitle(leftString)
        leftButton.setBackgroundColor(defaultColor)
        
        self.middleString = middleString
        middleButton.setTitle(middleString)
        middleButton.setBackgroundColor(defaultColor)
        
        self.rightString = rightString
        rightButton.setTitle(rightString)
        if rightString == "C" {
        } else {
            rightButton.setBackgroundColor(defaultColor)
        }
    }
    
    @IBAction func leftButtonPressed() {
        if let delegate = self.delegate, leftString = self.leftString {
            delegate.buttonPressedWithTitle(leftString);
        }
        leftButton.setBackgroundColor(highlightedColor)
        let delayTime = dispatch_time(DISPATCH_TIME_NOW, Int64(0.1 * Double(NSEC_PER_SEC)))
        dispatch_after(delayTime, dispatch_get_main_queue()) { () -> Void in
            self.leftButton.setBackgroundColor(self.defaultColor)
        }
    }
    
    @IBAction func middleButtonPressed() {
        if let delegate = self.delegate, middleString = self.middleString {
            delegate.buttonPressedWithTitle(middleString);
        }
        middleButton.setBackgroundColor(highlightedColor)
        let delayTime = dispatch_time(DISPATCH_TIME_NOW, Int64(0.1 * Double(NSEC_PER_SEC)))
        dispatch_after(delayTime, dispatch_get_main_queue()) { () -> Void in
            self.middleButton.setBackgroundColor(self.defaultColor)
        }
    }
    
    @IBAction func rightButtonPressed() {
        if let delegate = self.delegate, rightString = self.rightString {
            delegate.buttonPressedWithTitle(rightString);
        }
        var normalColor : UIColor = defaultColor
        var highlightedColor : UIColor = self.highlightedColor
        if rightString == "C" {
            highlightedColor = lightenColor(normalColor)
        }
        rightButton.setBackgroundColor(highlightedColor)
        let delayTime = dispatch_time(DISPATCH_TIME_NOW, Int64(0.1 * Double(NSEC_PER_SEC)))
        dispatch_after(delayTime, dispatch_get_main_queue()) { () -> Void in
            self.rightButton.setBackgroundColor(normalColor)
        }
    }
    
    func lightenColor(color:UIColor) -> UIColor {
        var hue : CGFloat = 0.0
        var saturation : CGFloat = 0.0
        var brightness : CGFloat = 0.0
        var alpha : CGFloat = 0.0
        if(color.getHue(&hue, saturation: &saturation, brightness: &brightness, alpha: &alpha)) {
            return UIColor(hue: hue, saturation: saturation, brightness: brightness*1.3, alpha: alpha)
        }
        return color
    }
}
