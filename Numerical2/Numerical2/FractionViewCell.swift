//
//  EquationViewCell.swift
//  Numerical2
//
//  Created by Andrew J Clark on 2/08/2015.
//  Copyright © 2015 Very Tiny Machines. All rights reserved.
//

import UIKit

public enum FractionViewCellType {
    case answer
    case question
    case or
}

class FractionViewCell:UICollectionViewCell {
    
    @IBOutlet weak var numeratorLabel: UILabel!
    @IBOutlet weak var denominatorLabel: UILabel!
    
    @IBOutlet weak var seperatorView: UIView!
    
    func setAnswerCell(_ answer: FractionViewCellType) {
        
        var font:UIFont?
        switch answer {
        case .answer:
            font = StyleFormatter.preferredFontForContext(FontDisplayContext.answerFraction)
        case .question:
            font = StyleFormatter.preferredFontForContext(FontDisplayContext.questionFraction)
        case .or:
            font = StyleFormatter.preferredFontForContext(FontDisplayContext.answerOr)
        }
        
        if let theFont = font {
            numeratorLabel.font = theFont
            denominatorLabel.font = theFont
        }
        
        numeratorLabel.textColor = ThemeCoordinator.shared.foregroundColorForCurrentTheme()
        denominatorLabel.textColor = ThemeCoordinator.shared.foregroundColorForCurrentTheme()
        seperatorView.backgroundColor = ThemeCoordinator.shared.foregroundColorForCurrentTheme()
    }
    
}
