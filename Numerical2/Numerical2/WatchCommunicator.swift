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
            currentContext["timestamp"] = NSDate().timeIntervalSince1970
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
        currentContext["colorData"] = colorData
        currentContext["timestamp"] = NSDate().timeIntervalSince1970
        do{
            try session.updateApplicationContext(currentContext)
        } catch let error {print(error)}
        
    }
    
    static private func latestContext() -> [String:AnyObject] {
        var dictionaryToUse = session.applicationContext
        if let latestSentTimestamp = session.applicationContext["timestamp"] as! NSTimeInterval? {
            if let latestReceivedTimestamp = session.receivedApplicationContext["timestamp"] as! NSTimeInterval? {
                dictionaryToUse = latestReceivedTimestamp > latestSentTimestamp ? session.receivedApplicationContext : session.applicationContext
                
            }
            
        } else if session.receivedApplicationContext["timestamp"] != nil {
            dictionaryToUse = session.receivedApplicationContext
        }
        return dictionaryToUse
    }
    
    @objc internal func session(session: WCSession, didReceiveUserInfo userInfo: [String : AnyObject]) {
//        let equationDict = userInfo as! [String:String]
//        let newWatchEquation = WatchEquation.fromDictionary(equationDict)
    }
    
    @objc internal func session(session: WCSession, didReceiveApplicationContext applicationContext: [String : AnyObject]) {
//        let equationDict = applicationContext[LatestEquationKey] as! [String:String]
//        let newWatchEquation = WatchEquation.fromDictionary(equationDict)
        
    }
    
}
