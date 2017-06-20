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

class ViewController: NumericalViewController, KeypadDelegate, HistoryViewControllerDelegate, WorkPanelDelegate, UIGestureRecognizerDelegate {
    
    var blurView: UIVisualEffectView?
    
    var historyView: HistoryViewController?
    var workPanelView: WorkPanelViewController?
    //var currentEquation: WorkingEquation?
    
    var currentSize = KeypadSize.maximum
    var workPanelShowEquation = true
    
    var workPanelSlideOrigin:CGPoint?
    var workPanelLastLocation:CGPoint?
    var workPanelVerticalSpeed:CGFloat = 0.0
    
    var workPanelPercentage:Float = 1.0
    let midPoint:CGFloat = 0.66
    
    var workpanelPanning = false
    
    var adReadyToDisplay = false
    
    var gradiantLayer:CAGradientLayer?
    
    var currentStatus = UIStatusBarStyle.default
    
    var panGesture:UIPanGestureRecognizer?
    
    var leftSwipeGesture:UISwipeGestureRecognizer?
    var rightSwipeGesture:UISwipeGestureRecognizer?
    
    var upSwipeGesture:UISwipeGestureRecognizer?
    var downSwipeGesture:UISwipeGestureRecognizer?
    
    
    @IBOutlet weak var shadeView: UIView!
    @IBOutlet weak var shadeViewLeftCorner: UIImageView!
    @IBOutlet weak var shadeViewRightCorner: UIImageView!
    
    @IBOutlet weak var workPanelShadow: UIImageView!
    
    @IBOutlet weak var backgroundImageView: UIImageView!
    
    @IBOutlet weak var workPanelHeight: NSLayoutConstraint!
    
    @IBOutlet weak var workPanelBottomConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var historyViewBottomConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var keypadLeadingConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var historyTrailingConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var testView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor.green
        
        NotificationCenter.default.addObserver(self, selector: #selector(ViewController.themeChanged), name: Notification.Name(rawValue: PremiumCoordinatorNotification.themeChanged), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(ViewController.transparencyChanged), name: NSNotification.Name.UIAccessibilityReduceTransparencyStatusDidChange, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(ViewController.keypadLayoutChanged), name: Notification.Name(rawValue: NumericalHelperSetting.preferHistoryBehind), object: nil)
        
        // preferHistoryBehind
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
        
        
        Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true, block: { (timer) in
//            if let offset = self.workPanelView?.keyPanelView?.currentPageOffset() {
//                print("offset: \(offset)")
//            } else {
//                print("no offset")
//            }
        })
        
        let currentVersion = NumericalHelper.currentDeviceInfo(includeBuildNumber: false)
        
        if let previousVersion = UserDefaults.standard.string(forKey: "CurrentVersion") {
            print("previousVersion: \(previousVersion)")
            print("")
            if (currentVersion > previousVersion && previousVersion < "v2.0.8") {
                // Display a tool tip
                DispatchQueue.main.async {
                    let alertView = UIAlertController(title: "Numerical² has been\nupdated to \(currentVersion)!", message: "You can now access Numerical² using the Today widget! Swipe down to open Notification center, swipe left for Today, then click Edit and add Numerical²  :D It works much the same as the Numerical² Keyboard, which you can enable in Settings.", preferredStyle: UIAlertControllerStyle.alert)
                    
                    alertView.addAction(UIAlertAction(title: "What Else Is New?", style: UIAlertActionStyle.default, handler: { (action) in
                        self.attemptToOpenURL(urlString: "http://www.verytinymachines.com/numerical2-whatsnew/")
                    }))
                    
                    alertView.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.cancel, handler: { (action) in
                        
                    }))
                    
                    alertView.popoverPresentationController?.sourceView = self.view
                    
                    self.present(alertView, animated: true, completion: {
                        
                    })
                }
                
