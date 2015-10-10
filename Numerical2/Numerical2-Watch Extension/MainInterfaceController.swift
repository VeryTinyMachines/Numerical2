//
//  InterfaceController.swift
//  Numerical2-Watch Extension
//
//  Created by Kevin Enax on 10/8/15.
//  Copyright © 2015 Very Tiny Machines. All rights reserved.
//

import WatchKit
import Foundation


class MainInterfaceController: WKInterfaceController {

    @IBOutlet var mainLabel: WKInterfaceLabel!
    @IBOutlet var subLabel: WKInterfaceLabel!
    
    @IBOutlet var topLabelGroup: WKInterfaceGroup!
    @IBOutlet var buttonContainer: WKInterfaceGroup!
    

    override func willActivate() {
        super.willActivate()
        let device = WKInterfaceDevice.currentDevice()
        if device.screenBounds.width < 156.0 {
            topLabelGroup.setContentInset(UIEdgeInsetsMake(0, 8, 0, 5))
            buttonContainer.setContentInset(UIEdgeInsetsMake(0, 0, 0, 0))
        }
        let attrNumericalString = NSAttributedString(string: "Numerical", attributes: [NSFontAttributeName : UIFont.systemFontOfSize(24)])
        mainLabel.setAttributedText(attrNumericalString)
        subLabel.setText("A calculator with\nno equal")
    }

    
    @IBAction func speechButtonPressed() {
        presentTextInputControllerWithSuggestions(nil, allowedInputMode: .Plain) { (results) -> Void in
            if let strings : [String] = results as? [String] where results!.count > 0 {
                self.mainLabel.setText(strings.reduce("") { wholeString, partial in return wholeString! + partial })
            }
        }
    }
}
