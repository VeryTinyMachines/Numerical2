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
    let creationTimestampString:String
    init(equationString:String, answerString:String, deviceIDString:String) {
        self.answerString = answerString
        self.deviceIDString = deviceIDString
        self.equationString = equationString
        self.creationTimestampString = "\(NSDate().timeIntervalSince1970)"
    }
    init(equationString:String, answerString:String, deviceIDString:String, dateString:String) {
        self.answerString = answerString
        self.deviceIDString = deviceIDString
        self.equationString = equationString
        self.creationTimestampString = dateString
    }
    
    func toDictionary() -> Dictionary<String, String> {
        var dict = Dictionary<String, String>()
        dict[EquationStringKey] = equationString
        dict[AnswerStringKey] = answerString
        dict[TimestampKey] = creationTimestampString
        dict[DeviceIdStringKey] = deviceIDString
        return dict
    }
    
    #if os(watchOS)
    func persist() {
        PhoneCommunicator.sendEquationDictToPhone(self.toDictionary())
        PhoneCommunicator.latestEquationDict = self.toDictionary()
    }
    #endif

    static func fromDictionary(dictionary:[String:String]) -> WatchEquation? {
        if let equationString = dictionary[EquationStringKey], dateString = dictionary[TimestampKey] {
            return WatchEquation(equationString: equationString, answerString: "", deviceIDString: "", dateString: dateString)
        }
        return nil
    }
}