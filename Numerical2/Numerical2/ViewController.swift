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
    let midPoint:CGFloat = 0.66
    
    var panning = false
    
    var adReadyToDisplay = false
    
    var gradiantLayer:CAGradientLayer?
    
    var currentStatus = UIStatusBarStyle.default
    
    @IBOutlet weak var shadeView: UIView!
    @IBOutlet weak var shadeViewLeftCorner: UIImageView!
    @IBOutlet weak var shadeViewRightCorner: UIImageView!
    
    @IBOutlet weak var workPanelShadow: UIImageView!
    
    @IBOutlet weak var backgroundImageView: UIImageView!
    
    @IBOutlet weak var workPanelHeight: NSLayoutConstraint!
    
    @IBOutlet weak var workPanelBottomConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var historyViewBottomConstraint: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor.green
        
        NotificationCenter.default.addObserver(self, selector: #selector(ViewController.themeChanged), name: Notification.Name(rawValue: PremiumCoordinatorNotification.themeChanged), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(ViewController.transparencyChanged), name: NSNotification.Name.UIAccessibilityReduceTransparencyStatusDidChange, object: nil)
        
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
        
        /*
        Timer.scheduledTimer(withTimeInterval: 2.0, repeats: false, block: { (timer) in
            
        })
 */
        
        let currentVersion = NumericalHelper.currentDeviceInfo(includeBuildNumber: false)
        
        if let previousVersion = UserDefaults.standard.string(forKey: "CurrentVersion") {
            if currentVersion != previousVersion {
                // Display a tool tip
                DispatchQueue.main.async {
                    let alertView = UIAlertController(title: "Numerical² has been updated!", message: "You can learn about the new features by going to settings and selected What's New. Or tap the button below.", preferredStyle: UIAlertControllerStyle.alert)
                    
                    alertView.addAction(UIAlertAction(title: "What's New", style: UIAlertActionStyle.default, handler: { (action) in
                        self.attemptToOpenURL(urlString: "http://verytinymachines.com/numerical2-whatsnew")
                    }))
                    
                    alertView.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.cancel, handler: { (action) in
                        
                    }))
                    
                    self.present(alertView, animated: true, completion: { 
                        
                    })
                }
            }
        }
        
        UserDefaults.standard.set(currentVersion, forKey: "CurrentVersion")
    }
    
    func transparencyChanged() {
        // snapPercentageHeight()
        themeChanged()
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
        
        if NumericalHelper.isSettingEnabled(string: NumericalHelperSetting.themes) {
            // This is enabled.
            SimpleLogger.appendLog(string: "ViewController.themeChanged()")
            
            self.backgroundImageView.image = nil
            self.backgroundImageView.isHidden = true
            
            self.view.layoutIfNeeded()
            
            if let gradiantLayer = gradiantLayer {
                gradiantLayer.removeFromSuperlayer()
            }
            
            let layer = ThemeCoordinator.shared.gradiantLayerForCurrentTheme()
            layer.frame = self.view.frame
            
            self.view.layer.insertSublayer(layer, at: 1) // This puts the layer above the background image
            
            self.view.backgroundColor = ThemeCoordinator.shared.currentTheme().firstColor
            
            gradiantLayer = layer
            
            
        } else {
            if let gradiantLayer = gradiantLayer {
                gradiantLayer.removeFromSuperlayer()
            }
            
            gradiantLayer = nil
            self.view.backgroundColor = UIColor.black
        }
        
        updateBackgroundVisibility()
    }
    
    func updateBackgroundVisibility() {
        updateBackgroundVisibility(height: CGFloat(workPanelPercentage))
    }
    
    
    func updateBackgroundVisibility(height: CGFloat) {
        print("updateBackgroundVisibilityheight: \(height)")
        
        // Height is never quite 1.0 at maximum because we always leave a bit of room for the status bar. As such we should increase height just a little so that the shade and alpha changes are relative to 1.0
        
        var height = height
        let originalHeight = height
        
        if statusBarHidden() == false {
            let maximumHeight = (self.view.bounds.height - 20) / self.view.bounds.height // This is the maximum height that we can expect the height to have. This is our "new" 1.0
            height = height / maximumHeight // This normalises height to 1.0 if it is at the maximum expected height
        }
        
        self.shadeView.backgroundColor = UIColor.black
        
        var shadeAlpha:CGFloat = 0.0
        shadeAlpha = CGFloat(originalHeight - midPoint) // The maths here is weird but it works for some reason.
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
            
            if ThemeCoordinator.shared.blurViewAllowed() == false {
                self.workPanelShadow.alpha = 0
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
    
    func presentKeypad() {
        // The user selected an item from the history. Present the keypad IF needed.
        
        
        if workPanelPercentage == Float(self.minimumEquationHeight() / self.view.frame.height) {
            let newHeight = snappedHeight(heightPercentage: 0.7, velocity: 0, viewSize: self.view.frame.size, animated: true)
            
            print("newHeight: \(newHeight)")
            
            self.updateHistoryContentInsets(heightPercentage: newHeight, viewSize: self.view.frame.size)
            
            self.updateConstraints(heightPercentage: newHeight, viewSize:self.view.frame.size, velocity: 0, animated: true)
            
            workPanelPercentage = Float(newHeight)
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
    
    
    func equationHeight(workPanelHeight: CGFloat, viewSize: CGSize) -> CGFloat {
        let viewHeight = viewSize.height
        let equationHeight = (workPanelHeight * viewHeight) / 3
        print("equationHeight: \(equationHeight)")
        
        if equationHeight < minimumEquationHeight() {
            return minimumEquationHeight()
        } else if equationHeight > maximumEquationHeight() {
            return maximumEquationHeight()
        } else {
            return equationHeight
        }
    }
    
    func minimumEquationHeight() -> CGFloat {
        return 160
    }
    
    func maximumEquationHeight() -> CGFloat {
        return 240
    }
    
    // pan gesture
    
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
            
            
            if let origin = workPanelSlideOrigin {
                
                let verticalDelta = location.y - origin.y
                
                let verticalDeltaPercentage = verticalDelta / view.bounds.height
                
                var newHeight = CGFloat(workPanelPercentage) - verticalDeltaPercentage
                
                if newHeight > 1 {
                    let diff = newHeight - 1
                    newHeight = 1 + (diff / 4)
                }
                
                self.updateConstraints(heightPercentage: newHeight, viewSize:self.view.frame.size, velocity: 0, animated: false)
            }
            
            if let lastLocation = workPanelLastLocation {
                workPanelVerticalSpeed = lastLocation.y - location.y
            }
            
            workPanelLastLocation = location
            
        case .ended:
           //print("ended")
            
            
            if let origin = workPanelSlideOrigin {
                
                let verticalDelta = location.y - origin.y
                
                let verticalDeltaPercentage = verticalDelta / view.bounds.height
                
                var newHeight = CGFloat(workPanelPercentage) - verticalDeltaPercentage
                
                if newHeight > 1 {
                    let diff = newHeight - 1
                    newHeight = 1 + (diff / 4)
                }
                
                newHeight = snappedHeight(heightPercentage: newHeight, velocity: workPanelVerticalSpeed, viewSize: self.view.frame.size, animated: true)
                
                self.updateHistoryContentInsets(heightPercentage: newHeight, viewSize: self.view.frame.size)
                
                var velocityPercentage = workPanelVerticalSpeed / self.view.frame.height
                
                if velocityPercentage < 0 {
                    velocityPercentage *= -1
                }
                
                self.updateConstraints(heightPercentage: newHeight, viewSize:self.view.frame.size, velocity: velocityPercentage, animated: true)
                
                workPanelPercentage = Float(newHeight)
            }
            
            workPanelVerticalSpeed = 0
            
        case .failed:
           //print("failed")
            panning = false
        case .possible:
           //print("possible")
            break
        }
    }
    
    func snapAndUpdate(viewSize: CGSize) {
        
        let newHeight = snappedHeight(heightPercentage: CGFloat(workPanelPercentage), velocity: 0, viewSize: viewSize, animated: false)
        self.updateConstraints(heightPercentage: newHeight, viewSize:viewSize, velocity: 0, animated: false)
        
        self.updateHistoryContentInsets(heightPercentage: newHeight, viewSize: viewSize)
        
        workPanelPercentage = Float(newHeight)
    }
    
    func allowMiddlePosition(viewSize: CGSize) -> Bool {
        var allowMiddlePosition = true
        
        if NumericalViewHelper.isDevicePad() == false && viewSize.width > viewSize.height {
            // Device is landscape iPhone - don't allow the middle position
            allowMiddlePosition = false
        }
        
        return allowMiddlePosition
    }
    
    func snappedHeight(heightPercentage: CGFloat, velocity: CGFloat, viewSize:CGSize, animated: Bool) -> CGFloat {
        
        // Simulate where the current velocity will "end up" and snap from there.
        var velocity = velocity
        var velocityDistance:CGFloat = 0
        
        for _ in 1...100 {
            velocityDistance += velocity
            velocity *= 0.95
        }
        
        velocityDistance = velocityDistance / viewSize.height
        
        let heightPercentage = heightPercentage + velocityDistance  // determine the height if the velocity died off at 0.95% each frame
        
        var maxHeight = (viewSize.height - 20) / viewSize.height
        
        if self.statusBarHidden() {
            maxHeight = 1
        }
        
        // There are 2 or 3 positions, we need to pick the closet
        
        var positions = [CGFloat:CGFloat]()
        
        let minPoint = minimumEquationHeight() / viewSize.height / 2
        let minPointResult = minimumEquationHeight() / viewSize.height
        
        if self.allowMiddlePosition(viewSize: viewSize) {
            positions[maxHeight] = maxHeight
            positions[midPoint] = midPoint
            positions[minPoint] = minPointResult
        } else {
            positions[maxHeight] = maxHeight
            positions[minPoint] = minPointResult
        }
        
        var currentDistance:CGFloat = 1000
        var newHeight = heightPercentage
        
        // Let's find the closest item in the array
        
        for (pos, result) in positions {
            var distance = heightPercentage - pos
            
            if distance < 0 {
                distance *= -1
            }
            
            if distance < currentDistance {
                // This item is closer!
                newHeight = result
                currentDistance = distance
            }
        }
        
        return newHeight
    }
    
    func updateConstraints(heightPercentage: CGFloat, viewSize:CGSize, velocity: CGFloat, animated: Bool) {
        
        var heightPercentage = heightPercentage
        
        if heightPercentage < 0 {
            heightPercentage = 0
        } else if heightPercentage > 1 {
            heightPercentage = 1
        }
        
        // Resize the equation view so that it doesn't try and animate with the rest.
        
        if let workPanelView = workPanelView {
            
            let newEquationHeight = equationHeight(workPanelHeight: heightPercentage, viewSize: viewSize)
            
            workPanelView.equationViewHeightConstraint.constant = newEquationHeight
        }
        
        var panelSize:CGFloat = 0
        
        var newBottomConstaint:CGFloat = 0
        var newMultiplier:CGFloat = 1.0
        
        if self.allowMiddlePosition(viewSize: viewSize) {
            if heightPercentage > midPoint {
                newMultiplier = heightPercentage
                newBottomConstaint = 0
                
                panelSize = viewSize.height * heightPercentage
                
            } else {
                
                let offset:CGFloat = heightPercentage - midPoint
                
                panelSize = (viewSize.height * heightPercentage) - offset
                
                newMultiplier = midPoint
                newBottomConstaint = offset * viewSize.height
            }
        } else {
            // Landscape mode on iPhone
            
            let offset:CGFloat = heightPercentage - 1.0
            
            panelSize = (viewSize.height * heightPercentage) - offset
            
            newMultiplier = 1.0
            newBottomConstaint = offset * viewSize.height
        }
        
        // Force the equation view to update - this seems to be the only combo that really works and is most efficient and does not result in transform animation errors.
        self.view.layoutIfNeeded()
        self.workPanelView?.equationView?.questionView?.collecitonView.reloadData()
        self.workPanelView?.equationView?.answerView?.collecitonView.reloadData()
        self.view.layoutIfNeeded()
        
        
        // Update the history view
        if ThemeCoordinator.shared.blurViewAllowed() {
            self.workPanelView?.view.backgroundColor = UIColor.clear
            self.historyViewBottomConstraint.constant = 0
        } else {
            self.workPanelView?.view.backgroundColor = UIColor(white: 1.0, alpha: 0.1)
            self.historyViewBottomConstraint.constant = panelSize
        }
        
        // Queue up these constraints to animate.
        self.changeHeightMultipler(newMultiplier)
        self.workPanelBottomConstraint.constant = newBottomConstaint
        
        if animated {
            
            UIView.animate(withDuration: 0.25, delay: 0.0, usingSpringWithDamping: 1.0, initialSpringVelocity: velocity, options: UIViewAnimationOptions(), animations: { () -> Void in
                self.updateBackgroundVisibility(height: heightPercentage)
                // self.workPanelView?.updateLayout()
                self.view.layoutIfNeeded()
            }, completion: { (complete) -> Void in
                self.workPanelView?.updateLayout()
                self.view.layoutIfNeeded()
            })
        } else {
            self.workPanelView?.updateLayout()
            self.updateBackgroundVisibility(height: heightPercentage)
            self.view.layoutIfNeeded()
        }
    }
    
    
    func pressedKey(_ key: Character, sourceView: UIView?) {
        // A key was pressed. No action required as history view is using a fetched results controller.
    }
    
    
    func unpressedKey(_ key: Character, sourceView: UIView?) {
        
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
        
        snapAndUpdate(viewSize: self.view.frame.size)
        
        themeChanged()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        // Focus the history view on the current equation
        historyView?.focusOnCurrentEquation()
        themeChanged() // Just in case we have rotated in another view.
    }
    
    func updateHistoryContentInsets(heightPercentage: CGFloat, viewSize: CGSize) {
        
        if ThemeCoordinator.shared.blurViewAllowed() {
            
            var heightPercentage = heightPercentage
            
            if heightPercentage > midPoint {
                heightPercentage = midPoint
            }
            
            let bottomInset:CGFloat = viewSize.height * CGFloat(heightPercentage)
            
            self.historyView?.updateContentInsets(UIEdgeInsets(top: 0, left: 0, bottom: bottomInset, right: 0))
        } else {
            self.historyView?.updateContentInsets(UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0))
        }
    }
    
    func statusBarHidden() -> Bool {
        return UIApplication.shared.isStatusBarHidden
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
            self.snapAndUpdate(viewSize: size)
            self.view.layoutIfNeeded()
            }) { (context) -> Void in
                self.themeChanged()
        }
    }
    
    
    @IBAction func toggleEditing(_ sender: AnyObject) {
        if let view = historyView {
            view.toggleEditing()
        }
    }
    
    func statusBarStyleForHeight() -> UIStatusBarStyle {
        if let workPanelHeight = workPanelHeight {
            
            // Find the mid point between the mid point and total height
            let statusBarSwitchPoint = (1.0 + midPoint) / 2
            
            if workPanelHeight.multiplier > statusBarSwitchPoint {
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

