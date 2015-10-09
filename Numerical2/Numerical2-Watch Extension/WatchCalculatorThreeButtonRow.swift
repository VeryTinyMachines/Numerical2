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
    
    var delegate : WatchButtonDelegate?
    
    func configureButtons(leftString:String, middleString:String, rightString:String) {
        self.leftString = leftString
        leftButton.setTitle(leftString)
        
        self.middleString = middleString
        middleButton.setTitle(middleString)
        
        self.rightString = rightString
        rightButton.setTitle(rightString)
    }
    
    @IBAction func leftButtonPressed() {
        if let delegate = self.delegate, leftString = self.leftString {
            delegate.buttonPressedWithTitle(leftString);
        }
    }
    
    @IBAction func middleButtonPressed() {
        if let delegate = self.delegate, middleString = self.middleString {
            delegate.buttonPressedWithTitle(middleString);
        }
    }
    
    @IBAction func rightButtonPressed() {
        if let delegate = self.delegate, rightString = self.rightString {
            delegate.buttonPressedWithTitle(rightString);
        }
    }
}
