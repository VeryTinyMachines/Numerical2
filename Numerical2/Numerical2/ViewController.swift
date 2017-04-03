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
    
    var currentStatus = UIStatusBarStyle.default
    
    @IBOutlet weak var shadeView: UIView!
    @IBOutlet weak var shadeViewLeftCorner: UIImageView!
    @IBOutlet weak var shadeViewRightCorner: UIImageView!
    
    @IBOutlet weak var workPanelShadow: UIImageView!
    
    @IBOutlet weak var bannerView: UIView!
    
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
        
        currentStatus = self.preferredStatusBarStyle
        
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
        updateBackgroundVisibility()
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
    
    func updateBackgroundVisibility() {
        updateBackgroundVisibility(height: CGFloat(workPanelPercentage))
    }
    
    
    func updateBackgroundVisibility(height: CGFloat) {
        
        // Height is never quite 1.0 at maximum because we always leave a bit of room for the status bar. As such we should increase height just a little so that the shade and alpha changes are relative to 1.0
        
        var height = height
        let originalHeight = height
        
        if statusBarHidden() == false {
            let maximumHeight = (self.view.bounds.height - 20) / self.view.bounds.height // This is the maximum height that we can expect the height to have. This is our "new" 1.0
            height = height / maximumHeight // This normalises height to 1.0 if it is at the maximum expected height
        }
        
        self.shadeView.backgroundColor = UIColor.black
        
        var shadeAlpha:CGFloat = 0.0
        shadeAlpha = CGFloat(originalHeight - 0.5)
        if shadeAlpha > 0.5 {
            shadeAlpha = 0.5
        }
        
        if self.shadeView.alpha != shadeAlpha || self.shadeViewLeftCorner.alpha != shadeAlpha || self.shadeViewRightCorner.alpha != shadeAlpha {
            // At least one of the view's has an incorrect alpha, update 'em all!
            self.shadeView.alpha = shadeAlpha
            self.shadeViewLeftCorner.alpha = shadeAlpha
            self.shadeViewRightCorner.alpha = shadeAlpha
        }
        
        // History view hide at 1.0
        if let historyView = self.historyView {
            let historyAlpha = CGFloat((height * -9) + 9)
            
            if historyView.view.alpha != historyAlpha {
                historyView.view.alpha = historyAlpha
                print("self.historyView?.view.alpha: \(self.historyView?.view.alpha)")
            }
        }
        
        // Add the drop shadow as needed.
        var workPanelAlpha = CGFloat((height * -2) + 2)
        if workPanelAlpha > 1.0 {
            workPanelAlpha = 1.0
        }
        workPanelAlpha *= 0.05
        
        if ThemeCoordinator.shared.styleForCurrentTheme() == ThemeStyle.bright {
            
            var workPanelAlpha = CGFloat((height * -2) + 2)
            if workPanelAlpha > 1.0 {
                workPanelAlpha = 1.0
            }
            workPanelAlpha *= 0.05
            
            workPanelShadow.isHidden = false
            if workPanelShadow.alpha != workPanelAlpha {
                workPanelShadow.alpha = workPanelAlpha
            }
        } else {
            workPanelShadow.isHidden = true
        }
        
        updateStatusBarIfNeeded()
    }
    
    func updateStatusBarIfNeeded() {
        print("updateStatusBarIfNeeded:")
        print("\(currentStatus.rawValue) vs \(statusBarStyleForHeight().rawValue)")
        
        if currentStatus != statusBarStyleForHeight() {
            self.setNeedsStatusBarAppearanceUpdate()
            currentStatus = statusBarStyleForHeight()
        }
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
                        updateBackgroundVisibility(height: newHeight)
                        
                        self.view.layoutIfNeeded()
                    }
                } else {
                    var newHeight = CGFloat(workPanelPercentage) - verticalDeltaPercentage
                    
                    if newHeight > 1 {
                        let diff = newHeight - 1
                        newHeight = 1 + (diff / 4)
                    }
                    
                    updateWorkPanelForHeight(Float(newHeight))
                    updateBackgroundVisibility(height: newHeight)
                    
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
                    self.updateBackgroundVisibility(height: CGFloat(self.workPanelPercentage))
                }, completion: { (complete) -> Void in
                    self.updateKeypad()
                    self.updateBackgroundVisibility(height: CGFloat(self.workPanelPercentage))
                    
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
        self.updateBackgroundVisibility(height: CGFloat(self.workPanelPercentage))
    }
    
    
    func snapPercentageHeight(_ verticalSpeed: CGFloat, viewSize: CGSize) {
        
        var totalHeight:Float = 1.0
        
        if statusBarHidden() == false {
            totalHeight = (Float(viewSize.height) - 20) / Float(viewSize.height)  // remove 20 for the status bar section
        }
        
       //print("snapPercentageHeight: \(verticalSpeed)")
        
        // Look at the vertical speed to decide what height to snap it to.
        
        // Determine the height of equation as a percentage
        
        let viewHeight = viewHeightWithAd()
        
//        let equationHeightPercentage = 140 / viewHeight
        
        let equationHeightPercentage = 125 / viewHeight
        
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
                        workPanelPercentage = totalHeight
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
                    workPanelPercentage = totalHeight
                } else {
                    workPanelPercentage = Float(equationHeightPercentage)
                }
            }
            
        } else {
            if allowMiddlePosition {
                // Portrait
                if workPanelPercentage > 0.66 {
                    workPanelPercentage = totalHeight
                } else if workPanelPercentage > 0.33 {
                    workPanelPercentage = 0.5
                } else {
                    workPanelPercentage = Float(equationHeightPercentage)
                }
            } else {
                // Landscape
                if workPanelPercentage > 0.5 {
                    workPanelPercentage = totalHeight
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
        
        themeChanged() // Just in case we have rotated in another view.
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
        
        self.historyView?.updateContentInsets(UIEdgeInsets(top: 0, left: 0, bottom: bottomInset + (effectiveBannerHeight() / 2), right: 0))
    }
    
    func statusBarHidden() -> Bool {
        return UIApplication.shared.isStatusBarHidden
    }
    
    func updateWorkPanelForHeight(_ heightPercentage: Float) {
        
        // Between 1.0 and 0.5 the height shrinks. Below this the height remains the same but the position is offset.
        
        var newHeight = CGFloat(heightPercentage)
        
        //  entirely hide the status bar as it's not longer in this design - TODO
        statusBarBlur.isHidden = true
        
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
            
            self.workPanelBottomConstraint.constant = offset * viewHeight
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
        updateBackgroundVisibility(height: CGFloat(workPanelPercentage))
        
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
    
    func statusBarStyleForHeight() -> UIStatusBarStyle {
        if let workPanelHeight = workPanelHeight {
            if workPanelHeight.multiplier > 0.75 {
                return UIStatusBarStyle.lightContent
            }
        }
        
        return ThemeCoordinator.shared.preferredStatusBarStyleForCurrentTheme()
        
    }
    
    override var preferredStatusBarStyle : UIStatusBarStyle {
        return statusBarStyleForHeight()
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

