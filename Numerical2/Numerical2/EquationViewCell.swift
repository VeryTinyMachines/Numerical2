//
//  EquationViewCell.swift
//  Numerical2
//
//  Created by Andrew J Clark on 2/08/2015.
//  Copyright © 2015 Very Tiny Machines. All rights reserved.
//

import UIKit

public enum EquationViewCellType {
    case Answer
    case Question
    case Or
}

class EquationViewCell:UICollectionViewCell {
    
    @IBOutlet weak var mainLabel: UILabel!
    
    func setAnswerCell(answer: EquationViewCellType) {
        
        var font:UIFont?
        switch answer {
        case .Answer:
            font = StyleFormatter.preferredFontForContext(FontDisplayContext.Answer)
        case .Question:
            font = StyleFormatter.preferredFontForContext(FontDisplayContext.Question)
        case .Or:
            font = StyleFormatter.preferredFontForContext(FontDisplayContext.AnswerOr)
        }
        
        if let theFont = font {
            mainLabel.font = theFont
        }
        
    }
    
}