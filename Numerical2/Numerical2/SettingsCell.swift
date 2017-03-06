//
//  SettingsCell.swift
//  Numerical2
//
//  Created by Andrew Clark on 6/03/2017.
//  Copyright © 2017 Very Tiny Machines. All rights reserved.
//

import UIKit

class SettingsCell:UITableViewCell {
    
    
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
