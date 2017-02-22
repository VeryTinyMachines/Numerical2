//
//  ViewController.swift
//  Numerical2
//
//  Created by Andrew J Clark on 31/07/2015.
//  Copyright © 2015 Very Tiny Machines. All rights reserved.
//

import UIKit
import Firebase

public enum KeypadSize {
    case maximum
    case medium
    case minimum
}

class ViewController: NumericalViewController, KeypadDelegate, HistoryViewControllerDelegate, WorkPanelDelegate, GADBannerViewDelegate {
    
    @IBOutlet weak var statusBarBlur: UIView!
    
    var blurView: UIVisualEffectView?
    
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
    
    var adReadyToDisplay = false
    
    var gradiantLayer:CAGradientLayer?
    
    @IBOutlet weak var bannerView: GADBannerView!
    
    @IBOutlet weak var backgroundImageView: UIImageView!
    
    @IBOutlet weak var workPanelHeight: NSLayoutConstraint!
    
    @IBOutlet weak var workPanelBottomConstraint: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor.green
        
        presentKeypad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(ViewController.themeChanged), name: Notification.Name(rawValue: PremiumCoordinatorNotification.themeChanged), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(ViewController.premiumStatusChanged), name: Notification.Name(rawValue: PremiumCoordinatorNotification.premiumStatusChanged), object: nil)
        
        /*
        bannerView.adUnitID = "ca-app-pub-3940256099942544/2934735716"
        bannerView.rootViewController = self
        bannerView.delegate = self
        bannerView.isHidden = true
        
        let request = GADRequest()
//        request.testDevices = [kGADSimulatorID]
        bannerView.load(request)
        */
        
        themeChanged()
        
        /*
        Timer.scheduledTimer(withTimeInterval: 2.0, repeats: false, block: { (timer) in
            
        })
 */
        
    }
    
    /*
    /// Tells the delegate an ad request loaded an ad.
    func adViewDidReceiveAd(_ bannerView: GADBannerView!) {
       //print("adViewDidReceiveAd")
        adReadyToDisplay = true
        premiumStatusChanged()
    }
    
    /// Tells the delegate an ad request failed.
    func adView(_ bannerView: GADBannerView!,
                didFailToReceiveAdWithError error: GADRequestError!) {
       //print("adView:didFailToReceiveAdWithError: \(error.localizedDescription)")
        
        adReadyToDisplay = false
        premiumStatusChanged()
    }
    
    /// Tells the delegate that a full screen view will be presented in response
    /// to the user clicking on an ad.
    func adViewWillPresentScreen(_ bannerView: GADBannerView!) {
       //print("adViewWillPresentScreen")
    }
    
    /// Tells the delegate that the full screen view will be dismissed.
    func adViewWillDismissScreen(_ bannerView: GADBannerView!) {
       //print("adViewWillDismissScreen")
    }
    
    /// Tells the delegate that the full screen view has been dismissed.
    func adViewDidDismissScreen(_ bannerView: GADBannerView!) {
       //print("adViewDidDismissScreen")
    }
    
    /// Tells the delegate that a user click will open another app (such as
    /// the App Store), backgrounding the current app.
    func adViewWillLeaveApplication(_ bannerView: GADBannerView!) {
       //print("adViewWillLeaveApplication")
    }
    */
    
    func themeChanged() {
        self.backgroundImageView.image = nil
        self.backgroundImageView.isHidden = true
        
        self.view.layoutIfNeeded()
        
        if let gradiantLayer = gradiantLayer {
            gradiantLayer.removeFromSuperlayer()
        }
        
        let layer = ThemeCoordinator.shared.gradiantLayerForCurrentTheme()
        layer.frame = self.view.frame
        
        self.view.layer.insertSublayer(layer, at: 0)
        
        self.view.backgroundColor = ThemeCoordinator.shared.currentTheme().firstColor
        
        gradiantLayer = layer
        
        // Update the status bar blur view
        updateBlurView()
        
        self.setNeedsStatusBarAppearanceUpdate()
    }
    
    func updateBlurView() {
        if let currentBlurView = self.blurView {
            currentBlurView.removeFromSuperview()
            self.blurView = nil
        }
        
        let visualEffectView = ThemeCoordinator.shared.visualEffectViewForCurrentTheme()
        self.statusBarBlur.insertSubview(visualEffectView, at: 0)
        
        visualEffectView.bindFrameToSuperviewBounds()
        
        self.blurView = visualEffectView
    }
    
    func premiumStatusChanged() {
        
        if bannerView.isHidden {
            if showAd() {
                // Banner is hidden, but user should be seeing an ad.
                bannerView.isHidden = false
                
                snapPercentageHeight()
                
                UIView.animate(withDuration: 0.15) {
                    self.view.layoutIfNeeded()
                }
            }
        } else {
            // Banner is visible, check if it should be shown
            if showAd() == false {
                bannerView.isHidden = true
                
                snapPercentageHeight()
                
                UIView.animate(withDuration: 0.15) {
                    self.view.layoutIfNeeded()
                }
            }
        }
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
       //print("workPanelPanned")
        
        let location = sender.location(in: view)
       //print(location)
        
        switch sender.state {
        case .began:
           //print("began")
            workPanelSlideOrigin = location
            workPanelLastLocation = location
            view.layer.removeAllAnimations()
        case .cancelled:
           //print("cancelled")
            break
        case .changed:
           //print("changed")

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
                        
                        self.view.layoutIfNeeded()
                    }
                } else {
                    var newHeight = CGFloat(workPanelPercentage) - verticalDeltaPercentage
                    
                    if newHeight > 1 {
                        let diff = newHeight - 1
                        newHeight = 1 + (diff / 4)
                    }
                    
                    updateWorkPanelForHeight(Float(newHeight))
                    
                    view.layoutIfNeeded()
                }
            }
            
            if let lastLocation = workPanelLastLocation {
                workPanelVerticalSpeed = lastLocation.y - location.y
            }
            
            workPanelLastLocation = location
            
        case .ended:
           //print("ended")
            
            panning = false
            
            if let origin = workPanelSlideOrigin {
                let verticalDelta = location.y - origin.y
                
               //print("verticalDelta: \(verticalDelta)")
                
                let verticalDeltaPercentage = verticalDelta / view.bounds.height
                
               //print("verticalDeltaPercentage: \(verticalDeltaPercentage)")
                
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
           //print("failed")
            panning = false
        case .possible:
           //print("possible")
            break
        }
    }
    
    
    func snapPercentageHeight() {
        snapPercentageHeight(0, viewSize: view.frame.size)
        self.updateWorkPanelForHeight(self.workPanelPercentage)
    }
    
    
    func snapPercentageHeight(_ verticalSpeed: CGFloat, viewSize: CGSize) {
        
       //print("snapPercentageHeight: \(verticalSpeed)")
        
        // Look at the vertical speed to decide what height to snap it to.
        
        // Determine the height of equation as a percentage
        
        let viewHeight = viewHeightWithAd()
        
//        let equationHeightPercentage = 140 / viewHeight
        
        let equationHeightPercentage = 150 / viewHeight
        
        
        workPanelPercentage += Float(verticalSpeed) / Float(viewHeight) * 5
        
        var allowMiddlePosition = true
        
        if NumericalViewHelper.isDevicePad() == false && viewSize.width > viewSize.height {
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
        
        // If the bannerview is present then reduce this percentage by the corrcet amount
        workPanelPercentage *= Float(viewHeightWithAd() / self.view.frame.height)
        
        // Update history view content insets.
        updateHistoryContentInsets(viewSize: viewSize)
    }
    
    
    func pressedKey(_ key: Character, sourceView: UIView?) {
        // A key was pressed. No action required as history view is using a fetched results controller.
    }
    
    
    func unpressedKey(_ key: Character, sourceView: UIView?) {
        
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
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        premiumStatusChanged()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        updateHistoryContentInsets(viewSize: self.view.frame.size)
        
        // Focus the history view on the current equation
        historyView?.focusOnCurrentEquation()
        
        snapPercentageHeight()
        
        premiumStatusChanged()
    }
    
    func viewHeightWithAd() -> CGFloat {
        return self.view.frame.height - effectiveBannerHeight()
    }
    
    func viewHeightWithoutAd() -> CGFloat {
        return self.view.frame.height
    }
    
    
    func effectiveBannerHeight() -> CGFloat {
        if showAd() {
            return bannerView.frame.height + bannerView.frame.origin.y
        }
        return 0
    }
    
    func updateHistoryContentInsets(viewSize: CGSize) {
        
        let equationHeightPercentage = 140 / viewSize.height
        
        let viewHeight = viewSize.height - effectiveBannerHeight()
        
        var bottomInset:CGFloat = viewHeight * CGFloat(workPanelPercentage)
        
        if viewSize.width > viewSize.height {
            bottomInset = viewHeight * CGFloat(equationHeightPercentage)
        } else {
            if workPanelPercentage > 0.5 {
                bottomInset = viewHeight * 0.5
            }
        }
        
        var topHeight:CGFloat = 44.0
        
        if showAd() {
            topHeight += bannerView.frame.height
        }
        
        self.historyView?.updateContentInsets(UIEdgeInsets(top: topHeight, left: 0, bottom: bottomInset + (effectiveBannerHeight() / 2), right: 0))
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
        }
        
        if newHeight < 0 {
            newHeight = 0
        }
        
        // determine the middle float point given this height
        
        let middlePoint = (self.viewHeightWithAd() / self.view.frame.height) / 2
        
        if newHeight > middlePoint {
            self.changeHeightMultipler(CGFloat(newHeight))
            self.workPanelBottomConstraint.constant = 0
        } else {
            self.changeHeightMultipler(CGFloat(middlePoint))
            
            let offset:CGFloat = (CGFloat(newHeight) - middlePoint)
            
            let viewHeight = self.viewHeightWithoutAd()
            
           //print("middlePoint: \(middlePoint)")
           //print("newHeight: \(newHeight)")
           //print("offset: \(offset)")
            
            self.workPanelBottomConstraint.constant = offset * viewHeight
            
           //print("self.workPanelBottomConstraint.constant: \(self.workPanelBottomConstraint.constant)")
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
        
        if let gradiantLayer = self.gradiantLayer {
            gradiantLayer.frame = CGRect(x: 0, y: 0, width: size.width, height: size.height)
        }
        
        super.viewWillTransition(to: size, with: coordinator)
        
        coordinator.animate(alongsideTransition: { (context) -> Void in
            self.snapPercentageHeight(0.0, viewSize: size)
            self.updateKeypad()
            self.view.layoutIfNeeded()
            }) { (context) -> Void in
                self.themeChanged()
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
        return ThemeCoordinator.shared.preferredStatusBarStyleForCurrentTheme()
    }
    
    func showAd() -> Bool {
        return false
        
        if PremiumCoordinator.shared.preventAd {
            return false
        }
        
        if adReadyToDisplay == false {
            return false // We are still loading the first ad.
        }
        
        return PremiumCoordinator.shared.shouldUserSeeAd()
    }
    
    
    
    
}

