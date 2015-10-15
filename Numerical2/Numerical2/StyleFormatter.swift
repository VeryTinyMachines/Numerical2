//
//  StyleFormatter.swift
//  Numerical2
//
//  Created by Andrew J Clark on 29/09/2015.
//  Copyright © 2015 Very Tiny Machines. All rights reserved.
//

import UIKit

public enum FontDisplayContext {
    case Question
    case QuestionFraction
    case Answer
    case AnswerFraction
    case AnswerOr
}

class StyleFormatter {
    
    
    
    class func preferredFontForContext(context: FontDisplayContext) -> UIFont {
        switch context {
        case .Question:
            return UIFont.systemFontOfSize(14.0)
        case .QuestionFraction:
            return UIFont.systemFontOfSize(14.0)
        case .Answer:
            return UIFont.systemFontOfSize(72.0, weight: -0.75)
        case .AnswerFraction:
            return UIFont.systemFontOfSize(14.0)
        case .AnswerOr:
            return UIFont.systemFontOfSize(14.0)
        }
    }
    
    
}
