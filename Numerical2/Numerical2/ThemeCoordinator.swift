//
//  ThemeCoordinator.swift
//  Numerical2
//
//  Created by Andrew Clark on 28/11/2016.
//  Copyright © 2016 Very Tiny Machines. All rights reserved.
//
import UIKit

class ThemeCoordinator {
    
    var themes = [Theme]()
    var userThemes = [Theme]()
    
    private var theCurrentTheme:Theme?
    
    static let shared = ThemeCoordinator()
    fileprivate init() {
        SimpleLogger.appendLog(string: "ThemeCoordinator.init")
        
        themes.append(Theme(title: "Candy", themeID: "candy001", color1: "fc52ff", color2: "48b1d4", style: ThemeStyle.normal, premium: false))
        themes.append(Theme(title: "Mint", themeID: "green002", color1: "62b849", color2: "3a80cc", style: ThemeStyle.normal, premium: true))
        themes.append(Theme(title: "Lava", themeID: "red001", color1: "b94747", color2: "e10101", style: ThemeStyle.normal, premium: true))
        
        themes.append(Theme(title: "Pink", themeID: "pink001", color1: "fe4c42", color2: "8e1677", style: ThemeStyle.normal, premium: false))
        themes.append(Theme(title: "Orange", themeID: "orange001", color1: "fe952c", color2: "d5415b", style: ThemeStyle.normal, premium: true))
        themes.append(Theme(title: "Purple", themeID: "purple001", color1: "c341fb", color2: "5653d6", style: ThemeStyle.normal, premium: true))
        
        themes.append(Theme(title: "Light Pink", themeID: "lightpink001", color1: "fff2ff", color2: "ff3caa", style: ThemeStyle.bright, premium: false))
        themes.append(Theme(title: "Light Orange", themeID: "lightorange001", color1: "fff2e5", color2: "d5415b", style: ThemeStyle.bright, premium: true))
        themes.append(Theme(title: "Light Purple", themeID: "lightpurple001", color1: "f7e5ff", color2: "5653d6", style: ThemeStyle.bright, premium: true))
        
        themes.append(Theme(title: "Dark", themeID: "dark001", color1: "4a4a4a", color2: "2b2b2b", style: ThemeStyle.dark, premium: true))
        themes.append(Theme(title: "Pitch", themeID: "dark002", color1: "000000", color2: "000000", style: ThemeStyle.dark, premium: true))
        themes.append(Theme(title: "Blue", themeID: "blue001", color1: "4192d4", color2: "161b52", style: ThemeStyle.normal, premium: true))
        
        themes.append(Theme(title: "Ocean", themeID: "water001", color1: "5aaac1", color2: "001d33", style: ThemeStyle.normal, premium: true))
        themes.append(Theme(title: "Sand", themeID: "sand001", color1: "77a9b4", color2: "a77617", style: ThemeStyle.normal, premium: true))
        themes.append(Theme(title: "Cloud", themeID: "cloud001", color1: "315676", color2: "939da5", style: ThemeStyle.normal, premium: true))
        
        themes.append(Theme(title: "Leaves", themeID: "leaves001", color1: "3c6511", color2: "6e8811", style: ThemeStyle.normal, premium: true))
        
        SimpleLogger.appendLog(string: "Setup \(themes.count) themes")
        
        loadThemes()
        
        SimpleLogger.appendLog(string: "Loaded \(userThemes.count) user themes")
        
        // Set the current theme based on the saved ID.
        if let theme = themeForID(themeID: self.currentThemeID()) {
            theCurrentTheme = theme
            self.saveCurrentThemeForKeyboard()
            SimpleLogger.appendLog(string: "Set current theme \(theme.themeID) with ID")
            
        } else {
            theCurrentTheme = ThemeFormatter.defaultTheme()
            self.saveCurrentThemeForKeyboard()
            SimpleLogger.appendLog(string: "Set default theme")
        }
    }
    
    func currentTheme() -> Theme {
        if let theme = theCurrentTheme {
            return theme
        } else {
            let defaultTheme = ThemeFormatter.defaultTheme()
            return defaultTheme
        }
    }
    
