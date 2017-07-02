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
    public static let themes = "themes"
    public static let logging = "logging"
    public static let migration = "migration"
    public static let preferdecimal = "preferdecimal"
    public static let preferRadians = "preferRadians"
    public static let showScientific = "showScientific"
    public static let preferHistoryBehind = "preferHistoryBehind"
    public static let decimalLength = "decimalLength"
    public static let boldFont = "boldFont"
}

public enum HistoryViewType {
    case behind
    case side
}

class NumericalHelper {
    
    class func aboutMenuFont() -> UIFont {
        return StyleFormatter.preferredFontForContext(FontDisplayContext.about)
    }
    
    class func isSettingEnabled(string: String) -> Bool {
        
        if string == NumericalHelperSetting.themes {
            return true // todo - yank out this junk
        }
        
        if let obj = UserDefaults.standard.object(forKey: string) as? NSNumber {
            return obj.boolValue
        }
        
        return defaultTrueForSetting(string: string)
    }
    
    class func integerForSetting(string: String) -> Int {
        
        let integer = UserDefaults.standard.integer(forKey: string)
        
        if string == NumericalHelperSetting.decimalLength && integer == 0 {
            // Not set, default to 14.
            return 10 // Default amount
        }
        
        return integer
    }
    
    class func setIntegerForSetting(string: String, integer: Int) {
        UserDefaults.standard.set(integer, forKey: string)
        UserDefaults.standard.synchronize()
    }
    
    class func defaultTrueForSetting(string: String) -> Bool {
        if string == NumericalHelperSetting.iCloudHistorySync || string == NumericalHelperSetting.autoBrackets || string == NumericalHelperSetting.preferRadians || string == NumericalHelperSetting.showScientific {
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
    
    class func postNotificationForEquationLogicChanged() {
        DispatchQueue.main.async {
            NotificationCenter.default.post(name: Notification.Name(rawValue: "EquationNotification.equationLogicChanged"), object: nil)
        }
    }
    
    
    class func currentVersionNumber() -> String {
        if let info = Bundle.main.infoDictionary {
            if let version = info["CFBundleShortVersionString"] as? String {
                return version
            }
        }
        return ""
    }
    
    class func convertIn(number1: Float, number2: Float, isSecondColor: Bool, isLightStyle: Bool) -> UIColor {
        
        //print("convertIn")
        //print("number1: \(number1)")
        //print("number2: \(number2)")
        
        var hue:Float = 0
        var bri:Float = 0
        var sat:Float = 0
        
        if isLightStyle {
            // Light style
            
            if isSecondColor {
//                //print("lightStyle isSecondColor")
                // The foreground color
//                //print("number2: \(number2)")
                
                let newNumber2 = 0.25 + (number2 * 0.5)
                
//                //print("newNumber2: \(newNumber2)")
                
                hue = number1
                sat = 1.0
                bri = newNumber2
                
//                //print("bri: \(bri)")
                
                // return (hue: number1, sat: 1.0, bri: newNumber2)
            } else {
                // The background color
                
                let newNumber2 = number2 * 0.1
                
                hue = number1
                sat = newNumber2
                bri = 1.0
                
                //return (hue: number1, sat: newNumber2, bri: 1.0)
            }
            
        } else {
            // Default style
            
            let maxSat:Float = 0.75
            let maxBright:Float = 0.9
            
            if number2 > 0.5 {
                // Brightness is maxed out, start desaturating now
                
                let newNumber2 = maxSat - ((number2 - 0.5) * 1.2)
                
                hue = number1
                sat = newNumber2
                bri = maxBright
                
                //return (hue: number1, sat: newNumber2, bri: 1.0)
                
            } else {
                hue = number1
                sat = maxSat
                bri = (number2 * 2 * maxBright)
                //return (hue: number1, sat: 1.0, bri: number2)
            }
        }
        
        let color = UIColor(hue: CGFloat(hue), saturation: CGFloat(sat), brightness: CGFloat(bri), alpha: 1.0)
        
        //print("hue: \(hue)")
        //print("sat: \(sat)")
        //print("bri: \(bri)")
        
        //print("color: \(color)")
        
        return color
    }
    
    class func convertOut(color: UIColor, isSecondColor: Bool, isLightStyle: Bool) -> (number1: Float, number2: Float) {
        //print("convertOut")
        var hue:CGFloat = 0.0
        var sat:CGFloat = 0.0
        var bri:CGFloat = 0.0
        
        color.getHue(&hue, saturation: &sat, brightness: &bri, alpha: nil)
        
        //print("hue: \(hue)")
        //print("sat: \(sat)")
        //print("bri: \(bri)")
        
        if isLightStyle {
            // Light style
            
            if isSecondColor {
                let number2 = (bri - 0.25) / 0.5
//                //print("number2: \(number2)")
                return (Float(hue), Float(number2))
                //let newNumber2 = 0.25 + (number2 * 0.5)
                //return (hue: number1, sat: 1.0, bri: newNumber2)
                
            } else {
                
                let number2 = sat / 0.1
                return (Float(hue), Float(number2))
            }
            
        } else {
            // Default style
            
            let maxSat:Float = 0.75
            let maxBright:Float = 0.9
            
            if bri >= CGFloat(maxBright) {
                // Brightness is maxed out, start desaturating now
                //print("Brightness is maxed out, start desaturating now")
                let number2 = (((sat - CGFloat(maxSat)) / 1.2) * -1) + 0.5
                //print("number2: \(number2)")
                return (Float(hue), Float(number2))
                
            } else {
                // Normal
                let number2 = bri / 2 / CGFloat(maxBright)
                return (Float(hue), Float(number2))
            }
        }
        
        //return (0.0, 0.0)
    }
}

extension UIView {
    
    /// Adds constraints to this `UIView` instances `superview` object to make sure this always has the same size as the superview.
    /// Please note that this has no effect if its `superview` is `nil` – add this `UIView` instance as a subview before calling this.
    func bindFrameToSuperviewBounds() {
        guard let superview = self.superview else {
            //print("Error! `superview` was nil – call `addSubview(view: UIView)` before calling `bindFrameToSuperviewBounds()` to fix this.")
            return
        }
        
        self.translatesAutoresizingMaskIntoConstraints = false
        superview.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-0-[subview]-0-|", options: .directionLeadingToTrailing, metrics: nil, views: ["subview": self]))
        superview.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-0-[subview]-0-|", options: .directionLeadingToTrailing, metrics: nil, views: ["subview": self]))
    }
}
