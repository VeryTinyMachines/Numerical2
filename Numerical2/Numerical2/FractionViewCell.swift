//
//  EquationViewCell.swift
//  Numerical2
//
//  Created by Andrew J Clark on 2/08/2015.
//  Copyright © 2015 Very Tiny Machines. All rights reserved.
//

import UIKit

public enum FractionViewCellType {
    case Answer
    case Question
    case Or
}

class FractionViewCell:UICollectionViewCell {
    
    @IBOutlet weak var numeratorLabel: UILabel!
    @IBOutlet weak var denominatorLabel: UILabel!
    
    func setAnswerCell(answer: FractionViewCellType) {
        
        var font:UIFont?
        switch answer {
        case .Answer:
            font = StyleFormatter.preferredFontForContext(FontDisplayContext.AnswerFraction)
        case .Question:
            font = StyleFormatter.preferredFontForContext(FontDisplayContext.QuestionFraction)
        case .Or:
            font = StyleFormatter.preferredFontForContext(FontDisplayContext.AnswerOr)
        }
        
        if let theFont = font {
            numeratorLabel.font = theFont
            denominatorLabel.font = theFont
        }
    }
    
}