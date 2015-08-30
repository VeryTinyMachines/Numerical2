//
//  EquationViewCell.swift
//  Numerical2
//
//  Created by Andrew J Clark on 2/08/2015.
//  Copyright © 2015 Very Tiny Machines. All rights reserved.
//

import UIKit

class EquationViewCell:UICollectionViewCell {
    
    @IBOutlet weak var mainLabel: UILabel!
    
    func setAnswerCell(answer: Bool) {
        if answer {
            mainLabel.font = UIFont.preferredFontForTextStyle(UIFontTextStyleHeadline)
        } else {
            mainLabel.font = UIFont.preferredFontForTextStyle(UIFontTextStyleBody)
        }
    }
    
}