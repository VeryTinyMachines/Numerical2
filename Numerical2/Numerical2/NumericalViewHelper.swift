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
            if let size = UIApplication.shared.delegate?.window??.bounds {
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
}
