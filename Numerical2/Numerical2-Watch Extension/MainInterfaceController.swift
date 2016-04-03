//
//  InterfaceController.swift
//  Numerical2-Watch Extension
//
//  Created by Kevin Enax on 10/8/15.
//  Copyright © 2015 Very Tiny Machines. All rights reserved.
//

import WatchKit
import Foundation




class MainInterfaceController: WKInterfaceController, PhoneCommunicatorDelegate, WatchKeyboardDelegate {

    @IBOutlet var resultLabel: WKInterfaceLabel!
    @IBOutlet var equationLabel: WKInterfaceLabel!
    var equationText : String = ""
    var answerText : String = ""
    
    var firstLaunch = true
    
    @IBOutlet var topLabelGroup: WKInterfaceGroup!
    @IBOutlet var buttonContainer: WKInterfaceGroup!
    
    @IBOutlet var coloredButtonContainer: WKInterfaceGroup!
    
    override func willActivate() {
        super.willActivate()
        print("willActivate")
        let device = WKInterfaceDevice.currentDevice()
        if device.screenBounds.width < 156.0 {
            topLabelGroup.setContentInset(UIEdgeInsetsMake(0, 8, 0, 5))
            buttonContainer.setContentInset(UIEdgeInsetsMake(0, 0, 0, 0))
        }
        PhoneCommunicator.delegate = self
        
        if firstLaunch == true {
            setLabelStringsWithDictionary(PhoneCommunicator.latestEquationDict)
            firstLaunch = false
        }
        
        self.equationLabel.setText(equationText)
        self.resultLabel.setText(answerText)
        
     coloredButtonContainer.setBackgroundColor(PhoneCommunicator.currentTint())
        
    }
    
    func userEquationChanged(equation: String, answer: String) {
        
        print("equation: \(equation)")
        print("answer: \(answer)")
        
        equationText = equation
        answerText = answer
        
    }
    
    func userEnteredEquation(notification: NSNotification) {
        
    }
    
    func contextDidChangeWithNewLatestEquation(newEquation: [String : String]?, newTintColor: UIColor) {
        print("contextDidChangeWithNewLatestEquation")
        print("newEquation: \(newEquation)")
        
        setLabelStringsWithDictionary(newEquation)
        
        self.equationLabel.setText(equationText)
        self.resultLabel.setText(answerText)
        
        coloredButtonContainer.setBackgroundColor(newTintColor)
    }
    
    func setLabelStringsWithDictionary(optionalEquationDict:[String:String]?) {
        if let latestEquation = optionalEquationDict {
            print("latestEquation: \(latestEquation)")
            print(latestEquation[EquationStringKey])
            if let equation = latestEquation[EquationStringKey] {
//                equationLabel.setText(equation)
                equationText = equation
            }
            
            if let answer = latestEquation[AnswerStringKey] {
//                resultLabel.setText(answer)
                answerText = answer
            }
            
            
        } else {
//            let attrNumericalString = NSAttributedString(string: "Numerical", attributes: [NSFontAttributeName : UIFont.systemFontOfSize(24)])
//            resultLabel.setAttributedText(attrNumericalString)
//            equationLabel.setText("The calculator\nwithout equal")
        }
    }

    
    @IBAction func gridButtonPressed() {
        print("gridButtonPressed")
        self.presentControllerWithName("WatchKeyboard", context: self)
    }
    
    @IBAction func speechButtonPressed() {
        presentTextInputControllerWithSuggestions(nil, allowedInputMode: .Plain) { (results) -> Void in
            if let strings : [String] = results as? [String] where results!.count > 0 {
                self.equationText = strings.reduce("", combine: { (whole:String, partial:String) -> String in
                    print("returning whole + partial")
                    return whole + partial
                })
                print("setting equationLabel")
                self.equationLabel.setText(self.equationText)
                
                if let parsedString = NaturalLanguageParser.sharedInstance.translateString(self.equationText) {
                    print("parsedString: \(parsedString)")
                    
                    let cleanedString = Glossary.formattedStringForQuestion(parsedString)
                    
                    self.equationLabel.setText(cleanedString)
                    self.equationText = cleanedString
                    self.resultLabel.setText("...")
                    
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        
                        CalculatorBrain().solveStringSyncQueue(parsedString, completion: { (answer: AnswerBundle) -> Void in
                            if let answerString = answer.answer {
                                print("answer: \(answer)")
                                print("answer.answer: \(answer.answer)")
                                
                                let cleanedAnswer = Glossary.formattedStringForQuestion(answerString)
                                self.resultLabel.setText(cleanedAnswer)
                                
                                
                                let fullEquation = parsedString
                                
                                var equationDict = [String:String]()
                                
                                equationDict[LatestEquationKey] = fullEquation
                                equationDict[TimestampKey] = "\(NSDate().timeIntervalSince1970)"
                                
                                
                                PhoneCommunicator.sendEquationDictToPhone(equationDict)
                                
                            } else {
                                self.resultLabel.setText("Error")
                            }
                        })
                        
                    })
                    
                } else {
                    //maybe show error
                    print("an error occurred")
                }
            }
        }
    }
}
