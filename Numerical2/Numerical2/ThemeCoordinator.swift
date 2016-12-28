//
//  ThemeCoordinator.swift
//  Numerical2
//
//  Created by Andrew Clark on 28/11/2016.
//  Copyright © 2016 Very Tiny Machines. All rights reserved.
//
import UIKit

public enum ThemeStyle:String {
    case normal = "normal" // Blur layer is light, text is white
    case dark = "dark" // Blue layer is dark, text is white
    case bright = "bright" // Blur layer is bright, foreground elements are black.
}

class ThemeCoordinator {
    
    var themes = [Theme]()
    var userThemes = [Theme]()
    
    private var theCurrentTheme:Theme?
    
//    let defaultTheme = Theme(title: "Pink", themeID: "pink001", color1: "fe4c42", color2: "8e1677", style: ThemeStyle.bright)
    
    let defaultTheme = Theme(title: "Pink", themeID: "pink001", color1: "fe4c42", color2: "8e1677", style: ThemeStyle.normal, premium: false)
    
    static let shared = ThemeCoordinator()
    fileprivate init() {
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
        themes.append(Theme(title: "Mint", themeID: "green002", color1: "62b849", color2: "3a80cc", style: ThemeStyle.normal, premium: true))
        themes.append(Theme(title: "Red", themeID: "red001", color1: "b94747", color2: "e10101", style: ThemeStyle.normal, premium: true))
        themes.append(Theme(title: "Leaves", themeID: "leaves001", color1: "3c6511", color2: "6e8811", style: ThemeStyle.normal, premium: true))
        
        loadThemes()
        
        // Set the current theme based on the saved ID.
        if let theme = themeForID(themeID: self.currentThemeID()) {
            if theme.isPremium && PremiumCoordinator.shared.canAccessThemes() == false {
                self.changeTheme(toTheme: defaultTheme)
            } else {
                theCurrentTheme = theme
            }
            
        } else {
            theCurrentTheme = defaultTheme
        }
    }
    
