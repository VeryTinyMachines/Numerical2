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
            return WatchCommunicator.session.receivedApplicationContext["latestEquation"] as? [String:String]
        }
        set {
            var currentContext = WatchCommunicator.session.receivedApplicationContext
            currentContext["latestEquation"] = newValue
            do {
                try session.updateApplicationContext(currentContext)
            } catch let error {print(error)}
        }
    }
    
    static func setCurrentTint(tintColor:UIColor) {
        let colorData =  NSKeyedArchiver.archivedDataWithRootObject(tintColor)
        var currentContext = session.receivedApplicationContext
        currentContext["colorData"] = colorData
        do{
            try session.updateApplicationContext(currentContext)
        } catch let error {print(error)}
        
    }
    
    @objc internal func session(session: WCSession, didReceiveUserInfo userInfo: [String : AnyObject]) {
//        let equationDict = userInfo as! [String:String]
//        let newWatchEquation = WatchEquation.fromDictionary(equationDict)
    }
    
    @objc internal func session(session: WCSession, didReceiveApplicationContext applicationContext: [String : AnyObject]) {
//        let equationDict = applicationContext["latestEquation"] as! [String:String]
//        let newWatchEquation = WatchEquation.fromDictionary(equationDict)
        
    }
    
}