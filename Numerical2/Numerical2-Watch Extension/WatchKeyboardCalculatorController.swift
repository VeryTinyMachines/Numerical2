//
//  WatchKeyboardCalculatorController.swift
//  Numerical2
//
//  Created by Kevin Enax on 10/8/15.
//  Copyright © 2015 Very Tiny Machines. All rights reserved.
//

import WatchKit
import Foundation
import WatchConnectivity

protocol WatchButtonDelegate {
    func buttonPressedWithTitle(title:String)
}

class WatchKeyboardCalculatorController: WKInterfaceController, WatchButtonDelegate {
    @IBOutlet var resultLabel: WKInterfaceLabel!
    var resultString : String = ""
    
    @IBOutlet var equationLabel: WKInterfaceLabel!
    var equationString : String = ""
    
    @IBOutlet var buttonTable: WKInterfaceTable!
    
    let OneButtonRowIdentifier = "OneButtonRow"
    let ThreeButtonRowIdentifier = "ThreeButtonRow"
    

    
    override func awakeWithContext(context: AnyObject?) {
        super.awakeWithContext(context)
        
        configureTable()
    }
    
    func buttonPressedWithTitle(title: String) {
        if title == "C" {
            self.persistEquation()
            self.storeEquationString("0")
            self.storeResultString("0")
        } else {
            if equationString == "0" {
                equationString = title
            } else {
                equationString += title
            }
            equationLabel.setText(equationString)
            CalculatorBrain().solveStringAsyncQueue(equationString, completion: { (answer:AnswerBundle) -> Void in
                if let answerString = answer.answer {
                    self.storeResultString(answerString)
                }
            })
        }
    }
    
    
    func persistEquation() {
        if equationString != "0" {
            WatchEquation(equationString: self.equationString, answerString: self.resultString, deviceIDString: WKInterfaceDevice.currentDevice().model).persist()
        }
    }
    
    func storeEquationString(equationString:String) {
        self.equationString = equationString
        self.equationLabel.setText(self.equationString)
    }
    
    func storeResultString(resultString:String) {
        self.resultString = resultString
        self.resultLabel.setText(self.resultString)
    }
    
    let buttons = ["7", "8", "9",
        "4", "5", "6",
        "1", "2", "3",
        "0", ".", "C",
        "+", "÷", "x",
        "-", "sin", "cos",
        "tan", "ln", "log",
        "!", "π", "e",
        "^", "(", ")"]
    
    func configureTable() {
        buttonTable.insertRowsAtIndexes(NSIndexSet(index: 0), withRowType: OneButtonRowIdentifier)
        let lastRow : WatchCalculatorOneButtonRow = buttonTable.rowControllerAtIndex(0) as! WatchCalculatorOneButtonRow
        lastRow.configureButtons("√")
        lastRow.delegate = self
        
        buttonTable.insertRowsAtIndexes(NSIndexSet(indexesInRange: NSMakeRange(0, 9)), withRowType: ThreeButtonRowIdentifier)
        
        for row in 0...8 {
            let cell : WatchCalculatorThreeButtonRow = buttonTable.rowControllerAtIndex(row) as! WatchCalculatorThreeButtonRow
            
            cell.configureButtons(buttons[row * 3], middleString:buttons[row * 3 + 1] , rightString: buttons[row * 3 + 2])
            cell.delegate = self
        }
        
    }

}
