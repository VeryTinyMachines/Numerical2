//
//  QuestionCollectionView.swift
//  Numerical2
//
//  Created by Andrew Clark on 19/04/2017.
//  Copyright © 2017 Very Tiny Machines. All rights reserved.
//

import UIKit

class QuestionCollectionView:UICollectionView {
    
    override func draw(_ rect: CGRect) {
        self.transform = CGAffineTransform(scaleX: -1.0, y: 1.0) // FLIP!
    }
    
    
}
