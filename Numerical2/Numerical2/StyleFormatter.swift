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
    
    class func preferredFontForButtonOfSize(_ size: CGSize) -> UIFont {
        
        return UIFont.systemFont(ofSize: 20.0)
    }
    
}
