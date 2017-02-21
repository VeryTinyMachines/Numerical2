//
//  TutorialViewController.swift
//  Numerical2
//
//  Created by Andrew Clark on 16/01/2017.
//  Copyright © 2017 Very Tiny Machines. All rights reserved.
//

import UIKit

class TutorialViewController:NumericalViewController {
    
    @IBOutlet weak var blurView: UIVisualEffectView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        blurView.alpha = 0.0
        
        
        
        
        
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        UIView.animate(withDuration: 1.0, animations: {
            self.blurView.alpha = 1.0
        }) { (complete) in
            // Begin the tutorial
        }
    }
}
