//
//  ThemeCoordinator.swift
//  Numerical2
//
//  Created by Andrew Clark on 28/11/2016.
//  Copyright © 2016 Very Tiny Machines. All rights reserved.
//
import UIKit

public enum ThemeStyle {
    case normal // Blur layer is light, text is white
    case dark // Blue layer is dark, text is white
    case bright // Blur layer is bright, foreground elements are black.
}

class ThemeCoordinator {
    
    var themes = [Theme]()
    
    private var theCurrentTheme:Theme?
    
//    let defaultTheme = Theme(title: "Pink", themeID: "pink001", color1: "fe4c42", color2: "8e1677", style: ThemeStyle.bright)
    
    let defaultTheme = Theme(title: "Light Pink", themeID: "pink001", color1: "fff0f0", color2: "ff0000", style: ThemeStyle.bright)
    
    static let shared = ThemeCoordinator()
    fileprivate init() {
        themes.append(Theme(title: "Light Pink", themeID: "pink001", color1: "fbceff", color2: "8e1677", style: ThemeStyle.bright))
//        themes.append(Theme(title: "Pink", themeID: "pink001", color1: "fe4c42", color2: "8e1677", style: ThemeStyle.bright))
//        themes.append(Theme(title: "Orange", themeID: "orange001", color1: "fe952c", color2: "d5415b", style: ThemeStyle.bright))
//        themes.append(Theme(title: "Purple", themeID: "purple001", color1: "c341fb", color2: "5653d6", style: ThemeStyle.bright))
        themes.append(Theme(title: "Dark", themeID: "dark001", color1: "4a4a4a", color2: "2b2b2b", style: ThemeStyle.dark))
//        themes.append(Theme(title: "Pitch Black", themeID: "dark002", color1: "000000", color2: "000000", style: ThemeStyle.dark))
//        themes.append(Theme(title: "Blue", themeID: "blue001", color1: "4192d4", color2: "161b52", style: ThemeStyle.normal))
//        themes.append(Theme(title: "Ocean", themeID: "water001", color1: "5aaac1", color2: "001d33", style: ThemeStyle.normal))
//        themes.append(Theme(title: "Sand", themeID: "sand001", color1: "77a9b4", color2: "a77617", style: ThemeStyle.normal))
//        themes.append(Theme(title: "Cloud", themeID: "cloud001", color1: "315676", color2: "939da5", style: ThemeStyle.normal))
//        themes.append(Theme(title: "Mint", themeID: "green002", color1: "62b849", color2: "3a80cc", style: ThemeStyle.normal))
//        themes.append(Theme(title: "Red", themeID: "red001", color1: "b94747", color2: "e10101", style: ThemeStyle.normal))
//        themes.append(Theme(title: "Leaves", themeID: "leaves001", color1: "3c6511", color2: "6e8811", style: ThemeStyle.normal))
    }
    
    func currentTheme() -> Theme {
        if let theme = theCurrentTheme {
            return theme
        } else {
            return defaultTheme
        }
    }
    
    func changeTheme() {
        // Pick a random theme
        
        let randomIndex = Int(arc4random_uniform(UInt32(themes.count)))
        theCurrentTheme = themes[randomIndex]
        
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
        
        if currentTheme().style == ThemeStyle.normal {
            // Normal aka light
            return UIColor.white
        } else if currentTheme().style == ThemeStyle.bright {
            // Bright
            return currentTheme().secondColor
        } else {
            // Dark
            return UIColor.white
        }
    }
    
    func preferredStatusBarStyleForCurrentTheme() -> UIStatusBarStyle {
        if currentTheme().style == ThemeStyle.normal {
            // Normal
            return UIStatusBarStyle.lightContent
        } else if currentTheme().style == ThemeStyle.bright {
            // Bright
            return UIStatusBarStyle.default
        } else {
            // Dark
            return UIStatusBarStyle.lightContent
        }
    }
    
    func gradiantLayerForCurrentTheme() -> CAGradientLayer {
        let layer = CAGradientLayer()
        
        let currentTheme = ThemeCoordinator.shared.currentTheme()
        
        let color0 = currentTheme.firstColor
        let color1 = currentTheme.secondColor
        
        if currentTheme.style == ThemeStyle.bright {
            // Bright theme (only use color 0)
            layer.colors = [color0.cgColor]
        } else {
            layer.colors = [color0.cgColor, color1.cgColor]
        }
        
        layer.startPoint = CGPoint(x: 0, y: 0)
        layer.endPoint = CGPoint(x: 0, y: 1)
        
        return layer
    }
}

class Theme {
    var themeID = ""
    var title = ""
    var style = ThemeStyle.normal
    
    var firstColor = UIColor(red: 1.0, green: 0.0, blue: 0.0, alpha: 1.0)
    var secondColor = UIColor(red: 0.0, green: 1.0, blue: 0.0, alpha: 1.0)
    
    init() {
        
    }
    
    init(title: String, themeID: String, color1: String, color2: String, style: ThemeStyle) {
        self.title = title
        self.themeID = themeID
        self.style = style
        self.firstColor = UIColor(hexString: color1)
        self.secondColor = UIColor(hexString: color2)
    }
}



extension UIColor {
    convenience init(hexString:String) {
        let hexString = hexString.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        
        let scanner = Scanner(string: hexString)
        
        if (hexString.hasPrefix("#")) {
        scanner.scanLocation = 1
        }
        
        var color:UInt32 = 0
        scanner.scanHexInt32(&color)
        
        let mask = 0x000000FF
        let r = Int(color >> 16) & mask
        let g = Int(color >> 8) & mask
        let b = Int(color) & mask
        
        let red   = CGFloat(r) / 255.0
        let green = CGFloat(g) / 255.0
        let blue  = CGFloat(b) / 255.0
        
        self.init(red:red, green:green, blue:blue, alpha:1)
    }
    
    func toHexString() -> String {
        var r:CGFloat = 0
        var g:CGFloat = 0
        var b:CGFloat = 0
        var a:CGFloat = 0
        
        getRed(&r, green: &g, blue: &b, alpha: &a)
        
        let rgb:Int = (Int)(r*255)<<16 | (Int)(g*255)<<8 | (Int)(b*255)<<0
        
        return NSString(format:"#%06x", rgb) as String
    }
    
    func hue() -> Float {
        
        var hue : CGFloat = 0
        var saturation : CGFloat = 0
        var brightness : CGFloat = 0
        var alpha : CGFloat = 0
        
        
        if getHue(&hue, saturation: &saturation, brightness: &brightness, alpha: &alpha) {
            return Float(hue)
        }
        
        return 0
    }
}
