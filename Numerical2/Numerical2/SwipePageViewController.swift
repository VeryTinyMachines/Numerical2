//
//  SwipePageViewController.swift
//  Numerical2
//
//  Created by Andrew Clark on 24/04/2017.
//  Copyright © 2017 Very Tiny Machines. All rights reserved.
//

import UIKit

class SwipePageViewController:UIPageViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let myView = view?.subviews.first as? UIScrollView {
            myView.canCancelContentTouches = false
        }
    }
}
