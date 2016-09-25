//
//  NumeicalHelper.swift
//  Numerical2
//
//  Created by Andrew J Clark on 24/09/2016.
//  Copyright © 2016 Very Tiny Machines. All rights reserved.
//

import UIKit


public struct NumericalHelperSetting {
    public static let iCloudHistorySync = "iCloudHistorySync"
    public static let autoBrackets = "autoBrackets"
}

class NumericalHelper {
    
    class func aboutMenuFont() -> UIFont {
        return UIFont(name: "AvenirNext-Regular", size: 14.0)!
    }
    
    class func isSettingEnabled(string: String) -> Bool {
        
        if let obj = UserDefaults.standard.object(forKey: NumericalHelperSetting.iCloudHistorySync) as? NSNumber {
            return obj.boolValue
        }
        
        return defaultTrueForSetting(string: NumericalHelperSetting.iCloudHistorySync)
    }
    
    class func defaultTrueForSetting(string: String) -> Bool {
        if string == NumericalHelperSetting.iCloudHistorySync || string == NumericalHelperSetting.autoBrackets {
            return true
        }
        
        return false
    }
    
    class func setSetting(string: String, enabled: Bool) {
        UserDefaults.standard.set(NSNumber(value: enabled), forKey: string)
        UserDefaults.standard.synchronize()
    }
    
    class func flipSetting(string: String) {
        setSetting(string: string, enabled: !isSettingEnabled(string: string))
    }
    
}
