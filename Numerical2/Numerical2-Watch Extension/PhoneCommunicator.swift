//
//  PhoneCommunicator.swift
//  Numerical2
//
//  Created by Kevin Enax on 10/17/15.
//  Copyright © 2015 Very Tiny Machines. All rights reserved.
//

import WatchConnectivity
import UIKit

protocol PhoneCommunicatorDelegate {
    func contextDidChangeWithNewLatestEquation(newEquation:[String:String]?, newTintColor:UIColor)
}

class PhoneCommunicator : NSObject, WCSessionDelegate {
    
    private override init(){
        super.init()
    }
    
    func setup() {
        PhoneCommunicator.session.delegate = self
        PhoneCommunicator.session.activateSession()
    }
    
    static let sharedCommunicator = PhoneCommunicator()
    
    private static let session = WCSession.defaultSession()
    
    static var delegate : PhoneCommunicatorDelegate? = nil
    
    static var latestEquationDict : [String : String]?  {
        get {
        var dictionaryToUse = session.applicationContext
            if let latestSentTimestamp = session.applicationContext["timestamp"] as! NSTimeInterval? {
                if let latestReceivedTimestamp = session.receivedApplicationContext["timestamp"] as! NSTimeInterval? {
                    dictionaryToUse = latestReceivedTimestamp > latestSentTimestamp ? session.receivedApplicationContext : session.applicationContext
        
                }
        
            } else if session.receivedApplicationContext["timestamp"] != nil {
                dictionaryToUse = session.receivedApplicationContext
            }
        
            return dictionaryToUse["latestEquation"] as? [String:String]
        }
        set {
            var currentContext = session.receivedApplicationContext
            currentContext["latestEquation"] = newValue
            currentContext["timestamp"] = NSDate().timeIntervalSince1970
            do {
                try session.updateApplicationContext(currentContext)
            } catch let error {
                print(error)
            }
        }
    }
    
    static func sendEquationDictToPhone(equationDict:[String:String]) {
        session.transferUserInfo(equationDict)
    }
    
    static func currentTint() -> UIColor {
        if let colorData = session.receivedApplicationContext["colorData"] as! NSData? {
            return NSKeyedUnarchiver.unarchiveObjectWithData(colorData) as! UIColor
        }
        return UIColor.purpleColor()
    }
    
    
    @objc internal func session(session: WCSession, didReceiveApplicationContext applicationContext: [String : AnyObject]) {
        if let delegate = PhoneCommunicator.delegate{
            var colorToSend = PhoneCommunicator.currentTint()
            var equationDict : [String:String]? = nil
            if let realDict = applicationContext["latestEquation"] as! [String:String]? {
                equationDict = realDict
            }
            
            if let colorData = applicationContext["colorData"] as! NSData? {
                colorToSend =  NSKeyedUnarchiver.unarchiveObjectWithData(colorData) as! UIColor
            }
            delegate.contextDidChangeWithNewLatestEquation(equationDict, newTintColor: colorToSend)
        }
    }
    
}