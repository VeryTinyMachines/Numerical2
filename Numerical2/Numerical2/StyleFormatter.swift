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
    case questionWidget
    case answerWidget
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
        case .questionFraction:
            pointSize = 26
        case .questionWidget:
            pointSize = 22
        case .answer, .answerWidget:
            pointSize = 80
            fontName = "HelveticaNeue-Thin"
        case .answerFraction:
            pointSize = 34
        case .answerOr:
            pointSize = 18
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
            if key == SymbolCharacter.keyboard {
                pointSize *= 0.7
                fontName = "HelveticaNeue"
            } else if key == SymbolCharacter.subtract || key == SymbolCharacter.divide {
                pointSize *= 1.3
            } else if smallOperands.contains(key) {
                pointSize *= 1.2
            } else if key == SymbolCharacter.app {
                pointSize *= 0.8
                fontName = "HelveticaNeue"
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
