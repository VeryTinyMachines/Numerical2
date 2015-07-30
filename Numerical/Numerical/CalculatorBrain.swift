//
//  CalculatorBrain.swift
//  Numerical2
//
//  Created by Andrew J Clark on 7/07/2015.
//  Copyright © 2015 Andrew J Clark. All rights reserved.
//

import Foundation

public protocol CalculatorBrainDelete {
    func answerProcessed(answer: String?)
}

public class CalculatorBrain {
    
    public var currentQuestion: String?
    public var currentAnswer: String?
    public var delegate:CalculatorBrainDelete?
    
    public func solveStringInQueue(string: String) {
        
        currentQuestion = string
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), { () -> Void in
            if self.currentQuestion == string {
                
                // This is still the current question
                let result = Evaluator.solveString(string)
                self.currentAnswer = result
                
                if let theDelegate = self.delegate {
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        theDelegate.answerProcessed(result)
                    })
                }
            }
        })
    }
    
    
    public func possibleAnswersFromString(answerString: String) -> Array<String> {
        var answersArray:Array<String> = []
        
        if Glossary.isStringFractionNumber(answerString) {
            // This is a fraction
            answersArray.append(answerString)
            
            // Let's try and reduce it and add it if it's different
            if let reducedAnswer = Evaluator.reduceFraction(answerString) {
                if answerString != reducedAnswer {
                    answersArray.append(reducedAnswer)
                }
            }
            
            // Let's also express it as a decimal
            if let decimalAnswer = Evaluator.decimalFromFraction(answerString) {
                answersArray.append(decimalAnswer)
            }
        } else {
            answersArray.append(answerString)
        }
        
        return answersArray
    }
}