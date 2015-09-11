//
//  ViewController.swift
//  Numerical2
//
//  Created by Andrew J Clark on 31/07/2015.
//  Copyright © 2015 Very Tiny Machines. All rights reserved.
//

import UIKit

class ViewController: UIViewController, KeypadDelegate {
    
    var historyView: HistoryViewController?
    var workPanelView: WorkPanelViewController?
    
    @IBOutlet weak var workPanelBottomConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var workPanelHeightProportion: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if let keyPad = segue.destinationViewController as? HistoryViewController {
            historyView = keyPad
            keyPad.reloadData()
        } else if let keyPad = segue.destinationViewController as? WorkPanelViewController {
            workPanelView = keyPad
            keyPad.delegate = self
        }
    }
    
    func pressedKey(key: Character) {
        // A key was pressed. we need to reload the history view
        if let view = historyView {
            view.reloadData()
            
            
        }
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        updateHistoryContentInsets()
        
    }

    func updateHistoryContentInsets() {
        if let view = historyView, workView = workPanelView {
            view.updateContentInsets(UIEdgeInsetsMake(0, 0, workView.view.bounds.height - 44 + workPanelBottomConstraint.constant, 0))
        }
    }
    
    
    @IBAction func swipeDown(sender: UISwipeGestureRecognizer) {
        
        
        print("self.view.bounds.height: \(self.view.bounds.height)")
        
        workPanelBottomConstraint.constant = (workPanelHeightProportion.multiplier * self.view.bounds.height * -1) + 110
        
        
        
        UIView.animateWithDuration(0.25, delay: 0.0, options: UIViewAnimationOptions.CurveEaseInOut, animations: { () -> Void in
            
            self.view.layoutIfNeeded()
            self.updateHistoryContentInsets()
            }) { (complete) -> Void in
        }
    }
    
    
    @IBAction func swipeUp(sender: UISwipeGestureRecognizer) {
        
        workPanelBottomConstraint.constant = -0
        
        UIView.animateWithDuration(0.25, delay: 0.0, options: UIViewAnimationOptions.CurveEaseInOut, animations: { () -> Void in
            
            self.view.layoutIfNeeded()
            self.updateHistoryContentInsets()
            
            }) { (complete) -> Void in
        }
    }

}

