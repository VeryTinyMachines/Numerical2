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
    public static let sounds = "sounds"
}

class NumericalHelper {
    
    class func aboutMenuFont() -> UIFont {
        return UIFont(name: "AvenirNext-Regular", size: 14.0)!
    }
    
    class func isSettingEnabled(string: String) -> Bool {
        
        if let obj = UserDefaults.standard.object(forKey: string) as? NSNumber {
            return obj.boolValue
        }
        
        return defaultTrueForSetting(string: string)
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
    
    class func isDevicePad() -> Bool {
        return UIScreen.main.traitCollection.userInterfaceIdiom == .pad
    }
    
    class func shouldSettingsScreenBeModal() -> Bool {
        return isDevicePad()
    }
    
    class func currentDeviceInfo(includeBuildNumber: Bool) -> String {
        if let info = Bundle.main.infoDictionary {
            if let version = info["CFBundleShortVersionString"] as? String, let buildNumber = info["CFBundleVersion"] as? String {
                if includeBuildNumber {
                    return "v\(version) (\(buildNumber))"
                } else {
                    return "v\(version)"
                }
            }
        }
        return ""
    }
}

extension UIView {
    
    /// Adds constraints to this `UIView` instances `superview` object to make sure this always has the same size as the superview.
    /// Please note that this has no effect if its `superview` is `nil` – add this `UIView` instance as a subview before calling this.
    func bindFrameToSuperviewBounds() {
        guard let superview = self.superview else {
            print("Error! `superview` was nil – call `addSubview(view: UIView)` before calling `bindFrameToSuperviewBounds()` to fix this.")
            return
        }
        
        self.translatesAutoresizingMaskIntoConstraints = false
        superview.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-0-[subview]-0-|", options: .directionLeadingToTrailing, metrics: nil, views: ["subview": self]))
        superview.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-0-[subview]-0-|", options: .directionLeadingToTrailing, metrics: nil, views: ["subview": self]))
    }
}