    func saveCurrentThemeForKeyboard() {
        
        if let defs = UserDefaults(suiteName: "group.andrewjclark.numericalapp") {
            
            let firstColor = firstColorForCurrentTheme()
            let secondColor = secondColorForCurrentTheme()
            let style = styleForCurrentTheme()
            
            defs.setColor(color: firstColor, forKey: "CurrentTheme.firstColor")
            defs.setColor(color: secondColor, forKey: "CurrentTheme.secondColor")
            
            switch style {
            case .bright:
                defs.set("bright", forKey: "CurrentTheme.style")
            case .dark:
                defs.set("dark", forKey: "CurrentTheme.style")
            case .normal:
                defs.set("normal", forKey: "CurrentTheme.style")
            }
            
            defs.synchronize()
        }
    }
    
    func themeForID(themeID: String) -> Theme? {
        for theme in themes {
            if theme.themeID == themeID {
                return theme
            }
        }
        
        for theme in userThemes {
            if theme.themeID == themeID {
                return theme
            }
        }
        
        SimpleLogger.appendLog(string: "ThemeCoordinator.themeForID could not find theme with ID, returning nil")
        return nil
    }
    
    func changeTheme() {
        // Pick a random theme
        
        let randomIndex = Int(arc4random_uniform(UInt32(themes.count)))
        theCurrentTheme = themes[randomIndex]
        
        postThemeChangedNotification()
    }
    
    func changeTheme(toTheme theme: Theme) {
        theCurrentTheme = theme
        
        UserDefaults.standard.set(theme.themeID, forKey: "CurrentTheme-v2")
        UserDefaults.standard.synchronize()
        
        postThemeChangedNotification()
        self.saveCurrentThemeForKeyboard()
        
        let deadlineTime = DispatchTime.now() + .milliseconds(700)
        DispatchQueue.main.asyncAfter(deadline: deadlineTime) {
            if NumericalHelper.isSettingEnabled(string: NumericalHelperSetting.changeIcon) {
                self.updateAppIcon()
            }
        }
        
        SimpleLogger.appendLog(string: "ThemeCoordinator.changeTheme to \(theme)")
    }
    
