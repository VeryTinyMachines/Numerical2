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

    
    var delegate : WatchButtonDelegate?
    
    func configureButtons(leftString:String) {
        self.buttonTitle = leftString
        button.setTitle(leftString)
    
    }
    
    @IBAction func leftButtonPressed() {
        if let delegate = self.delegate, leftString = self.buttonTitle {
            delegate.buttonPressedWithTitle(leftString);
        }
    }

}
