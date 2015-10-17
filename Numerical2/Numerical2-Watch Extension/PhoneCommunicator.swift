//
//  PhoneCommunicator.swift
//  Numerical2
//
//  Created by Kevin Enax on 10/17/15.
//  Copyright © 2015 Very Tiny Machines. All rights reserved.
//

import Foundation
import WatchConnectivity

protocol PhoneCommunicatorDelegate {
    func contextDidChangeWithNewLatestEquation(newEquation:[String:String]?, newTintColor:UIColor)
}

class PhoneCommunicator : NSObject, WCSessionDelegate {
    
    private override init(){
        super.init()
        PhoneCommunicator.session.activateSession()
        PhoneCommunicator.session.delegate = self
    }
    
    static let sharedCommunicator = PhoneCommunicator()
    
    private static let session = WCSession.defaultSession()
    
    static var delegate : PhoneCommunicatorDelegate? = nil
    
    static var latestEquationDict : [String : String]?  {
        get {
        return PhoneCommunicator.session.applicationContext["latestEquation"] as? [String:String]
        }
        set {
            var currentContext = PhoneCommunicator.session.applicationContext
            currentContext["latestEquation"] = newValue
            do {
                try PhoneCommunicator.session.updateApplicationContext(currentContext)
            } catch _ {}
        }
    }
    
    static func sendEquationDictToPhone(equationDict:[String:String]) {
        PhoneCommunicator.session.transferUserInfo(equationDict)
    }
    
    static func currentTint() -> UIColor {
        if let colorData = PhoneCommunicator.session.applicationContext["colorData"] as! NSData? {
            return NSKeyedUnarchiver.unarchiveObjectWithData(colorData) as! UIColor
        }
        return UIColor.purpleColor()
    }
    
    @objc private static func session(session: WCSession, didReceiveApplicationContext applicationContext: [String : AnyObject]) {
        if let delegate = self.delegate {
            delegate.contextDidChangeWithNewLatestEquation(self.latestEquationDict, newTintColor: self.currentTint())
        }
    }
    
}