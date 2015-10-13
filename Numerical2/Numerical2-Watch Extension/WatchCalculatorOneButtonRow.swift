//
//  WatchCalculatorOneButtonRow.swift
//  Numerical2
//
//  Created by Kevin Enax on 10/8/15.
//  Copyright © 2015 Very Tiny Machines. All rights reserved.
//

import WatchKit

class WatchCalculatorOneButtonRow: NSObject {
    
    @IBOutlet var button: WKInterfaceButton!
    var buttonTitle : String?

    let defaultColor = UIColor(red:0.2, green:0.2, blue:0.2, alpha:1)
    let highlightedColor = UIColor(red:0.4, green:0.4, blue:0.4, alpha:1)
    
    var delegate : WatchButtonDelegate?
    
    func configureButtons(leftString:String) {
        self.buttonTitle = leftString
        button.setTitle(leftString)
        button.setBackgroundColor(defaultColor)
    }
    
    @IBAction func leftButtonPressed() {
        if let delegate = self.delegate, leftString = self.buttonTitle {
            delegate.buttonPressedWithTitle(leftString);
        }
        button.setBackgroundColor(highlightedColor)
        let delayTime = dispatch_time(DISPATCH_TIME_NOW, Int64(0.1 * Double(NSEC_PER_SEC)))
        dispatch_after(delayTime, dispatch_get_main_queue()) { () -> Void in
            self.button.setBackgroundColor(self.defaultColor)
        }
    }

}
