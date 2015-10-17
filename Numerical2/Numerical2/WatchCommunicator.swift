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
        return WatchCommunicator.session.applicationContext["latestEquation"] as? [String:String]
        }
        set {
            var currentContext = WatchCommunicator.session.applicationContext
            currentContext["latestEquation"] = newValue
            do {
                try WatchCommunicator.session.updateApplicationContext(currentContext)
            } catch _ {}
        }
    }
    
    static func setCurrentTint(tintColor:UIColor) {
        let colorData =  NSKeyedArchiver.archivedDataWithRootObject(tintColor)
        var currentContext = session.applicationContext
        currentContext["colorData"] = colorData
        do{
            try session.updateApplicationContext(currentContext)
        } catch _ {}
        
    }
    
    @objc private static func session(session: WCSession, didReceiveUserInfo userInfo: [String : AnyObject]) {
        //        let equationDict = userInfo as! [String:String]
        //        let newWatchEquation = WatchEquation.fromDictionary(equationDict)
    }
    
    @objc private static func session(session: WCSession, didReceiveApplicationContext applicationContext: [String : AnyObject]) {
        //        if let equationDict = self.latestEquationDict {
        //            let newWatchEquation = WatchEquation.fromDictionary(equationDict)
        //        }
        //    }
    }
}
