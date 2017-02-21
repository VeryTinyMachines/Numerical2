//
//  StyleFormatter.swift
//  Numerical2
//
//  Created by Andrew J Clark on 29/09/2015.
//  Copyright © 2015 Very Tiny Machines. All rights reserved.
//

import UIKit

public enum FontDisplayContext {
    case question
    case questionFraction
    case answer
    case answerFraction
    case answerOr
}

public enum KeyStyle {
    case Available // A normal button
    case AvailablePremium // A usually premium button that is now available (trial mode)
    case PremiumRequired // A premium button, locked from the user.
}

class StyleFormatter {
    
    class func preferredFontForContext(_ context: FontDisplayContext) -> UIFont {
        switch context {
        case .question:
            return UIFont.systemFont(ofSize: 20.0)
        case .questionFraction:
            return UIFont.systemFont(ofSize: 14.0)
        case .answer:
            return UIFont.systemFont(ofSize: 72.0, weight: -0.75)
        case .answerFraction:
            return UIFont.systemFont(ofSize: 28.0)
        case .answerOr:
            return UIFont.systemFont(ofSize: 18.0)
        }
    }
    
    class func preferredFontForButtonOfSize(_ size: CGSize, keyStyle: KeyStyle) -> UIFont {
        
        let font = UIFont.preferredFont(forTextStyle: UIFontTextStyle.headline)
        
        return UIFont.systemFont(ofSize: font.pointSize * 1.1 + 2)
    }
    
}

extension UserDefaults {
    
    func colorForKey(key: String) -> UIColor? {
        var color: UIColor?
        if let colorData = data(forKey: key) {
            color = NSKeyedUnarchiver.unarchiveObject(with: colorData) as? UIColor
        }
        return color
    }
    
    func setColor(color: UIColor?, forKey key: String) {
        var colorData: NSData?
        if let color = color {
            colorData = NSKeyedArchiver.archivedData(withRootObject: color) as NSData?
        }
        set(colorData, forKey: key)
    }
}