    func currentTheme() -> Theme {
        if let theme = theCurrentTheme {
            return theme
        } else {
            return defaultTheme
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
        NSUbiquitousKeyValueStore.default().set(theme.themeID, forKey: "CurrentTheme")
        NSUbiquitousKeyValueStore.default().synchronize()
        postThemeChangedNotification()
    }
    
    func addNewUserTheme(theme: Theme) {
        userThemes.append(theme)
        saveThemes()
    }
    
    func deleteTheme(theme:Theme) {
        
        print("userThemes: \(userThemes)")
        
        var cleanedThemes = [Theme]()
        
        for userTheme in userThemes {
            if userTheme.themeID != theme.themeID {
                cleanedThemes.append(userTheme)
            }
        }
        
        print("cleanedThemes: \(cleanedThemes)")
        
        userThemes = cleanedThemes
        
        print("userThemes: \(userThemes)")
        
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
        self.changeTheme(toTheme: defaultTheme)
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
    
    func visualEffectViewForCurrentTheme() -> UIVisualEffectView {
        if currentTheme().style == ThemeStyle.normal {
            // Normal aka light
            return UIVisualEffectView(effect: UIBlurEffect(style: .light))
        } else if currentTheme().style == ThemeStyle.bright {
            // Bright
            return UIVisualEffectView(effect: UIBlurEffect(style: .light))
        } else {
            // Dark
            return UIVisualEffectView(effect: UIBlurEffect(style: .dark))
        }
    }
    
    func foregroundColorForCurrentTheme() -> UIColor {
        
        return foregroundColorForTheme(theme: currentTheme())
        
//        if currentTheme().style == ThemeStyle.normal {
//            // Normal aka light
//            return UIColor.white
//        } else if currentTheme().style == ThemeStyle.bright {
//            // Bright
//            return currentTheme().secondColor
//        } else {
//            // Dark
//            return UIColor.white
//        }
    }
    
    func foregroundColorForTheme(theme: Theme) -> UIColor {
        if theme.style == ThemeStyle.normal {
            // Normal aka light
            return UIColor.white
        } else if theme.style == ThemeStyle.bright {
            // Bright
            return theme.secondColor
        } else {
            // Dark
            return UIColor.white
        }
    }
    
    func preferredStatusBarStyleForCurrentTheme() -> UIStatusBarStyle {
        return preferredStatusBarStyleForTheme(theme: self.currentTheme())
    }
    
    func preferredStatusBarStyleForTheme(theme: Theme) -> UIStatusBarStyle {
        if theme.style == ThemeStyle.normal {
            // Normal
            return UIStatusBarStyle.lightContent
        } else if theme.style == ThemeStyle.bright {
            // Bright
            return UIStatusBarStyle.default
        } else {
            // Dark
            return UIStatusBarStyle.lightContent
        }
    }
    
    func gradiantLayerForCurrentTheme() -> CAGradientLayer {
        
        let currentTheme = ThemeCoordinator.shared.currentTheme()
        
        return gradiantLayerForTheme(theme: currentTheme)
    }
    
    func gradiantLayerForTheme(theme: Theme) -> CAGradientLayer {
        
        let layer = CAGradientLayer()
        
        let color0 = theme.firstColor
        let color1 = theme.secondColor
        
        if theme.style == ThemeStyle.bright {
            // Bright theme (only use color 0)
            layer.colors = [color0.cgColor, color0.cgColor]
        } else {
            layer.colors = [color0.cgColor, color1.cgColor]
        }
        
        layer.startPoint = CGPoint(x: 0, y: 0)
        layer.endPoint = CGPoint(x: 0, y: 1)
        
        return layer
    }
    
    func currentThemeID() -> String {
        if let string =  NSUbiquitousKeyValueStore.default().object(forKey: "CurrentTheme") as? String {
            return string
        }
        
        // No current theme picked, return the default.
        return "pink001"
    }
}

class Theme: NSObject, NSCoding {
    var themeID = ""
    var title = ""
    var style = ThemeStyle.normal
    var isPremium = false
    var isUserCreated = false
    
    var firstColor = UIColor(red: 1.0, green: 0.0, blue: 0.0, alpha: 1.0)
    var secondColor = UIColor(red: 0.0, green: 1.0, blue: 0.0, alpha: 1.0)
    
    override init() {
        themeID = UUID().uuidString
    }
    
    init(title: String, themeID: String, color1: String, color2: String, style: ThemeStyle, premium: Bool) {
        self.title = title
        self.themeID = themeID
        self.style = style
        self.firstColor = UIColor(hexString: color1)
        self.secondColor = UIColor(hexString: color2)
        self.isPremium = premium
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(themeID, forKey: "themeID")
        aCoder.encode(title, forKey: "title")
        aCoder.encode(style.rawValue, forKey: "style")
        aCoder.encode(isPremium, forKey: "isPremium")
        aCoder.encode(isUserCreated, forKey: "isUserCreated")
        aCoder.encode(firstColor, forKey: "firstColor")
        aCoder.encode(secondColor, forKey: "secondColor")
    }
    
    required init?(coder aDecoder: NSCoder) {
        
        if let obj = aDecoder.decodeObject(forKey: "themeID") as? String {
            self.themeID = obj
        }
        
        if let obj = aDecoder.decodeObject(forKey: "title") as? String {
            self.title = obj
        }
        
        if let obj = aDecoder.decodeObject(forKey: "style") as? String {
            
            if let styleObj = ThemeStyle(rawValue: obj) {
                self.style = styleObj
            }
        }
        
        self.isPremium = aDecoder.decodeBool(forKey: "isPremium")
        
        self.isUserCreated = aDecoder.decodeBool(forKey: "isUserCreated")
        
        if let obj = aDecoder.decodeObject(forKey: "firstColor") as? UIColor {
            self.firstColor = obj
        }
        
        if let obj = aDecoder.decodeObject(forKey: "secondColor") as? UIColor {
            self.secondColor = obj
        }
    }
}
