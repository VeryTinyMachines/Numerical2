//
//  ViewController.swift
//  Numerical2
//
//  Created by Andrew J Clark on 31/07/2015.
//  Copyright © 2015 Very Tiny Machines. All rights reserved.
//

import UIKit

public enum KeypadSize {
    case maximum
    case medium
    case minimum
}

class ViewController: NumericalViewController, KeypadDelegate, HistoryViewControllerDelegate, WorkPanelDelegate {
    
    @IBOutlet weak var statusBarBlur: UIVisualEffectView!
    
    var historyView: HistoryViewController?
    var workPanelView: WorkPanelViewController?
    var currentEquation: Equation?
    var currentSize = KeypadSize.maximum
    var workPanelShowEquation = true
    
    var workPanelSlideOrigin:CGPoint?
    var workPanelLastLocation:CGPoint?
    var workPanelVerticalSpeed:CGFloat = 0.0
    
    var workPanelPercentage:Float = 1.0
    
    var panning = false
    
    @IBOutlet weak var backgroundImageView: UIImageView!
    
    @IBOutlet weak var workPanelHeight: NSLayoutConstraint!
    
    @IBOutlet weak var workPanelBottomConstraint: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor.green
        
        presentKeypad()
        themeChanged()
        
        DispatchQueue.main.async {
            NotificationCenter.default.addObserver(self, selector: #selector(ViewController.themeChanged), name: Notification.Name(rawValue: PremiumCoordinatorNotification.themeChanged), object: nil)
        }
    }
    