                /*
                DispatchQueue.main.async {
                    let alertView = UIAlertController(title: "Numerical² has been\nupdated to \(currentVersion)!", message: "You can now customise the History List and keyboard! Let's begin.\n\nDo you want your History List...", preferredStyle: UIAlertControllerStyle.alert)
                    
                    alertView.addAction(UIAlertAction(title: "Behind Keypad", style: UIAlertActionStyle.default, handler: { (action) in
                        NumericalHelper.setSetting(string: NumericalHelperSetting.preferHistoryBehind, enabled: true)
                        self.askScientificQuestion()
                    }))
                    
                    if NumericalViewHelper.isDeviceLiterallyPad() {
                        alertView.addAction(UIAlertAction(title: "Left Of Keypad", style: UIAlertActionStyle.default, handler: { (action) in
                            NumericalHelper.setSetting(string: NumericalHelperSetting.preferHistoryBehind, enabled: false)
                            self.askScientificQuestion()
                        }))
                    } else {
                        alertView.addAction(UIAlertAction(title: "Right Of Keypad", style: UIAlertActionStyle.default, handler: { (action) in
                            NumericalHelper.setSetting(string: NumericalHelperSetting.preferHistoryBehind, enabled: false)
                            self.askScientificQuestion()
                        }))
                    }
                    
                    self.present(alertView, animated: true, completion: { 
                        
                    })
                }
                 */
            }
        }
        
        UserDefaults.standard.set(currentVersion, forKey: "CurrentVersion")
    }
    
    func askScientificQuestion() {
        let alertView = UIAlertController(title: "Scientific Keyboard", message: "Do you want to show the Scientific Keypad?\n(You can change this later in Settings)", preferredStyle: UIAlertControllerStyle.alert)
        
        alertView.addAction(UIAlertAction(title: "Yes - Show It", style: UIAlertActionStyle.default, handler: { (action) in
            NumericalHelper.setSetting(string: NumericalHelperSetting.showScientific, enabled: true)
            self.finishUpdateQuestions()
        }))
        
        alertView.addAction(UIAlertAction(title: "No - Hide It", style: UIAlertActionStyle.default, handler: { (action) in
            NumericalHelper.setSetting(string: NumericalHelperSetting.showScientific, enabled: false)
            self.finishUpdateQuestions()
        }))
        
        
        alertView.addAction(UIAlertAction(title: "I Don't Care", style: UIAlertActionStyle.default, handler: { (action) in
            self.finishUpdateQuestions()
        }))
        
        self.present(alertView, animated: true, completion: {
            
        })
    }
    
    func finishUpdateQuestions() {
        self.keypadLayoutChanged()
    }
    
    func keypadLayoutChanged() {
        updateBackgroundVisibility()
        themeChanged()
        
        workPanelView?.updateLayout()
        workPanelView?.updateBlurView()
        workPanelView?.keyPanelView?.setupPageView()
    }
    
    func transparencyChanged() {
        // snapPercentageHeight()
        themeChanged()
    }
    
    
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
            
            if NumericalViewHelper.keypadIsDraggable() == false && NumericalViewHelper.historyBesideKeypadNeeded() {
                let layer = ThemeCoordinator.shared.gradiantLayerForCurrentTheme()
                layer.frame = self.view.frame
                
                self.view.layer.insertSublayer(layer, at: 1) // This puts the layer above the background image
                
                gradiantLayer = layer
                
            } else {
                let layer = ThemeCoordinator.shared.gradiantLayerForCurrentTheme()
                layer.frame = self.view.frame
                
                self.view.layer.insertSublayer(layer, at: 1) // This puts the layer above the background image
                
                gradiantLayer = layer
            }
            
            self.view.backgroundColor = ThemeCoordinator.shared.currentTheme().firstColor
        } else {
            if let gradiantLayer = gradiantLayer {
                gradiantLayer.removeFromSuperlayer()
            }
            
            gradiantLayer = nil
            self.view.backgroundColor = UIColor.black
        }
        
        if NumericalViewHelper.historyBesideKeypadNeeded() {
            // The constraints needs to now put the history and the keypanel next to each other.
            
            //let historyWidth:CGFloat = 300
            var viewWidth = self.view.frame.width
            var historyWidth = viewWidth / 2
            
            if historyWidth > 320 {
                historyWidth = 320
            }
            
            keypadLeadingConstraint.constant = historyWidth
            historyTrailingConstraint.constant = viewWidth - historyWidth
        } else {
            keypadLeadingConstraint.constant = 0
            historyTrailingConstraint.constant = 0
        }
        
        
        
        
        updateBackgroundVisibility()
        
        snapAndUpdate(viewSize: self.view.frame.size)
    }
    
    func updateBackgroundVisibility() {
        updateBackgroundVisibility(height: CGFloat(workPanelPercentage))
    }
    
    
    func updateBackgroundVisibility(height: CGFloat) {
        
        // Does the history view need to be visible, given it's position?
        if NumericalViewHelper.historyBehindKeypadNeeded() || NumericalViewHelper.historyBesideKeypadNeeded() {
            // This device needs to display the history behind it, or next to it
            historyView?.view.isHidden = false
        } else {
            historyView?.view.isHidden = true
        }
        
        
        // Does the keypad need to be moveable?
        if NumericalViewHelper.keypadIsDraggable() {
            workPanelView?.view.layer.cornerRadius = 10.0
        } else {
            workPanelView?.view.layer.cornerRadius = 0.0
        }
        
        
        if NumericalViewHelper.keypadIsDraggable() {
            
            // Height is never quite 1.0 at maximum because we always leave a bit of room for the status bar. As such we should increase height just a little so that the shade and alpha changes are relative to 1.0
            
            var height = height
            
            if statusBarHidden() == false {
                let maximumHeight = (self.view.bounds.height - 20) / self.view.bounds.height // This is the maximum height that we can expect the height to have. This is our "new" 1.0
                height = height / maximumHeight // This normalises height to 1.0 if it is at the maximum expected height
            }
            
            // History view hide at 1.0
            if let historyView = self.historyView {
                let historyAlpha = CGFloat((height * -9) + 9)
                
                if historyView.view.alpha != historyAlpha {
                    historyView.view.alpha = historyAlpha
                }
            }
            
            // Add the drop shadow as needed.
            
            var workPanelAlpha:CGFloat = 0.1
            
            if ThemeCoordinator.shared.styleForCurrentTheme() == ThemeStyle.bright {
                workPanelAlpha = 0.05
            }
            
            if height > 0.9 {
                workPanelAlpha += (height - 0.9)
            }
            
            // override everything
            self.shadeViewLeftCorner.isHidden = false
            self.shadeViewRightCorner.isHidden = false
            self.workPanelShadow.isHidden = false
            
            self.shadeViewLeftCorner.alpha = workPanelAlpha
            self.shadeViewRightCorner.alpha = workPanelAlpha
            self.workPanelShadow.alpha = workPanelAlpha
            
        } else {
            // The keypad isn't draggable, which means it's full screen
            
            self.shadeViewLeftCorner.isHidden = true
            self.shadeViewRightCorner.isHidden = true
            self.workPanelShadow.isHidden = true
            
            self.historyView?.view.alpha = 1.0
        }
        
        updateStatusBarIfNeeded()
    }
    
    func updateStatusBarIfNeeded() {
        if currentStatus != statusBarStyleForHeight() {
            self.setNeedsStatusBarAppearanceUpdate()
            currentStatus = statusBarStyleForHeight()
        }
    }
    
    func selectedEquation(_ equation: Equation) {
        
        if let theWorkView = workPanelView {
            
            if let question = equation.question {
                theWorkView.selectedQuestion(question: question)
            } else {
                theWorkView.selectedQuestion(question: "")
            }
            
            presentKeypad()
        }
    }
    
    func postEquationChangedNotif() {
        DispatchQueue.main.async {
            NotificationCenter.default.post(name: Notification.Name(rawValue: EquationStoreNotification.currentEquationChanged), object: nil)
        }
    }
    
    func presentKeypad() {
        // The user selected an item from the history. Present the keypad IF needed.
        
        if workPanelPercentage == Float(self.minimumEquationHeight() / self.view.frame.height) {
            // The work panel is in the minimum configuration. Raise it
            
            let newHeight = snappedHeight(heightPercentage: 0.7, velocity: 0, viewSize: self.view.frame.size, animated: true)
            
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
            keyPad.updateSelectedEquation()
            
        } else if let keyPad = segue.destination as? WorkPanelViewController {
            workPanelView = keyPad
            keyPad.delegate = self
            keyPad.workPanelDelegate = self
            
            keyPad.updateViews(currentCursor: nil)
            
            // Add a gesture recogniser to the keypad
            let slideGesture = UIPanGestureRecognizer(target: self, action: #selector(ViewController.workPanelPanned(_:)))
            slideGesture.delegate = self
            keyPad.view.addGestureRecognizer(slideGesture)
            panGesture = slideGesture
            
            // Add swipe gesture recogniser (left)
            let undoSwipeGesture = UISwipeGestureRecognizer(target: self, action: #selector(ViewController.swiped(_:)))
            undoSwipeGesture.direction = .left
            undoSwipeGesture.delegate = self
            keyPad.view.addGestureRecognizer(undoSwipeGesture)
            
            leftSwipeGesture = undoSwipeGesture
            
            // Add swipe right gesture recogniser (right)
            let redoSwipeGesture = UISwipeGestureRecognizer(target: self, action: #selector(ViewController.swiped(_:)))
            redoSwipeGesture.direction = .right
            redoSwipeGesture.delegate = self
            keyPad.view.addGestureRecognizer(redoSwipeGesture)
            
            rightSwipeGesture = redoSwipeGesture
            
            // Add the up / down gestures
            
            let clearSwipeGesture = UISwipeGestureRecognizer(target: self, action: #selector(ViewController.swiped(_:)))
            clearSwipeGesture.direction = .up
            clearSwipeGesture.delegate = self
            keyPad.view.addGestureRecognizer(clearSwipeGesture)
            
            upSwipeGesture = clearSwipeGesture
            
            
            let newSwipeGesture = UISwipeGestureRecognizer(target: self, action: #selector(ViewController.swiped(_:)))
            newSwipeGesture.direction = .down
            newSwipeGesture.delegate = self
            keyPad.view.addGestureRecognizer(newSwipeGesture)
            
            downSwipeGesture = newSwipeGesture
            
            
            /*
             var upSwipeGesture:UISwipeGestureRecognizer?
             var downSwipeGesture:UISwipeGestureRecognizer?
             */
            
            
        }
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        
        var swiping = false
        var panning = false
        
        if let _ = gestureRecognizer as? UISwipeGestureRecognizer {
            swiping = true
        }
        
        if let _ = otherGestureRecognizer as? UISwipeGestureRecognizer {
            swiping = true
        }
        
        if let _ = gestureRecognizer as? UIPanGestureRecognizer {
            panning = true
        }
        
        if let _ = otherGestureRecognizer as? UIPanGestureRecognizer {
            panning = true
        }
        
        if swiping && panning {
            return true
        } else {
            return false
        }
    }
    
    func swiped(_ swipeGesture: UISwipeGestureRecognizer) {
        // This swipe only counts if the equation view is at 0, ie, it did not scroll
        
        if let answerView = workPanelView?.equationView?.answerView, let questionView = workPanelView?.equationView?.questionView {
            let locationAnswer = swipeGesture.location(in: answerView.view)
            let locationQuestion = swipeGesture.location(in: questionView.view)
            
            // Check if swiped in answer. The answer view maybe be a collection view but it should never be scrollable so we don't need to check offset.
            
            if answerView.view.frame.contains(locationAnswer) {
                // The swipe's location was inside the answer view
                
                // It's a redo.
                
                if swipeGesture == rightSwipeGesture {
                    // Redo
                    self.redo()
                } else if swipeGesture == leftSwipeGesture {
                    // Undo
                    self.undo()
                } else if swipeGesture == upSwipeGesture {
                    self.swipedUp()
                } else if swipeGesture == downSwipeGesture {
                    self.swipedDown()
                }
            }
            
            if questionView.view.frame.contains(locationQuestion) {
                // The swipe's location was inside the answer view
                
                if swipeGesture == rightSwipeGesture {
                    // Redo
                    
                    if questionView.collecitonView.delegate == nil {
                        // We don't have a collection view so just call redo.
                        self.redo()
                    } else if questionView.collecitonView.frame.width + questionView.collecitonView.contentOffset.x >= questionView.collecitonView.contentSize.width {
                        
                        self.redo()
                    }
                    
                } else if swipeGesture == leftSwipeGesture {
                    // Undo
                    
                    if questionView.collecitonView.delegate == nil {
                        self.undo()
                    } else if questionView.collecitonView.contentOffset.x <= 0 {
                        // The swipe was for a scrollable view that now has a negative content offset
                        // Delete this equation with a small animation.
                        self.undo()
                    }
                }
            }
        }
    }
    
    func undo() {
        if WorkingEquationManager.sharedManager.undo() {
            workPanelView?.undoEquationAnimation()
        } else {
            workPanelView?.undoEquationAnimationFailed()
        }
        
        // We also need to destroy the pangesture since it may still be working.
        self.resetPanGesture()
    }
    
    func redo() {
        if WorkingEquationManager.sharedManager.redo() {
            workPanelView?.redoEquationAnimation()
        } else {
            workPanelView?.redoEquationAnimationFailed()
        }
        
        // We also need to destroy the pangesture since it may still be working.
        self.resetPanGesture()
    }
    
    func swipedUp() {
        if NumericalViewHelper.historyBehindKeypadNeeded() == false {
            // Clear it
            workPanelView?.clearEquationAnimation(forceUp: true)
        }
    }
    
    func swipedDown() {
        if NumericalViewHelper.historyBehindKeypadNeeded() == false {
            // Need to save current item and move the other
            workPanelView?.startNewFromAnswerAnimation()
        }
    }
    
    func resetPanGesture() {
        if let panGesture = panGesture {
            panGesture.isEnabled = false
            panGesture.isEnabled = true
            self.snapAndUpdate(viewSize: self.view.frame.size)
        }
    }
    
    func equationHeight(workPanelHeight: CGFloat, viewSize: CGSize) -> CGFloat {
        let viewHeight = viewSize.height
        let equationHeight = (workPanelHeight * viewHeight) / 3
        
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
    
    // pan gest
    func workPanelPanned(_ sender: UIPanGestureRecognizer) {
       //print("workPanelPanned")
        
        let location = sender.location(in: view)
        
        switch sender.state {
        case .began:
            
            workPanelSlideOrigin = location
            workPanelLastLocation = location
            view.layer.removeAllAnimations()
        case .cancelled:
           
            break
        case .changed:

            // origin is where the touch started.
            // location is where the touch is now.
            
            
            if let origin = workPanelSlideOrigin {
                
                let verticalDelta = location.y - origin.y
                
                let verticalDeltaPercentage = verticalDelta / view.bounds.height
                
                var newHeight = CGFloat(workPanelPercentage) - verticalDeltaPercentage
                
                // We only want to start panning if the workPanel has moved down further than it's moved across and one of those is more than 10 points
                
                
                if workpanelPanning == false {
                    
                    var yDiff = location.y - origin.y
                    
                    if yDiff < 0 {
                        yDiff *= -1
                    }
                    
                    var xDiff = location.x - origin.x
                    
                    if xDiff < 0 {
                        xDiff *= -1
                    }
                    
                    
                    if yDiff > 10 {
                        // We've moved more than 10 points now.
                        if xDiff < 10 {
                            // We have moved mostly vertical, so we should start the pan
                            workpanelPanning = true
                        } else {
                            // This pan has been too horizontal. Kill it!
                            panGesture?.isEnabled = false
                            panGesture?.isEnabled = true
                            return
                        }
                    } else {
                        // Haven't moved enouugh to do anything yet
                        return
                    }
                }
                
                if newHeight > 1 {
                    let diff = newHeight - 1
                    newHeight = 1 + (diff / 4)
                }
                
                self.updateHistoryContentInsets(heightPercentage: newHeight, viewSize: self.view.frame.size)
                self.updateConstraints(heightPercentage: newHeight, viewSize:self.view.frame.size, velocity: 0, animated: false)
            }
            
            if let lastLocation = workPanelLastLocation {
                workPanelVerticalSpeed = lastLocation.y - location.y
            }
            
            workPanelLastLocation = location
            
        case .ended:
           
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
            
            workPanelSlideOrigin = nil
            workPanelLastLocation = nil
            workpanelPanning = false
        case .failed:
            workpanelPanning = false
            workPanelSlideOrigin = nil
            workPanelLastLocation = nil
        case .possible:
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
        
        if NumericalViewHelper.keypadIsDraggable() == false {
            // Override this height pulling
            return 1.0
        }
        
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
        
        if NumericalViewHelper.keypadIsDraggable() == false {
            // Override this height pulling
            heightPercentage = 1.0
        }
        
        // Resize the equation view so that it doesn't try and animate with the rest.
        
        if let workPanelView = workPanelView {
            
            let newEquationHeight = equationHeight(workPanelHeight: heightPercentage, viewSize: viewSize)
            
            if newEquationHeight > 0 {
                workPanelView.equationViewHeightConstraint.constant = newEquationHeight
            }
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
        
        if let cv = self.workPanelView?.equationView?.questionView?.collecitonView {
            if cv.delegate != nil {
                cv.reloadData()
            }
        }
        
        if let cv = self.workPanelView?.equationView?.answerView?.collecitonView {
            if cv.delegate != nil {
                cv.reloadData()
            }
        }
        
        //self.workPanelView?.equationView?.questionView?.collecitonView.reloadData()
        //self.workPanelView?.equationView?.answerView?.collecitonView.reloadData()
        self.view.layoutIfNeeded()
        
        // Update the history view
        
        if NumericalViewHelper.keypadIsDraggable() {
            if ThemeCoordinator.shared.currentTheme().style == .dark {
                self.workPanelView?.view.backgroundColor = UIColor(white: 1.0, alpha: 0.05)
            } else {
                self.workPanelView?.view.backgroundColor = UIColor.clear
            }
            
            self.historyView?.view.clipsToBounds = true
            self.historyViewBottomConstraint.constant = panelSize
            
            panGesture?.isEnabled = true
        } else {
            self.workPanelView?.view.backgroundColor = UIColor.clear
            self.historyViewBottomConstraint.constant = 0
            
            panGesture?.isEnabled = false
        }
        
        // Queue up these constraints to animate.
        self.changeHeightMultipler(newMultiplier)
        self.workPanelBottomConstraint.constant = newBottomConstaint
        
        if animated {
            
            UIView.animate(withDuration: 0.25, delay: 0.0, usingSpringWithDamping: 1.0, initialSpringVelocity: velocity / heightPercentage, options: UIViewAnimationOptions(), animations: { () -> Void in
                self.updateBackgroundVisibility(height: heightPercentage)
                // self.workPanelView?.updateLayout()
                self.view.layoutIfNeeded()
            }, completion: { (complete) -> Void in
                //self.workPanelView?.updateLayout()
                self.view.layoutIfNeeded()
            })
        } else {
            //self.workPanelView?.updateLayout()
            self.updateBackgroundVisibility(height: heightPercentage)
            self.view.layoutIfNeeded()
        }
    }
    
    
    func pressedKey(_ key: Character, sourceView: UIView?) {
        // A key was pressed. No action required as history view is using a fetched results controller.
    }
    
    
    func unpressedKey(_ key: Character, sourceView: UIView?) {
        
    }
    
    
    func updateEquation(_ equation: WorkingEquation?) {
        print("")
        /*
        currentEquation = equation
        
        if let theHistoryView = historyView {
            //theHistoryView.updateSelectedEquation(currentEquation)
            self.postEquationChangedNotif()
        }
         */
    }
    
    func delectedEquation(_ equation: Equation) {
        // todo
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        snapAndUpdate(viewSize: self.view.frame.size)
        
        themeChanged()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        // Focus the history view on the current equation
        //historyView?.focusOnCurrentEquation()
        themeChanged() // Just in case we have rotated in another view.
        processURLIfNeeded()
    }
    
    func processURLIfNeeded() {
        print("processURLIfNeeded()")
        
        if let question = URLHandler.sharedHandler.questionFromURL() {
            
            if let workPanelView = workPanelView {
                workPanelView.newEquation(question: question)
                
                URLHandler.sharedHandler.url = nil
            }
        }
    }
    
    func updateHistoryContentInsets(heightPercentage: CGFloat, viewSize: CGSize) {
        
        /*
        if ThemeCoordinator.shared.blurViewAllowed() || NumericalViewHelper.keypadIsDraggable() {
            
//            var heightPercentage = heightPercentage
//            
//            if heightPercentage > midPoint {
//                heightPercentage = midPoint
//            }
            
            let bottomInset:CGFloat = viewSize.height * CGFloat(heightPercentage) - 50
            
            // self.historyView?.updateContentInsets(UIEdgeInsets(top: 0, left: 0, bottom: bottomInset, right: 0))
            self.historyViewBottomConstraint.constant = bottomInset
            self.view.layoutIfNeeded()
            
        } else {
            self.historyView?.updateContentInsets(UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0))
        }
 */
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
        
        self.historyView?.view.alpha = 0.0
        self.workPanelView?.equationView?.view.alpha = 0.0
        self.workPanelView?.keyPanelView?.view.alpha = 0.0
        
        coordinator.animate(alongsideTransition: { (context) -> Void in
            
            }) { (context) -> Void in
                
                self.snapAndUpdate(viewSize: size)
                self.view.layoutIfNeeded()
                self.themeChanged()
                self.workPanelView?.themeChanged()
                
                UIView.animate(withDuration: 0.2, animations: {
                    self.updateBackgroundVisibility()
                    self.workPanelView?.equationView?.view.alpha = 1.0
                    self.workPanelView?.keyPanelView?.view.alpha = 1.0
                }, completion: { (complete) in
                    
                })
                
        }
    }
    
    
    @IBAction func toggleEditing(_ sender: AnyObject) {
        if let view = historyView {
            view.toggleEditing()
        }
    }
    
    func statusBarStyleForHeight() -> UIStatusBarStyle {
        /*
        if let workPanelHeight = workPanelHeight {
            
            // Find the mid point between the mid point and total height
            let statusBarSwitchPoint = (1.0 + midPoint) / 2
            
            if workPanelHeight.multiplier > statusBarSwitchPoint {
                return UIStatusBarStyle.lightContent
            }
        }
         */
        
        return ThemeCoordinator.shared.preferredStatusBarStyleForCurrentTheme()
    }
    
    override var preferredStatusBarStyle : UIStatusBarStyle {
        return statusBarStyleForHeight()
    }
    
    func showAd() -> Bool {
        return false
        /*
        if PremiumCoordinator.shared.preventAd {
            return false
        }
        
        if adReadyToDisplay == false {
            return false // We are still loading the first ad.
        }
        
        return PremiumCoordinator.shared.shouldUserSeeAd()
         */
    }
}

