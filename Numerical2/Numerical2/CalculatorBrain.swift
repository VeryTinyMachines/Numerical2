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
    
    class var sharedBrain: CalculatorBrain {
        struct Static {
            static var onceToken: dispatch_once_t = 0
            static var instance: CalculatorBrain? = nil
        }
        dispatch_once(&Static.onceToken) {
            Static.instance = CalculatorBrain()
        }
        return Static.instance!
    }
    
    func currentTimeMillis() -> Int64{
        let nowDouble = NSDate().timeIntervalSince1970
        return Int64(nowDouble*1000)
    }
    
    public func solveStringInQueue(string: String, completion: ((answer: String) -> Void)? ) {
        
        currentQuestion = string
        
        let qualityOfServiceClass = QOS_CLASS_BACKGROUND
        let backgroundQueue = dispatch_get_global_queue(qualityOfServiceClass, 0)
        
        let startTime = self.currentTimeMillis()
        
        dispatch_async(backgroundQueue, {
            
            print("start time: \(startTime)", appendNewline: true)
            
            if self.currentQuestion == string {
                
                // This is still the current question
                let result = Evaluator.solveString(string)
                self.currentAnswer = result
                
                let readyTime = self.currentTimeMillis()
                let readyTimeDelta = readyTime - startTime
                
                print("readyTimeDelta: \(readyTimeDelta)")
                
                if let completionBlock = completion, theResult = result {
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        let endTime = self.currentTimeMillis()
                        let endTimeDelta = endTime - startTime
                        
                        print("endTimeDelta: \(endTimeDelta)")
                        
                        completionBlock(answer: theResult)
                    })
                }
            }

        })

    }
}