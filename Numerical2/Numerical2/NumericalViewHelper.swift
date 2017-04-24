//
//  NumericalViewHelper.swift
//  Numerical2
//
//  Created by Andrew Clark on 28/12/2016.
//  Copyright © 2016 Very Tiny Machines. All rights reserved.
//

import UIKit

class NumericalViewHelper {
    class func isDevicePad() -> Bool {
        if UIScreen.main.traitCollection.userInterfaceIdiom == .pad {
            if var size = UIApplication.shared.delegate?.window??.bounds {
                
                if size.width < 400 {
                    // This device has a width < 760 but is an iPad
                    // This is a split screen view and should therefore take on the size of a phone deivce
                    return false
                }
            }
        }
        
        return UIScreen.main.traitCollection.userInterfaceIdiom == .pad
    }
    
    class func shouldSettingsScreenBeModal() -> Bool {
        return isDevicePad()
    }
    
    class func sideHistoryEnabled() -> Bool {
        if NumericalHelper.isSettingEnabled(string: NumericalHelperSetting.preferHistoryBehind) {
            return false
        } else {
            return true
        }
    }
    
    class func deviceIsWide() -> Bool {
        // This return true if this device is an iPad and the available screen real estate is iPad "sized"
        return isDevicePad()
    }
    
    class func historyKeypadNeeded() -> Bool {
        // A keypad history is needed IF they are on iPhone or an iPhone sized device and the side history is enabled.
        
        if sideHistoryEnabled() && deviceIsWide() == false {
            return true
        }
        
        return false
    }
    
    class func historyBehindKeypadNeeded() -> Bool {
        // This history should be behind the keypad if sideHistoryEnabled is false
        
        if sideHistoryEnabled() == false {
            return true
        }
        
        return false
    }
    
    class func historyBesideKeypadNeeded() -> Bool {
        // A side keyboard is required ONLY if the side history is enabled and the device is wide, otherwise it should just be a keypad.
        if sideHistoryEnabled() {
            if deviceIsWide() {
                return true
            }
            
            // If there is no scientific keyboard, and history is meant to be on the side, and we're on iPhone in landscape mode, then we should show the
        }
        
        return false
    }
    
    class func keypadIsDraggable() -> Bool {
        // The keyboard is draggable anytime the sideHistoryEnabled is false
        if sideHistoryEnabled() == false {
            return true
        }
        
        return false
    }
    
    class func scientificKeypadNeeded() -> Bool {
        if NumericalHelper.isSettingEnabled(string: NumericalHelperSetting.showScientific) {
            return true
        } else {
            return false
        }
    }
}
