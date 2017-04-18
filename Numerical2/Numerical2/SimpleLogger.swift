//
//  SimpleLogger.swift
//  Numerical2
//
//  Created by Andrew Clark on 15/04/2017.
//  Copyright © 2017 Very Tiny Machines. All rights reserved.
//

import UIKit

class SimpleLogger {
    var logArray = [String]()
    var loggingEnabled = false
    
    static let shared = SimpleLogger()
    fileprivate init() {
        loggingEnabled = NumericalHelper.isSettingEnabled(string: NumericalHelperSetting.logging)
    }
    
    func appendLog(string: String) {
        
        if loggingEnabled {
            var string = string
            
            string = "\(Date()) - \(string)"
            
            // First check to see if it's the same as the last item
            
            if var lastString = logArray.last {
                if lastString.replacingOccurrences(of: " |", with: "") == string {
                    lastString += " |"
                    logArray.removeLast()
                    logArray.append(lastString)
                    return
                }
            }
            
            logArray.append(string)
        }
    }
    
    class func appendLog(string: String) {
        SimpleLogger.shared.appendLog(string: string)
    }
    
    func logAsData() -> Data? {
        
        let log = SimpleLogger.shared.logArray
        if log.count > 0 {
            let joinedString = log.joined(separator: "\n")
            
            if let data = (joinedString as NSString).data(using: String.Encoding.utf8.rawValue){
                //Attach File
                return data
            }
        }
        return nil
    }
}

