//
//  InterfaceController.swift
//  Numerical2-Watch Extension
//
//  Created by Kevin Enax on 10/8/15.
//  Copyright © 2015 Very Tiny Machines. All rights reserved.
//

import WatchKit
import Foundation


class MainInterfaceController: WKInterfaceController, PhoneCommunicatorDelegate {

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
        PhoneCommunicator.delegate = self
        
        setLabelStringsWithDictionary(PhoneCommunicator.latestEquationDict)
        coloredButtonContainer.setBackgroundColor(PhoneCommunicator.currentTint())
    }
    
    func contextDidChangeWithNewLatestEquation(newEquation: [String : String]?, newTintColor: UIColor) {
            setLabelStringsWithDictionary(newEquation)
            coloredButtonContainer.setBackgroundColor(newTintColor)
    }
    
    func setLabelStringsWithDictionary(optionalEquationDict:[String:String]?) {
        if let latestEquation = optionalEquationDict {
            resultLabel.setText(latestEquation[AnswerStringKey])
            equationLabel.setText(latestEquation[EquationStringKey])
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
                if let parsedString = NaturalLanguageParser.sharedInstance.translateString(self.equationText){
                    CalculatorBrain().solveStringAsyncQueue(parsedString, completion: { (answer) -> Void in
                        if let answer : AnswerBundle = answer { self.resultLabel.setText(answer.answer) }
                    })
                } else {
                    //maybe show error
                }
            }
        }
    }
}
