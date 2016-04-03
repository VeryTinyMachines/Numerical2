//
//  CalculatorBrain.swift
//  Numerical2
//
//  Created by Andrew J Clark on 7/07/2015.
//  Copyright © 2015 Andrew J Clark. All rights reserved.
//

import Foundation

public protocol CalculatorBrainDelete {
    
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
    
    public func solveString(string: String) -> String {
        let answer = Evaluator.solveString(string)
        
        if let answerString = answer.answer {
            return answerString
        } else {
            return ""
        }
    }
    
    public func solveStringSyncQueue(string: String, completion: ((answer: AnswerBundle) -> Void)? ) {
        
        let result = Evaluator.solveString(string)
        
        if let completionBlock = completion {
            completionBlock(answer: result)
        }
    }
    
    public func solveStringAsyncQueue(string: String, completion: ((answer: AnswerBundle) -> Void)? ) {
        
        currentQuestion = string
        
        let qualityOfServiceClass = QOS_CLASS_BACKGROUND
        let backgroundQueue = dispatch_get_global_queue(qualityOfServiceClass, 0)
        
        let startTime = self.currentTimeMillis()
        
        dispatch_async(backgroundQueue, {
            
            print("start time: \(startTime)", terminator: "\n")
            
            if self.currentQuestion == string {
                
                // This is still the current question
                let result = Evaluator.solveString(string)
                self.currentAnswer = result.answer
                
                let readyTime = self.currentTimeMillis()
                let readyTimeDelta = readyTime - startTime
                
                print("readyTimeDelta: \(readyTimeDelta)")
                
                if let completionBlock = completion {
                    
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        let endTime = self.currentTimeMillis()
                        let endTimeDelta = endTime - startTime
                        
                        print("endTimeDelta: \(endTimeDelta)")
                        
                        completionBlock(answer: result)
                    })
                }
            }
        })
    }
}