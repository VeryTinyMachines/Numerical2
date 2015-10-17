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
    
    func toJSON() -> Dictionary<String, String> {
        var dict = Dictionary<String, String>()
        dict["equationString"] = equationString
        dict["answerString"] = answerString
        dict["dateString"] = dateString
        dict["deviceIDString"] = deviceIDString
        return dict
    }
    
    func persist() {
        let fileURL = NSFileManager.defaultManager().containerURLForSecurityApplicationGroupIdentifier(AppGroupId)?.URLByAppendingPathComponent(dateString + ".json")
        if let os = NSOutputStream(toFileAtPath: (fileURL?.absoluteString)!, append: true) {
            os.open()
            NSJSONSerialization.writeJSONObject(self.toJSON(), toStream: os, options: .PrettyPrinted, error: nil)
            os.close()
        }
        SinkableUserDefaults.standardUserDefaults.setObject(equationString, forKey: "latestWatchEquation")
        SinkableUserDefaults.standardUserDefaults.setObject(answerString, forKey: "latestWatchResult")
    }
    
    static func getWatchEquationsAndPurgeCache() -> [WatchEquation]? {
        if let equationPaths = allEquationPaths() {
            return equationPaths.flatMap(yankWatchEquationAtPath)
        }
        return nil
    }
    
     static private func yankWatchEquationAtPath(equationPath:String) -> WatchEquation? {
        do {
            if let data = NSFileManager.defaultManager().contentsAtPath(equationPath){
                try NSFileManager.defaultManager().removeItemAtPath(equationPath)
                let json = try NSJSONSerialization.JSONObjectWithData(data, options: .AllowFragments) as! Dictionary<String, String>
                if let equation = WatchEquation.fromJSON(json) {
                    return equation
                }
            }
        } catch _ {}
        return nil
    }
    
    static func equationStore() -> String? {
        if let sharedContainer = sharedContainer() {
            return sharedContainer.URLByAppendingPathComponent("equations", isDirectory: true).absoluteString
        }
        return nil
    }
    
    static private func allEquationPaths() -> [String]? {
        do {
            if let equationStore = equationStore() { return try NSFileManager.defaultManager().contentsOfDirectoryAtPath(equationStore) }
        } catch _ {}
        return nil
    }

    static func fromJSON(json:Dictionary<String, String>) -> WatchEquation? {
        if let equationString = json["equationString"], answerString = json["answerString"], deviceIDString = json["deviceIDString"], dateString = json["dateString"] {
            return WatchEquation(equationString: equationString, answerString: answerString, deviceIDString: deviceIDString, dateString: dateString)
        }
        return nil
    }
}