    func themeChanged() {
        self.backgroundImageView.image = PremiumCoordinator.shared.imageForCurrentTheme()
    }
    
    
    func selectedEquation(_ equation: Equation) {
        
        currentEquation = equation
        
        if let theWorkView = workPanelView {
            theWorkView.currentEquation = currentEquation
            theWorkView.updateViews(currentCursor: nil)
            theWorkView.updateLegalKeys()
            presentKeypad()
        }
        
        EquationStore.sharedStore.setCurrentEquationID(string: equation.identifier)
        
        if let theHistoryView = historyView {
            theHistoryView.updateSelectedEquation(equation)
        }
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if let keyPad = segue.destination as? HistoryViewController {
            historyView = keyPad
            keyPad.delegate = self
            
            if let theCurrentEquation = currentEquation {
                keyPad.updateSelectedEquation(theCurrentEquation)
            }
            
        } else if let keyPad = segue.destination as? WorkPanelViewController {
            workPanelView = keyPad
            keyPad.delegate = self
            keyPad.workPanelDelegate = self
            keyPad.currentEquation = currentEquation
            keyPad.updateViews(currentCursor: nil)
            
            // Add a gesture recogniser to the keypad
            
            let slideGesture = UIPanGestureRecognizer(target: self, action: #selector(ViewController.workPanelPanned(_:)))
            keyPad.view.addGestureRecognizer(slideGesture)
        }
    }
    
    
    func workPanelPanned(_ sender: UIPanGestureRecognizer) {
        print("workPanelPanned")
        
        let location = sender.location(in: view)
        print(location)
        
        if needsEditMenuDismissal() {
            sender.isEnabled = false
            sender.isEnabled = true
            return
        }
        
        switch sender.state {
        case .began:
            print("began")
            workPanelSlideOrigin = location
            workPanelLastLocation = location
            view.layer.removeAllAnimations()
        case .cancelled:
            print("cancelled")
        case .changed:
            print("changed")

            // origin is where the touch started.
            // location is where the touch is now.
            // the work panel has it's own height as a percentage (workPanelPercentage)
            // we need to determine, based on the 3 items above, what the new percentage is.
            
            if let origin = workPanelSlideOrigin {
                
                let verticalDelta = location.y - origin.y
                
                let verticalDeltaPercentage = verticalDelta / view.bounds.height
                
                if panning == false {
                    if verticalDelta > 30 || verticalDelta < -30 {
                        
                        panning = true
                        
                        // Quickly animate to this pan point
                        
                        let newHeight = CGFloat(workPanelPercentage) - verticalDeltaPercentage
                        
                        updateWorkPanelForHeight(Float(newHeight))
                        
//                        if workPanelVerticalSpeed > -5 && workPanelVerticalSpeed < 5 {
//                            // Panel is moving slowly
//                            UIView.animate(withDuration: 0.15, animations: {
//                                self.view.layoutIfNeeded()
//                                }, completion: { (complet) in
//                                    
//                            })
//                        } else {
//                            self.view.layoutIfNeeded()
//                        }
                        
                        self.view.layoutIfNeeded()
                        
                    }
                } else {
                    let newHeight = CGFloat(workPanelPercentage) - verticalDeltaPercentage
                    
                    print("newHeight: \(newHeight)")
                    
                    updateWorkPanelForHeight(Float(newHeight))
                    
                    view.layoutIfNeeded()

                }
                
            }
            
            if let lastLocation = workPanelLastLocation {
                workPanelVerticalSpeed = lastLocation.y - location.y
            }
            
            workPanelLastLocation = location
            
        case .ended:
            print("ended")
            
            panning = false
            
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
            
            UIView.animate(withDuration: 0.25, delay: 0.0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.0, options: UIViewAnimationOptions(), animations: { () -> Void in
                    self.updateKeypad()
                }, completion: { (complete) -> Void in
                    self.updateKeypad()
                    
            })
            
            workPanelVerticalSpeed = 0
            
        case .failed:
            print("failed")
            panning = false
        case .possible:
            print("possible")
        }
    }
    
    
    func snapPercentageHeight(_ verticalSpeed: CGFloat, viewSize: CGSize) {
        
        print("snapPercentageHeight: \(verticalSpeed)")
        
        // Look at the vertical speed to decide what height to snap it to.
        
        // Determine the height of equation as a percentage
        let equationHeightPercentage = 140 / viewSize.height
        
        workPanelPercentage += Float(verticalSpeed) / Float(viewSize.height) * 5
        
        var allowMiddlePosition = true
        
        if NumericalHelper.isDevicePad() == false && viewSize.width > viewSize.height {
            // Device is landscape iPhone - don't allow the middle position
            allowMiddlePosition = false
        }
        
        if verticalSpeed > 5 || verticalSpeed < -5 {
            
            if allowMiddlePosition {
                // Portrait
                if workPanelPercentage > 0.66 {
                    if verticalSpeed > 0 {
                        workPanelPercentage = 1.0
                    } else {
                        workPanelPercentage = 0.5
                    }
                    
                } else if workPanelPercentage > 0.33 {
                    
                    if verticalSpeed > 0 {
                        workPanelPercentage = 0.5
                    } else {
                        workPanelPercentage = Float(equationHeightPercentage)
                    }
                    
                } else {
                    workPanelPercentage = Float(equationHeightPercentage)
                }
            } else {
                // Landscape
                if verticalSpeed > 0 {
                    workPanelPercentage = 1.0
                } else {
                    workPanelPercentage = Float(equationHeightPercentage)
                }
            }
            
        } else {
            if allowMiddlePosition {
                // Portrait
                if workPanelPercentage > 0.66 {
                    workPanelPercentage = 1.0
                } else if workPanelPercentage > 0.33 {
                    workPanelPercentage = 0.5
                } else {
                    workPanelPercentage = Float(equationHeightPercentage)
                }
            } else {
                // Landscape
                if workPanelPercentage > 0.5 {
                    workPanelPercentage = 1.0
                } else {
                    workPanelPercentage = Float(equationHeightPercentage)
                }
            }
        }
        
        // Update history view content insets.
        updateHistoryContentInsets(viewSize: viewSize)
        
    }
    
    
    func pressedKey(_ key: Character, sourceView: UIView?) {
        // A key was pressed. No action required as history view is using a fetched results controller.
        
    }
    
    
    func viewIsWide() -> Bool {
        return false
    }
    
    
    func updateEquation(_ equation: Equation?) {
        
        currentEquation = equation
        
        if let theHistoryView = historyView {
            theHistoryView.updateSelectedEquation(currentEquation)
        }
    }
    
    
    func delectedEquation(_ equation: Equation) {
        
        if currentEquation == equation {
            
            currentEquation = nil
            if let theWorkPanel = workPanelView {
                theWorkPanel.currentEquation = currentEquation
                theWorkPanel.updateLegalKeys()
                theWorkPanel.updateViews(currentCursor: nil)
            }
        }
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        updateHistoryContentInsets(viewSize: self.view.frame.size)
        
        // Focus the history view on the current equation
        historyView?.focusOnCurrentEquation()
        
        // ZZZ
    }
    

    func updateHistoryContentInsets(viewSize: CGSize) {
        
        let equationHeightPercentage = 140 / viewSize.height
        
//        workPanelPercentage += Float(verticalSpeed) / Float(viewSize.height) * 5
        
        var bottomInset:CGFloat = viewSize.height * CGFloat(workPanelPercentage)
        
        if viewSize.width > viewSize.height {
            bottomInset = viewSize.height * CGFloat(equationHeightPercentage)
        } else {
            if workPanelPercentage > 0.5 {
                bottomInset = viewSize.height * 0.5
            }
        }
        
        self.historyView?.updateContentInsets(UIEdgeInsets(top: 44, left: 0, bottom: bottomInset, right: 0))
        
//        if let theHistoryView = historyView {
//            
//            let bottomInset = view.bounds.height - 88
//            
//            theHistoryView.updateContentInsets(UIEdgeInsetsMake(40, 0, bottomInset, 0))
//        }
    }
    
    func updateWorkPanelForHeight(_ heightPercentage: Float) {
        
        // Between 1.0 and 0.5 the height shrinks. Below this the height remains the same but the position is offset.
        
        var newHeight = CGFloat(heightPercentage)
        
        // Less the height by 10points (for the status bar)
        
        // If there is a status bar
        
        if UIApplication.shared.isStatusBarHidden {
            // Status bar is NOT visible, hide the status bar blur view.
            statusBarBlur.isHidden = true
            
        } else {
            // Status bar is visible
            statusBarBlur.isHidden = false
//            newHeight = newHeight * ((view.bounds.height - 20) / (view.bounds.height - 0))
        }
        
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
    
    
    func changeHeightMultipler(_ height: CGFloat) {
        if let theWorkPanel = workPanelView?.view, let view = self.view {
            view.removeConstraint(workPanelHeight)
            
            let newConstraint = NSLayoutConstraint(item: theWorkPanel, attribute: NSLayoutAttribute.height, relatedBy: NSLayoutRelation.equal, toItem: view, attribute: NSLayoutAttribute.height, multiplier: height, constant: 1.0)
            
            workPanelHeight = newConstraint
            view.addConstraint(newConstraint)
        }
    }
    
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        
        needsEditMenuDismissal()
        
        super.viewWillTransition(to: size, with: coordinator)
        
        coordinator.animate(alongsideTransition: { (context) -> Void in
            self.snapPercentageHeight(0.0, viewSize: size)
            self.updateKeypad()
            self.view.layoutIfNeeded()
            }) { (context) -> Void in
        }
    }
    
    func updateKeypad() {
        
        updateWorkPanelForHeight(workPanelPercentage)
        
        view.layoutIfNeeded()
        
        if let workView = self.workPanelView {
            workView.updateLayout()
        }
    }
    
    
    func hideKeypad() {
        if currentSize == KeypadSize.maximum {
            currentSize = KeypadSize.medium
        } else {
            currentSize = KeypadSize.minimum
        }
        
        updateKeypad()
    }
    
    
    func presentKeypad() {
        if currentSize == KeypadSize.minimum {
            currentSize = KeypadSize.medium
        } else {
            currentSize = KeypadSize.maximum
        }
        
        updateKeypad()
    }
    
    
    @IBAction func swipeDown(_ sender: UISwipeGestureRecognizer) {
        hideKeypad()
    }
    
    
    @IBAction func swipeUp(_ sender: UISwipeGestureRecognizer) {
        presentKeypad()
    }

    @IBAction func toggleEditing(_ sender: AnyObject) {
        if let view = historyView {
            view.toggleEditing()
        }
    }
    
    override var preferredStatusBarStyle : UIStatusBarStyle {
        return UIStatusBarStyle.lightContent
    }
}

