//
//  ViewController.swift
//  Numerical2
//
//  Created by Andrew J Clark on 31/07/2015.
//  Copyright © 2015 Very Tiny Machines. All rights reserved.
//

import UIKit

class ViewController: UIViewController, KeypadDelegate, HistoryViewControllerDelegate, WorkPanelDelegate {
    
    var historyView: HistoryViewController?
    var workPanelView: WorkPanelViewController?
    var currentEquation: Equation?
    
    @IBOutlet weak var workPanelBottomConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var workPanelHeightProportion: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        // Find out how many equations are in the equation store.
        
        if let equations = EquationStore.sharedStore.equationArrayForPad(nil) {
            
            for equation in equations {
                print("\(equation.question) = \(equation.answer)")
                
            }
            
            if let lastEquation = equations.last {
                print("retrieved equation from store")
                currentEquation = lastEquation
                
                if let theHistoryView = historyView {
                    theHistoryView.updateSelectedEquation(lastEquation)
                }
                if let theWorkPanel = workPanelView {
                    theWorkPanel.currentEquation = lastEquation
                    theWorkPanel.updateViews()
                }
                
            }
        }
    }
    

    
    func selectedEquation(equation: Equation) {
        print("equation: \(equation)", appendNewline: true)
        
        currentEquation = equation
        
        if let theWorkView = workPanelView {
            theWorkView.currentEquation = currentEquation
            theWorkView.updateViews()
            theWorkView.updateLegalKeys()
            presentKeypad()
        }
        
        if let theHistoryView = historyView {
            theHistoryView.updateSelectedEquation(equation)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if let keyPad = segue.destinationViewController as? HistoryViewController {
            historyView = keyPad
            keyPad.delegate = self
//            keyPad.reloadData()
            
            if let theCurrentEquation = currentEquation {
                keyPad.updateSelectedEquation(theCurrentEquation)
            }
            
        } else if let keyPad = segue.destinationViewController as? WorkPanelViewController {
            workPanelView = keyPad
            keyPad.delegate = self
            keyPad.workPanelDelegate = self
            keyPad.currentEquation = currentEquation
            keyPad.updateViews()
        }
    }
    
    func pressedKey(key: Character) {
        // A key was pressed. we need to reload the history view
        
        
        
    }
    
    func updateEquation(equation: Equation?) {
        
        currentEquation = equation
        
        if let theHistoryView = historyView {
            theHistoryView.updateSelectedEquation(currentEquation)
        }
    }
    
    func delectedEquation(equation: Equation) {
        
        if currentEquation == equation {
            
            currentEquation = nil
            if let theWorkPanel = workPanelView {
                theWorkPanel.currentEquation = currentEquation
                theWorkPanel.updateLegalKeys()
                theWorkPanel.updateViews()
            }
            
        }
        
    }
    
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        updateHistoryContentInsets()
        
    }

    func updateHistoryContentInsets() {
        if let view = historyView, workView = workPanelView {
            view.updateContentInsets(UIEdgeInsetsMake(0, 0, workView.view.bounds.height + workPanelBottomConstraint.constant, 0))
        }
    }
    
    
    func changeHeightMultipler(height: CGFloat) {
        if let theWorkPanel = workPanelView?.view, view = self.view {
            view.removeConstraint(workPanelHeightProportion)
            
            let newConstraint = NSLayoutConstraint(item: theWorkPanel, attribute: NSLayoutAttribute.Height, relatedBy: NSLayoutRelation.Equal, toItem: view, attribute: NSLayoutAttribute.Height, multiplier: height, constant: 1.0)
            
            workPanelHeightProportion = newConstraint
            view.addConstraint(newConstraint)
        }
    }
    
    func hideKeypad() {
//        workPanelBottomConstraint.constant = (workPanelHeightProportion.multiplier * self.view.bounds.height * -1) + 110
        
        // Remove the height constraint, then make a new one.
        
        
        
        changeHeightMultipler(0.5)
        
        if let workView = self.workPanelView {
            workView.showEquationView = false
            workView.updateLayout()
        }
        
        UIView.animateWithDuration(0.25, delay: 0.0, options: UIViewAnimationOptions.CurveEaseInOut, animations: { () -> Void in
            
            self.view.layoutIfNeeded()
            self.updateHistoryContentInsets()
            }) { (complete) -> Void in
                
        }
    }
    
    func presentKeypad() {
        //        workPanelBottomConstraint.constant = -0
        
        changeHeightMultipler(1.0)
        
        if let workView = self.workPanelView {
            workView.showEquationView = true
            workView.updateLayout()
        }
        
        UIView.animateWithDuration(0.25, delay: 0.0, options: UIViewAnimationOptions.CurveEaseInOut, animations: { () -> Void in
            
            self.view.layoutIfNeeded()
            self.updateHistoryContentInsets()
            
            }) { (complete) -> Void in
                
        }
    }
    
    @IBAction func swipeDown(sender: UISwipeGestureRecognizer) {
        
        hideKeypad()
        
    }
    
    
    
    @IBAction func swipeUp(sender: UISwipeGestureRecognizer) {
        presentKeypad()
        
    }

    @IBAction func toggleEditing(sender: AnyObject) {
        if let view = historyView {
            view.toggleEditing()
        }
    }
    
}

