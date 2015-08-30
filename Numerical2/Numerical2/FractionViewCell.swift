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
            numeratorLabel.font = UIFont.preferredFontForTextStyle(UIFontTextStyleHeadline)
            denominatorLabel.font = UIFont.preferredFontForTextStyle(UIFontTextStyleHeadline)
        } else {
            numeratorLabel.font = UIFont.preferredFontForTextStyle(UIFontTextStyleBody)
            denominatorLabel.font = UIFont.preferredFontForTextStyle(UIFontTextStyleBody)
        }
    }
    
}