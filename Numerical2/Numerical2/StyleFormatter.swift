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
    case about
}

public enum KeyStyle {
    case Available // A normal button
    case AvailablePremium // A usually premium button that is now available (trial mode)
    case PremiumRequired // A premium button, locked from the user.
}

class StyleFormatter {
    
    class func preferredFontForContext(_ context: FontDisplayContext) -> UIFont {
        var pointSize:CGFloat = 20
        var fontName = "HelveticaNeue-Light"
        
        switch context {
        case .question:
            pointSize = 26
            //return UIFont.systemFont(ofSize: 20.0)
        case .questionFraction:
            //return UIFont.systemFont(ofSize: 14.0)
            pointSize = 26
        case .answer:
            pointSize = 80
            fontName = "HelveticaNeue-Thin"
            //return UIFont(name: fontName, size: pointSize)!
        case .answerFraction:
            pointSize = 34
            //return UIFont.systemFont(ofSize: 28.0)
        case .answerOr:
            pointSize = 18
            //return UIFont.systemFont(ofSize: 18.0)
        case .about:
            pointSize = 16
            fontName = "Avenir-Light"
        }
        
        if let font = UIFont(name: fontName, size: pointSize) {
            return font
        } else {
            return UIFont.systemFont(ofSize: pointSize)
        }
    }
    
    class func preferredFontForButtonOfSize(_ size: CGSize, key: Character?) -> UIFont {
        
        var pointSize:CGFloat = 25 // Numerical 1 was 25
        var fontName = "HelveticaNeue-Light"
        
        let smallOperands:Set<Character> = [SymbolCharacter.add, SymbolCharacter.multiply, SymbolCharacter.infinity]
        
        if let key = key {
            if key == SymbolCharacter.subtract || key == SymbolCharacter.divide {
                pointSize *= 1.3
                return UIFont(name: fontName, size: pointSize)!
                //return UIFont(name: "HelveticaNeue-Thin", size: pointSize)!
                //return UIFont(name: "AvenirNext-Regular", size: pointSize)!
            } else if smallOperands.contains(key) {
                pointSize *= 1.2
            }
        }
        
        if let font = UIFont(name: fontName, size: pointSize) {
            return font
        } else {
            return UIFont.systemFont(ofSize: pointSize)
        }
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
