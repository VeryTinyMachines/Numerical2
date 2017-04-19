//
//  EquationViewCell.swift
//  Numerical2
//
//  Created by Andrew J Clark on 2/08/2015.
//  Copyright © 2015 Very Tiny Machines. All rights reserved.
//

import UIKit

public enum EquationViewCellType {
    case answer
    case question
    case or
}

class EquationViewCell:UICollectionViewCell {
    
    @IBOutlet weak var mainLabel: UILabel!
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.transform = CGAffineTransform(scaleX: -1.0, y: 1.0)
    }
    
    func setAnswerCell(_ answer: EquationViewCellType) {
        
        var font:UIFont?
        switch answer {
        case .answer:
            font = StyleFormatter.preferredFontForContext(FontDisplayContext.answer)
        case .question:
            font = StyleFormatter.preferredFontForContext(FontDisplayContext.question)
        case .or:
            font = StyleFormatter.preferredFontForContext(FontDisplayContext.answerOr)
        }
        
        if let theFont = font {
            mainLabel.font = theFont
        }
        
        mainLabel.textColor = ThemeCoordinator.shared.foregroundColorForCurrentTheme()
        
    }
    
}
