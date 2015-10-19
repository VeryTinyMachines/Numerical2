//
//  WatchCommunicator.swift
//  Numerical2
//
//  Created by Kevin Enax on 10/17/15.
//  Copyright © 2015 Very Tiny Machines. All rights reserved.
//

import Foundation
import WatchConnectivity

//protocol WatchCommunicatorDelegate {
//    
//}

class WatchCommunicator : NSObject, WCSessionDelegate {
    
    private override init(){
        super.init()
    }
    
    func setup() {
        if WCSession.isSupported() {
            WatchCommunicator.session.delegate = self
            WatchCommunicator.session.activateSession()
        }
    }
    
    static let sharedCommunicator = WatchCommunicator()
    
    private static let session = WCSession.defaultSession()
    
//    static var delegate : WatchCommunicatorDelegate? = nil
    
    static var latestEquationDict : [String : String]?  {
        get {
        var dictionaryToUse = latestContext()
        
        return dictionaryToUse[LatestEquationKey] as? [String:String]
        }
        set {
            var currentContext = latestContext()
            currentContext[LatestEquationKey] = newValue
            currentContext[TimestampKey] = NSDate().timeIntervalSince1970
            do {
                try session.updateApplicationContext(currentContext)
            } catch let error {
                print(error)
            }
        }
    }
    
    static func setCurrentTint(tintColor:UIColor) {
        let colorData =  NSKeyedArchiver.archivedDataWithRootObject(tintColor)
        var currentContext = latestContext()
        currentContext[ColorDataKey] = colorData
        currentContext[TimestampKey] = NSDate().timeIntervalSince1970
        do{
            try session.updateApplicationContext(currentContext)
        } catch let error {print(error)}
        
    }
    
    static private func latestContext() -> [String:AnyObject] {
        var dictionaryToUse = session.applicationContext
        if let latestSentTimestamp = session.applicationContext[TimestampKey] as! NSTimeInterval? {
            if let latestReceivedTimestamp = session.receivedApplicationContext[TimestampKey] as! NSTimeInterval? {
                dictionaryToUse = latestReceivedTimestamp > latestSentTimestamp ? session.receivedApplicationContext : session.applicationContext
                
            }
            
        } else if session.receivedApplicationContext[TimestampKey] != nil {
            dictionaryToUse = session.receivedApplicationContext
        }
        return dictionaryToUse
    }
    
    @objc internal func session(session: WCSession, didReceiveUserInfo userInfo: [String : AnyObject]) {
        print("phone didReceiveUserInfo")
        
        if let dict = userInfo as? [String:String] {
            print(dict)
            
            if let equation = dict[LatestEquationKey] {
                print("equation: \(equation)")
                
                if let newEquation = EquationStore.sharedStore.newEquation() {
                    print("newEquation: \(newEquation)")
                    newEquation.question = equation
                    newEquation.creationDate = NSDate()
                    let answerBundle = Evaluator.solveString(equation)
                    
                    if let answer = answerBundle.answer {
                        print("answer: \(answer)")
                        newEquation.answer = answer
                    }
                    
                    EquationStore.sharedStore.save()
                }
            }
        }

    }
    
    @objc internal func session(session: WCSession, didReceiveApplicationContext applicationContext: [String : AnyObject]) {
        print("phone didReceiveApplicationContext")
        let equationDict = applicationContext[LatestEquationKey] as! [String:String]
        let newWatchEquation = WatchEquation.fromDictionary(equationDict)
        print(newWatchEquation)
        
    }
    
}
