//
//  WatchEquation.swift
//  Numerical2
//
//  Created by Kevin Enax on 10/15/15.
//  Copyright © 2015 Very Tiny Machines. All rights reserved.
//

import Foundation

struct WatchEquation {
    let equationString : String
    let answerString:String
    let deviceIDString:String
    let dateString:String
    init(equationString:String, answerString:String, deviceIDString:String) {
        self.answerString = answerString
        self.deviceIDString = deviceIDString
        self.equationString = equationString
        self.dateString = "\(NSDate().timeIntervalSince1970)"
    }
    init(equationString:String, answerString:String, deviceIDString:String, dateString:String) {
        self.answerString = answerString
        self.deviceIDString = deviceIDString
        self.equationString = equationString
        self.dateString = dateString
    }
    
    func toDictionary() -> Dictionary<String, String> {
        var dict = Dictionary<String, String>()
        dict["equationString"] = equationString
        dict["answerString"] = answerString
        dict["dateString"] = dateString
        dict["deviceIDString"] = deviceIDString
        return dict
    }
    
    func persist() {
        PhoneCommunicator.sendEquationDictToPhone(self.toDictionary())
        PhoneCommunicator.latestEquationDict = self.toDictionary()
    }
    
     static private func yankWatchEquationAtPath(equationPath:String) -> WatchEquation? {
        do {
            if let data = NSFileManager.defaultManager().contentsAtPath(equationPath){
                try NSFileManager.defaultManager().removeItemAtPath(equationPath)
                let json = try NSJSONSerialization.JSONObjectWithData(data, options: .AllowFragments) as! Dictionary<String, String>
                if let equation = WatchEquation.fromDictionary(json) {
                    return equation
                }
            }
        } catch _ {}
        return nil
    }

    static func fromDictionary(json:Dictionary<String, String>) -> WatchEquation? {
        if let equationString = json["equationString"], answerString = json["answerString"], deviceIDString = json["deviceIDString"], dateString = json["dateString"] {
            return WatchEquation(equationString: equationString, answerString: answerString, deviceIDString: deviceIDString, dateString: dateString)
        }
        return nil
    }
}