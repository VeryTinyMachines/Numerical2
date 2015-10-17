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

    @IBOutlet var resultLabel: WKInterfaceLabel!
    @IBOutlet var equationLabel: WKInterfaceLabel!
    var equationText : String = ""
    
    @IBOutlet var topLabelGroup: WKInterfaceGroup!
    @IBOutlet var buttonContainer: WKInterfaceGroup!
    
    @IBOutlet var coloredButtonContainer: WKInterfaceGroup!

    override func willActivate() {
        super.willActivate()
        let device = WKInterfaceDevice.currentDevice()
        if device.screenBounds.width < 156.0 {
            topLabelGroup.setContentInset(UIEdgeInsetsMake(0, 8, 0, 5))
            buttonContainer.setContentInset(UIEdgeInsetsMake(0, 0, 0, 0))
        }
        
        if let latestEquation : String = SinkableUserDefaults.standardUserDefaults.objectForKey("latestWatchEquation") as? String, latestAnswer : String = SinkableUserDefaults.standardUserDefaults.objectForKey("latestWatchResult") as? String {
            resultLabel.setText(latestAnswer)
            equationLabel.setText(latestEquation)
        } else {
            let attrNumericalString = NSAttributedString(string: "Numerical", attributes: [NSFontAttributeName : UIFont.systemFontOfSize(24)])
            resultLabel.setAttributedText(attrNumericalString)
            equationLabel.setText("A calculator with\nno equal")
        }
    }

    
    @IBAction func speechButtonPressed() {
        presentTextInputControllerWithSuggestions(nil, allowedInputMode: .Plain) { (results) -> Void in
            if let strings : [String] = results as? [String] where results!.count > 0 {
                self.equationText = strings.reduce("", combine: { (whole:String, partial:String) -> String in
                    return whole + partial
                })
                self.equationLabel.setText(self.equationText)
                CalculatorBrain().solveStringAsyncQueue(self.equationText, completion: { (answer) -> Void in
                    if let answer : AnswerBundle = answer { self.resultLabel.setText(answer.answer) }
                })
            }
        }
    }
}
