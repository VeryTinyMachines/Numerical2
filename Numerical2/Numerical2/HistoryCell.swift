//
//  HistoryCell.swift
//  Numerical2
//
//  Created by Andrew J Clark on 9/09/2015.
//  Copyright © 2015 Very Tiny Machines. All rights reserved.
//

import UIKit

class HistoryCell: UITableViewCell {
    
    var equation:Equation?
    var currentEquation = false
    
    override func awakeFromNib() {
        self.backgroundColor = UIColor.clear
        self.selectionStyle = UITableViewCellSelectionStyle.none
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        if highlighted {
            contentView.backgroundColor = ThemeCoordinator.shared.foregroundColorForCurrentTheme().withAlphaComponent(0.25)
        } else {
            contentView.backgroundColor = UIColor.clear
        }
        
        super.setHighlighted(highlighted, animated: animated)
    }
}
