//
//  ThemeCreatorViewController.swift
//  Numerical2
//
//  Created by Andrew Clark on 12/12/2016.
//  Copyright © 2016 Very Tiny Machines. All rights reserved.
//

import UIKit

class ThemeCreatorViewController:NumericalViewController {
    
    @IBOutlet weak var exampleView: UIView!
    
    @IBOutlet weak var slider1: UISlider!
    
    @IBOutlet weak var slider1Augment: UISlider!
    
    @IBOutlet weak var slider2: UISlider!
    
    @IBOutlet weak var slider2Augment: UISlider!
    
    @IBOutlet weak var keypadImage1: UIImageView! // Statusbar
    
    @IBOutlet weak var keypadImage2: UIImageView! // Keypad
    
    @IBOutlet weak var keypadImage3: UIImageView! // Foreground keypad
    
    @IBOutlet weak var backgroundColorView: UIView!
    
    @IBOutlet weak var styleSelector: UISegmentedControl!
    
    var updateTheme:Theme?
    var gradiantLayer:CAGradientLayer?
    var gradiantLayer2:CAGradientLayer?
    
    var gradiantBlockRunning = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        var items = [UIBarButtonItem]()
        
        let doneButton = UIBarButtonItem(title: "Done", style: UIBarButtonItemStyle.plain, target: self, action: #selector(ThemeCreatorViewController.userPressedDoneButton))
        
        items.append(doneButton)
        
        if updateTheme != nil {
            
            let deleteButton = UIBarButtonItem(title: "Delete", style: UIBarButtonItemStyle.plain, target: self, action: #selector(ThemeCreatorViewController.userPressedDeleteButton))
            
            items.append(deleteButton)
        }
        
        if let updateTheme = updateTheme {
            // Update the sliders
            
            let lightStyle = updateTheme.style == ThemeStyle.bright
            
            let color1 = NumericalHelper.convertOut(color: updateTheme.firstColor, isSecondColor: false, isLightStyle: lightStyle)
            
            let color2 = NumericalHelper.convertOut(color: updateTheme.secondColor, isSecondColor: true, isLightStyle: lightStyle)
            
            slider1.value = color1.number1
            slider1Augment.value = color1.number2
            
            slider2.value = color2.number1
            slider2Augment.value = color2.number2
            
            if updateTheme.style == ThemeStyle.bright {
                styleSelector.selectedSegmentIndex = 1
            }
        }
        
        navigationItem.rightBarButtonItems = items
        
        // Initial Setup
        if let image = self.keypadImage1.image {
            self.keypadImage1.image = image.withRenderingMode(UIImageRenderingMode.alwaysTemplate)
        }
        
        
        if let image = self.keypadImage2.image {
            self.keypadImage2.image = image.withRenderingMode(UIImageRenderingMode.alwaysTemplate)
        }
        
        if let image = self.keypadImage3.image {
            self.keypadImage3.image = image.withRenderingMode(UIImageRenderingMode.alwaysTemplate)
        }
        
        self.backgroundColorView.backgroundColor = UIColor.clear
        
        updateColorsMethod()
    }
    
    func userPressedDeleteButton() {
        if let updateTheme = updateTheme {
            if updateTheme.isUserCreated {
                let alert = UIAlertController(title: "Delete Theme", message: "Are you sure you want to delete this theme?", preferredStyle: UIAlertControllerStyle.alert)
                
                alert.addAction(UIAlertAction(title: "Delete", style: UIAlertActionStyle.destructive, handler: { (action) in
                    
                    ThemeCoordinator.shared.deleteTheme(theme: updateTheme)
                    self.navigationController?.popViewController(animated: true)
                }))
                
                alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: { (action) in
                    
                }))
                
                present(alert, animated: true) {
                    
                }
            }
        }
    }
    
    func userPressedDoneButton() {
        
        if PremiumCoordinator.shared.canEditThemes() {
            var lightStyle = false
            
            if styleSelector.selectedSegmentIndex > 0 {
                lightStyle = true
            }
            
            let slider1ColorAug = NumericalHelper.convertIn(number1: slider1.value, number2: slider1Augment.value, isSecondColor: false, isLightStyle: lightStyle)
            
            let slider2ColorAug = NumericalHelper.convertIn(number1: slider2.value, number2: slider2Augment.value, isSecondColor: true, isLightStyle: lightStyle)
            
            let topColor = slider1ColorAug
            let bottomColor = slider2ColorAug
            
            if let updateTheme = updateTheme {
                
                updateTheme.firstColor = topColor
                updateTheme.secondColor = bottomColor
                updateTheme.style = ThemeStyle.normal
                
                if lightStyle {
                    updateTheme.style = ThemeStyle.bright
                }
                
                ThemeCoordinator.shared.saveThemes() // TODO - This is weird to do here.
                ThemeCoordinator.shared.changeTheme(toTheme: updateTheme)
                
            } else {
                let newTheme = Theme()
                
                newTheme.firstColor = topColor
                newTheme.secondColor = bottomColor
                newTheme.style = ThemeStyle.normal
                newTheme.isUserCreated = true
                newTheme.isPremium = true
                
                if lightStyle {
                    newTheme.style = ThemeStyle.bright
                }
                
                ThemeCoordinator.shared.addNewUserTheme(theme: newTheme)
                ThemeCoordinator.shared.changeTheme(toTheme: newTheme)
            }
            
            self.navigationController?.popViewController(animated: true)
        } else {
            self.presentSalesScreen(type: SalesScreenType.themeCreator)
        }
    }
    
    @IBAction func sliderValueChanged(_ sender: UISlider) {
        updateColors()
    }
    
    @IBAction func styleSelectorValueChanged(_ sender: UISegmentedControl) {
        updateColors()
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        updateColors()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        updateColors()
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        coordinator.animate(alongsideTransition: { (context) in
            self.updateColors()
        }) { (context) in
            self.updateColors()
        }
    }
    
    func currentSliderState() -> String {
        return "\(slider1.value) \(slider2.value) \(slider1Augment.value) \(slider2Augment.value)"
    }
    
    func updateColors() {
        
        let sliderState = currentSliderState()
        
        if self.gradiantBlockRunning == false {
            self.gradiantBlockRunning = true
            
            DispatchQueue.global(qos: DispatchQoS.QoSClass.background).async {
                
                //print("gradiantQueue.async")
                
                let slider1Color = self.color(float: self.slider1.value)
                
                var lightStyle = false
                
                if self.styleSelector.selectedSegmentIndex > 0 {
                    lightStyle = true
                }
                
                let slider1ColorAug = NumericalHelper.convertIn(number1: self.slider1.value, number2: self.slider1Augment.value, isSecondColor: false, isLightStyle: lightStyle)
                
                let slider2Color = self.color(float: self.slider2.value)
                
                let slider2ColorAug = NumericalHelper.convertIn(number1: self.slider2.value, number2: self.slider2Augment.value, isSecondColor: true, isLightStyle: lightStyle)
                
                let topColor = slider1ColorAug
                var bottomColor = slider2ColorAug
                var foregroundColor = UIColor.white
                
                if lightStyle {
                    // Bright style
                    foregroundColor = bottomColor
                    bottomColor = topColor
                }
                
                let layer = self.layer(color1: topColor, color2: bottomColor)
                let size = self.exampleView.frame.size
                layer.frame = CGRect(x: 0, y: 0, width: size.width, height: size.height)
                
                let layer2 = self.layer(color1: topColor, color2: bottomColor)
                let size2 = self.view.frame.size
                layer2.frame = CGRect(x: 0, y: 0, width: size2.width, height: size2.height)
                
                DispatchQueue.main.async {
                    
                    self.gradiantLayer?.removeFromSuperlayer()
                    
                    self.slider1.thumbTintColor = slider1Color
                    self.slider1.minimumTrackTintColor = slider1Color
                    
                    self.slider1Augment.thumbTintColor = slider1ColorAug
                    self.slider1Augment.minimumTrackTintColor = slider1ColorAug
                    
                    self.slider2.thumbTintColor = slider2Color
                    self.slider2.minimumTrackTintColor = slider2Color
                    
                    self.slider2Augment.thumbTintColor = slider2ColorAug
                    self.slider2Augment.minimumTrackTintColor = slider2ColorAug
                    
                    
                    self.exampleView.layer.insertSublayer(layer, at: 0)
                    self.exampleView.backgroundColor = UIColor.clear
                    
                    self.gradiantLayer = layer
                    
                    // Update Gradiant background
                    
                    self.gradiantLayer2?.removeFromSuperlayer()
                    
                    self.backgroundColorView.layer.insertSublayer(layer2, at: 0)
                    
                    self.gradiantLayer2 = layer2
                    
                    self.backgroundColorView.alpha = 0.5
                    self.view.backgroundColor = UIColor.black
                    
                    self.keypadImage1.alpha = 1.0
                    self.keypadImage2.alpha = 1.0
                    self.keypadImage3.alpha = 0.25
                    
                    // Set the foreground elements
                    self.styleSelector.tintColor = UIColor.white
                    
                    if lightStyle {
                        self.keypadImage1.tintColor = UIColor.black
                    } else {
                        self.keypadImage1.tintColor = UIColor.white
                    }
                    
                    self.keypadImage2.tintColor = foregroundColor
                    self.keypadImage3.tintColor = foregroundColor
                    
                    // Update the status bar
                    
                    self.navigationController?.navigationBar.barTintColor = slider1ColorAug
                    
                    self.navigationController?.navigationBar.tintColor = foregroundColor
                    self.navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName:foregroundColor]
                    
                    self.gradiantBlockRunning = false
                    
                    if sliderState != self.currentSliderState() {
                        // The slider state has changed, call update again.
                        self.updateColors()
                    }
                }
            }
        }
        
        self.setNeedsStatusBarAppearanceUpdate()
    }
    
    func updateColorsMethod() {
        
        // TODO - This is dumb as hell, consolidate these methods.
        
        let slider1Color = self.color(float: self.slider1.value)
        
        var lightStyle = false
        
        if self.styleSelector.selectedSegmentIndex > 0 {
            lightStyle = true
        }
        
        let slider1ColorAug = NumericalHelper.convertIn(number1: self.slider1.value, number2: self.slider1Augment.value, isSecondColor: false, isLightStyle: lightStyle)
        
        let slider2Color = self.color(float: self.slider2.value)
        
        let slider2ColorAug = NumericalHelper.convertIn(number1: self.slider2.value, number2: self.slider2Augment.value, isSecondColor: true, isLightStyle: lightStyle)
        
        let topColor = slider1ColorAug
        var bottomColor = slider2ColorAug
        var foregroundColor = UIColor.white
        
        if lightStyle {
            // Bright style
            foregroundColor = bottomColor
            bottomColor = topColor
        }
        
        let layer = self.layer(color1: topColor, color2: bottomColor)
        let size = self.exampleView.frame.size
        layer.frame = CGRect(x: 0, y: 0, width: size.width, height: size.height)
        
        let layer2 = self.layer(color1: topColor, color2: bottomColor)
        let size2 = self.view.frame.size
        layer2.frame = CGRect(x: 0, y: 0, width: size2.width, height: size2.height)
        
        
        self.gradiantLayer?.removeFromSuperlayer()
        
        self.slider1.thumbTintColor = slider1Color
        self.slider1.minimumTrackTintColor = slider1Color
        
        self.slider1Augment.thumbTintColor = slider1ColorAug
        self.slider1Augment.minimumTrackTintColor = slider1ColorAug
        
        self.slider2.thumbTintColor = slider2Color
        self.slider2.minimumTrackTintColor = slider2Color
        
        self.slider2Augment.thumbTintColor = slider2ColorAug
        self.slider2Augment.minimumTrackTintColor = slider2ColorAug
        
        
        self.exampleView.layer.insertSublayer(layer, at: 0)
        self.exampleView.backgroundColor = UIColor.clear
        
        self.gradiantLayer = layer
        
        // Update Gradiant background
        
        self.gradiantLayer2?.removeFromSuperlayer()
        
        self.backgroundColorView.layer.insertSublayer(layer2, at: 0)
        
        
        self.gradiantLayer2 = layer2
        
        self.backgroundColorView.alpha = 0.5
        self.view.backgroundColor = UIColor.black
        
        self.keypadImage1.alpha = 1.0
        self.keypadImage2.alpha = 1.0
        self.keypadImage3.alpha = 0.25
        
        // Set the foreground elements
        self.styleSelector.tintColor = UIColor.white
        
        if lightStyle {
            self.keypadImage1.tintColor = UIColor.black
        } else {
            self.keypadImage1.tintColor = UIColor.white
        }
        
        self.keypadImage2.tintColor = foregroundColor
        self.keypadImage3.tintColor = foregroundColor
        
        // Update the status bar
        
        self.navigationController?.navigationBar.barTintColor = slider1ColorAug
        
        self.navigationController?.navigationBar.tintColor = foregroundColor
        self.navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName:foregroundColor]
        
        self.gradiantBlockRunning = false
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        if let styleSelector = styleSelector {
            if styleSelector.selectedSegmentIndex == 0 {
                // Default - light
                return UIStatusBarStyle.lightContent
            } else {
                return UIStatusBarStyle.default
            }
        }
        
        return UIStatusBarStyle.lightContent
    }
    
    func layer(color1: UIColor, color2: UIColor) -> CAGradientLayer {
        
        let layer = CAGradientLayer()
        
        let color0 = color1
        let color1 = color2
        
        layer.colors = [color0.cgColor, color1.cgColor]
        
        layer.startPoint = CGPoint(x: 0, y: 0)
        layer.endPoint = CGPoint(x: 0, y: 1)
        
        return layer
    }
    
    func color(float: Float) -> UIColor {
        return UIColor(hue: CGFloat(float), saturation:1.0, brightness:1.0, alpha:1.0)
    }
    
}
