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

open class CalculatorBrain {
    
    open var currentQuestion: String?
    open var currentAnswer: String?
    open var delegate:CalculatorBrainDelete?
    
    static let sharedBrain: CalculatorBrain = {
        let instance = CalculatorBrain()
        return instance
    }()
    
    func currentTimeMillis() -> Int64 {
        let nowDouble = Date().timeIntervalSince1970
        return Int64(nowDouble*1000)
    }
    
    open func solveString(_ string: String) -> String {
        let answer = Evaluator.solveString(string)
        
        if let answerString = answer.answer {
            return answerString
        } else {
            return ""
        }
    }
    
    open func solveStringSyncQueue(_ string: String, completion: ((_ answer: AnswerBundle) -> Void)? ) {
        
        let result = Evaluator.solveString(string)
        
        if let completionBlock = completion {
            completionBlock(result)
        }
    }
    
    open func solveStringAsyncQueue(_ string: String, completion: ((_ answer: AnswerBundle) -> Void)? ) {
        
        currentQuestion = string
        
        let qualityOfServiceClass = DispatchQoS.QoSClass.background
        let backgroundQueue = DispatchQueue.global(qos: qualityOfServiceClass)
        
        let startTime = self.currentTimeMillis()
        
        backgroundQueue.async(execute: {
            
            //print("start time: \(startTime)", terminator: "\n")
            
            if self.currentQuestion == string {
                
                // This is still the current question
                let result = Evaluator.solveString(string)
                self.currentAnswer = result.answer
                
                let readyTime = self.currentTimeMillis()
                let readyTimeDelta = readyTime - startTime
                
                //print("readyTimeDelta: \(readyTimeDelta)")
                
                if let completionBlock = completion {
                    
                    DispatchQueue.main.async(execute: { () -> Void in
                        let endTime = self.currentTimeMillis()
                        let endTimeDelta = endTime - startTime
                        
                        //print("endTimeDelta: \(endTimeDelta)")
                        
                        completionBlock(result)
                    })
                }
            }
        })
    }
}
