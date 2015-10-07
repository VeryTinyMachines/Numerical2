//
//  EquationViewCell.swift
//  Numerical2
//
//  Created by Andrew J Clark on 2/08/2015.
//  Copyright © 2015 Very Tiny Machines. All rights reserved.
//

import UIKit

class FractionViewCell:UICollectionViewCell {
    
    @IBOutlet weak var numeratorLabel: UILabel!
    @IBOutlet weak var denominatorLabel: UILabel!
    
    func setAnswerCell(answer: Bool) {
        
        if answer {
            let font = StyleFormatter.preferredFontForContext(FontDisplayContext.AnswerFraction)
            numeratorLabel.font = font
            denominatorLabel.font = font
        } else {
            let font = StyleFormatter.preferredFontForContext(FontDisplayContext.QuestionFraction)
            numeratorLabel.font = font
            denominatorLabel.font = font
        }
        
        
    }
    
}