    func updateAppIcon() {
        
        if #available(iOS 10.3, *) {
            
            let theme = self.currentTheme()
            
            // Try and change the icon.
            if theme.isUserCreated {
                // Reset the theme
                self.resetAppIcon()
            } else {
                // Change the icon
                
                if let currentIcon = UIApplication.shared.alternateIconName {
                
                    if currentIcon != theme.themeID {
                        UIApplication.shared.setAlternateIconName(theme.themeID, completionHandler: { (error) in
                            print(error?.localizedDescription)
                        })
                    }
                } else {
                    // No current icon. Set it, but only if this isn't candy, since that's the default
                    
                    if theme.themeID != ThemeFormatter.defaultTheme().themeID {
                        UIApplication.shared.setAlternateIconName(theme.themeID, completionHandler: { (error) in
                            print(error?.localizedDescription)
                        })
                    }
                }
            }
            
        } else {
            // Fallback on earlier versions
        }
    }
    
    func resetAppIcon() {
        if #available(iOS 10.3, *) {
            
            if let currentIcon = UIApplication.shared.alternateIconName {
                
                // There is an icon set, reset it but only if it's not the default
                
                if currentIcon != ThemeFormatter.defaultTheme().themeID {
                    UIApplication.shared.setAlternateIconName(nil, completionHandler: { (error) in
                        print(error?.localizedDescription)
                    })
                }
            }
            
        } else {
            // Fallback on earlier versions
        }
    }
    
    func addNewUserTheme(theme: Theme) {
        userThemes.append(theme)
        saveThemes()
    }
    
    func deleteTheme(theme:Theme) {
        
        //print("userThemes: \(userThemes)")
        
        var cleanedThemes = [Theme]()
        
        for userTheme in userThemes {
            if userTheme.themeID != theme.themeID {
                cleanedThemes.append(userTheme)
            }
        }
        
        //print("cleanedThemes: \(cleanedThemes)")
        
        userThemes = cleanedThemes
        
        //print("userThemes: \(userThemes)")
        
        saveThemes()
        resetTheme()
    }
    
    func doesThemeStillExist(theme: Theme) -> Bool {
        for userTheme in userThemes {
            if userTheme.themeID == theme.themeID {
                return true
            }
        }
        
        for systemTheme in themes {
            if systemTheme.themeID == theme.themeID {
                return true
            }
        }
        
        return false
    }
    
    func resetTheme() {
        self.changeTheme(toTheme: ThemeFormatter.defaultTheme())
    }
    
    func loadThemes() {
        if let loadedArray = NSKeyedUnarchiver.unarchiveObject(withFile: themeSaveLocation()) as? [Theme] {
            self.userThemes = loadedArray
        }
    }
    
    func saveThemes() {
        NSKeyedArchiver.archiveRootObject(userThemes, toFile: themeSaveLocation())
    }
    
    func themeSaveLocation() -> String {
        return applicationSupport() + "/userthemes.plist"
    }
    
    
    func applicationSupport() -> String {
        
        let paths = NSSearchPathForDirectoriesInDomains(.applicationSupportDirectory, .userDomainMask, true)
        let applicationSupportPath = paths[0]
        
        if FileManager.default.fileExists(atPath: applicationSupportPath) == false {
            do {
                try FileManager.default.createDirectory(atPath: applicationSupportPath, withIntermediateDirectories: true, attributes: nil)
            } catch {
                print("Error - Could not creation Application Support Directory")
            }
        }
        
        return applicationSupportPath
    }
    
    func postThemeChangedNotification() {
        DispatchQueue.main.async {
            NotificationCenter.default.post(name: Notification.Name(rawValue: PremiumCoordinatorNotification.themeChanged), object: nil)
        }
    }
    
    func visualEffectViewForCurrentTheme() -> UIVisualEffectView? {
        if NumericalHelper.isSettingEnabled(string: NumericalHelperSetting.themes) {
            // This is enabled.
            let theme = currentTheme()
            return visualEffectViewForTheme(theme: theme)
        }
        
        return nil
    }
    
    func visualEffectViewForTheme(theme:Theme) -> UIVisualEffectView? {
        if blurViewAllowed() {
            if theme.style == ThemeStyle.normal {
                // Normal aka light
                return UIVisualEffectView(effect: UIBlurEffect(style: .light))
            } else if theme.style == ThemeStyle.bright {
                // Bright
                return UIVisualEffectView(effect: UIBlurEffect(style: .light))
            } else {
                // Dark
                return UIVisualEffectView(effect: UIBlurEffect(style: .dark))
            }
        }
        
        return nil
    }
    
    func visualEffectViewForStyle(style:ThemeStyle) -> UIVisualEffectView? {
        if blurViewAllowed() {
            if style == ThemeStyle.normal {
                // Normal aka light
                return UIVisualEffectView(effect: UIBlurEffect(style: .light))
            } else if style == ThemeStyle.bright {
                // Bright
                return UIVisualEffectView(effect: UIBlurEffect(style: .light))
            } else {
                // Dark
                return UIVisualEffectView(effect: UIBlurEffect(style: .dark))
            }
        }
        
        return nil
    }
    
    func blurViewAllowed() -> Bool {
        
        return false
        
        if (UIAccessibilityIsReduceTransparencyEnabled()) {
            // transparency is disabled, so blur views are not allowed
            return false
        }
        
        return true
    }
    
    func foregroundColorForCurrentTheme() -> UIColor {
        
        if NumericalHelper.isSettingEnabled(string: NumericalHelperSetting.themes) {
            // This is enabled.
            return ThemeFormatter.foregroundColorForTheme(theme: currentTheme())
        }
        
        return UIColor.white
    }
    
    func preferredStatusBarStyleForCurrentTheme() -> UIStatusBarStyle {
        
        if NumericalHelper.isSettingEnabled(string: NumericalHelperSetting.themes) {
            // This is enabled.
            return ThemeFormatter.preferredStatusBarStyleForTheme(theme: self.currentTheme())
        }
        
        return UIStatusBarStyle.lightContent
    }
    
    func gradiantLayerForCurrentTheme() -> CAGradientLayer {
        let currentTheme = self.currentTheme()
        return ThemeFormatter.gradiantLayerForTheme(theme: currentTheme)
    }
    
    func lightGradiantLayerForCurrentTheme() -> CAGradientLayer {
        let currentTheme = self.currentTheme()
        return ThemeFormatter.brightGradiantLayerForTheme(theme: currentTheme)
    }
    
    func firstColorForCurrentTheme() -> UIColor {
        return self.currentTheme().firstColor
    }
    
    func secondColorForCurrentTheme() -> UIColor {
        return self.currentTheme().secondColor
    }
    
    func styleForCurrentTheme() -> ThemeStyle {
        return self.currentTheme().style
    }
    
    func currentThemeID() -> String {
        
        if let string = UserDefaults.standard.object(forKey: "CurrentTheme-v2") as? String {
            return string
        }
        
        // No current theme picked, return the default.
        return "candy001" 
    }
}


