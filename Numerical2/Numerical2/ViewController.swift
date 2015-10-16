//
//  ViewController.swift
//  Numerical2
//
//  Created by Andrew J Clark on 31/07/2015.
//  Copyright © 2015 Very Tiny Machines. All rights reserved.
//

import UIKit

public enum KeypadSize {
    case Maximum
    case Medium
    case Minimum
}

class ViewController: UIViewController, KeypadDelegate, HistoryViewControllerDelegate, WorkPanelDelegate {
    
    var historyView: HistoryViewController?
    var workPanelView: WorkPanelViewController?
    var currentEquation: Equation?
    var currentSize = KeypadSize.Maximum
    var workPanelShowEquation = true
    
    var workPanelSlideOrigin:CGPoint?
    var workPanelLastLocation:CGPoint?
    var workPanelVerticalSpeed:CGFloat = 0.0
    
    
    var workPanelPercentage:Float = 0.9
    
    @IBOutlet weak var workPanelHeight: NSLayoutConstraint!
    
    @IBOutlet weak var workPanelBottomConstraint: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        presentKeypad()
        
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
//        print("equation: \(equation)", appendNewline: true)
        
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
            
            // Add a gesture recogniser to the keypad
            
            let slideGesture = UIPanGestureRecognizer(target: self, action: "workPanelPanned:")
            keyPad.view.addGestureRecognizer(slideGesture)
        }
    }
    
    func workPanelPanned(sender: UIPanGestureRecognizer) {
        print("workPanelPanned")
        
        let location = sender.locationInView(view)
        print(location)
        
        switch sender.state {
        case .Began:
            print("began")
            workPanelSlideOrigin = location
            workPanelLastLocation = location
            view.layer.removeAllAnimations()
        case .Cancelled:
            print("cancelled")
        case .Changed:
            print("changed")

            // origin is where the touch started.
            // location is where the touch is now.
            // the work panel has it's own height as a percentage (workPanelPercentage)
            // we need to determine, based on the 3 items above, what the new percentage is.
            
            if let origin = workPanelSlideOrigin {
                let verticalDelta = location.y - origin.y
                
                print("verticalDelta: \(verticalDelta)")
                
                let verticalDeltaPercentage = verticalDelta / view.bounds.height
                
                print("verticalDeltaPercentage: \(verticalDeltaPercentage)")
                
                let newHeight = CGFloat(workPanelPercentage) - verticalDeltaPercentage
                
                print("newHeight: \(newHeight)")
                
                updateWorkPanelForHeight(Float(newHeight))
                
                view.layoutIfNeeded()
            }
            
            
            if let lastLocation = workPanelLastLocation {
                workPanelVerticalSpeed = lastLocation.y - location.y
                print("workPanelVerticalSpeed")
                print(workPanelVerticalSpeed)
            }
            
            workPanelLastLocation = location
            
        case .Ended:
            print("ended")
            
            if let origin = workPanelSlideOrigin {
                let verticalDelta = location.y - origin.y
                
                print("verticalDelta: \(verticalDelta)")
                
                let verticalDeltaPercentage = verticalDelta / view.bounds.height
                
                print("verticalDeltaPercentage: \(verticalDeltaPercentage)")
                
                let newHeight = CGFloat(workPanelPercentage) - verticalDeltaPercentage
                
                workPanelPercentage = Float(newHeight)
                
                updateWorkPanelForHeight(Float(newHeight))
                
                view.layoutIfNeeded()
            }
            
            workPanelSlideOrigin = nil
            
            // Snap to presets
            snapPercentageHeight(workPanelVerticalSpeed, viewSize: view.frame.size)
            
            updateWorkPanelForHeight(workPanelPercentage)
            
            UIView.animateWithDuration(0.25, delay: 0.0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.0, options: UIViewAnimationOptions.CurveEaseInOut, animations: { () -> Void in
                    self.updateKeypad()
                }, completion: { (complete) -> Void in
                    self.updateKeypad()
                    
            })
            
            workPanelVerticalSpeed = 0
            
        case .Failed:
            print("failed")
        case .Possible:
            print("possible")
            
        }
        
        
    }
    
    func snapPercentageHeight(verticalSpeed: CGFloat, viewSize: CGSize) {
        
        print("snapPercentageHeight: \(verticalSpeed)")
        
        // Determine the height of equation as a percentage
        let equationHeightPercentage = 130 / viewSize.height
        workPanelPercentage += Float(verticalSpeed) / Float(viewSize.height) * 5
        
        if viewSize.width > viewSize.height {
            // Landscape
            if workPanelPercentage > 0.5 {
                workPanelPercentage = 1.0
            } else {
                workPanelPercentage = Float(equationHeightPercentage)
            }
        } else {
            // Portrait
            if workPanelPercentage > 0.66 {
                workPanelPercentage = 0.9
            } else if workPanelPercentage > 0.33 {
                workPanelPercentage = 0.5
            } else {
                workPanelPercentage = Float(equationHeightPercentage)
            }
        }
        
    }
    
    func pressedKey(key: Character) {
        // A key was pressed. we need to reload the history view
    }
    
    
    func viewIsWide() -> Bool {
        return false
    }
    
    
    func updateEquation(equation: Equation?) {
        
        currentEquation = equation
        
        if let theHistoryView = historyView {
            theHistoryView.updateSelectedEquation(currentEquation)
            
            if currentSize == KeypadSize.Medium {
                
                // Get the keypanels current size
                
                if let workPanelFrame = workPanelView?.view, _ = currentEquation {
//                    theHistoryView.focusOnEquation(currentEquation, alignmentRect: workPanelFrame.frame)
                }
            }
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
        if let theHistoryView = historyView {
            
            let bottomInset = view.bounds.height - 88
            
            theHistoryView.updateContentInsets(UIEdgeInsetsMake(0, 0, bottomInset, 0))
        }
    }
    
    func updateWorkPanelForHeight(heightPercentage: Float) {
        
        // Between 1.0 and 0.5 the height shrinks. Below this the height remains the same but the position is offset.
        
        var newHeight = CGFloat(heightPercentage)
        
        if newHeight < 0 {
            newHeight = 0
        }
        
        if newHeight > 0.5 {
            
            changeHeightMultipler(CGFloat(newHeight))
            workPanelBottomConstraint.constant = 0
        } else {
            changeHeightMultipler(CGFloat(0.5))
            
            let offset:CGFloat = (CGFloat(newHeight) - 0.5)
            
            workPanelBottomConstraint.constant = offset * view.bounds.height
        }
        
        
        
        
        
    }
    
    
    func changeHeightMultipler(height: CGFloat) {
        if let theWorkPanel = workPanelView?.view, view = self.view {
            view.removeConstraint(workPanelHeight)
            
            let newConstraint = NSLayoutConstraint(item: theWorkPanel, attribute: NSLayoutAttribute.Height, relatedBy: NSLayoutRelation.Equal, toItem: view, attribute: NSLayoutAttribute.Height, multiplier: height, constant: 1.0)
            
            workPanelHeight = newConstraint
            view.addConstraint(newConstraint)
        }
    }
    
    
    override func viewWillTransitionToSize(size: CGSize, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {
        
        super.viewWillTransitionToSize(size, withTransitionCoordinator: coordinator)
        
        snapPercentageHeight(0.0, viewSize: size)
        
        coordinator.animateAlongsideTransition({ (context) -> Void in
            self.updateKeypad()
            self.view.layoutIfNeeded()
            }) { (context) -> Void in
        }
        
    }
    
    
    func updateKeypad() {
        
        updateWorkPanelForHeight(workPanelPercentage)
        updateHistoryContentInsets()
        view.layoutIfNeeded()
        
        if let workView = self.workPanelView {
            workView.updateLayout()
        }
        
        
    }
    
    
    func hideKeypad() {
        if currentSize == KeypadSize.Maximum {
            currentSize = KeypadSize.Medium
        } else {
            currentSize = KeypadSize.Minimum
        }
        
        updateKeypad()
    }
    
    
    func presentKeypad() {
        if currentSize == KeypadSize.Minimum {
            currentSize = KeypadSize.Medium
        } else {
            currentSize = KeypadSize.Maximum
        }
        
        
        updateKeypad()
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
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent
    }
}

