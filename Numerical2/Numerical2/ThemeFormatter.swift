//
//  ThemeFormatter.swift
//  Numerical2
//
//  Created by Andrew Clark on 22/01/2017.
//  Copyright © 2017 Very Tiny Machines. All rights reserved.
//

import UIKit

class ThemeFormatter {
    
    class func defaultTheme() -> Theme {
        // return Theme(title: "Pink", themeID: "pink001", color1: "fe4c42",  color2: "8e1677", style: ThemeStyle.normal, premium: false) // pink
        
        return Theme(title: "Candy", themeID: "candy001", color1: "fc52ff", color2: "48b1d4", style: ThemeStyle.normal, premium: false)
    }
    
    class func foregroundColorForTheme(theme: Theme) -> UIColor {
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
    
    class func foregroundColorFor(firstColor: UIColor, secondColor: UIColor, style: ThemeStyle) -> UIColor {
        if style == ThemeStyle.normal {
            // Normal aka light
            return UIColor.white
        } else if style == ThemeStyle.bright {
            // Bright
            return secondColor
        } else {
            // Dark
            return UIColor.white
        }
    }
    
    class func preferredStatusBarStyleForTheme(theme: Theme) -> UIStatusBarStyle {
        return preferredStatusBarStyleFor(style: theme.style)
    }
    
    class func preferredStatusBarStyleFor(style: ThemeStyle) -> UIStatusBarStyle {
        if style == ThemeStyle.normal {
            // Normal
            return UIStatusBarStyle.lightContent
        } else if style == ThemeStyle.bright {
            // Bright
            return UIStatusBarStyle.default
        } else {
            // Dark
            return UIStatusBarStyle.lightContent
        }
    }
    
    
    class func brightGradiantLayerForTheme(theme: Theme) -> CAGradientLayer {
        return brightGradiantLayerFor(firstColor: theme.firstColor, secondColor: theme.secondColor, style: theme.style)
    }
    
    class func gradiantLayerForTheme(theme: Theme) -> CAGradientLayer {
        return gradiantLayerFor(firstColor: theme.firstColor, secondColor: theme.secondColor, style: theme.style)
    }
    
    
    class func brightGradiantLayerFor(firstColor: UIColor, secondColor: UIColor, style: ThemeStyle) -> CAGradientLayer {
        
        var firstColor = firstColor
        var secondColor = secondColor
        
        if style == .normal {
            firstColor = firstColor.lighterColor
            secondColor = secondColor.lighterColor
        }
        
        return gradiantLayerFor(firstColor: firstColor, secondColor: secondColor, style: style)
    }
    
    class func gradiantLayerFor(firstColor: UIColor, secondColor: UIColor, style: ThemeStyle) -> CAGradientLayer {
        
        let layer = CAGradientLayer()
        
        let color0 = firstColor
        let color1 = secondColor
        
        if style == ThemeStyle.bright {
            // Bright theme (only use color 0)
            layer.colors = [color0.cgColor, color0.cgColor]
        } else {
            layer.colors = [color0.cgColor, color1.cgColor]
        }
        
        layer.startPoint = CGPoint(x: 0, y: 0)
        layer.endPoint = CGPoint(x: 0, y: 1)
        
        return layer
    }
    
}

extension UIColor {
    
    var lighterColor: UIColor {
        
        var h: CGFloat = 0, s: CGFloat = 0
        var b: CGFloat = 0, a: CGFloat = 0
        
        guard getHue(&h, saturation: &s, brightness: &b, alpha: &a)
            else {return self}
        
        if b < 0 {
            b = 0
        }
        
        //b *= 1.4
        //s *= 0.8
        
        b *= 1.4
        s *= 0.90
        
        if b > 1.0 {
            b = 1.0
        }
        
        return UIColor(hue: h,
                       saturation: s,
                       brightness: b,
                       alpha: 1.0)
        
        
        //return lighterColor(removeSaturation: 0.2, resultAlpha: 0)
    }
    
    var slightlyLighterColor: UIColor {
        
        var h: CGFloat = 0, s: CGFloat = 0
        var b: CGFloat = 0, a: CGFloat = 0
        
        guard getHue(&h, saturation: &s, brightness: &b, alpha: &a)
            else {return self}
        
        if b < 0 {
            b = 0
        }
        
        // b *= 1.5
        b *= 1.1
        //b += 0.2
        s *= 0.9
        
        if b > 1.0 {
            b = 1.0
        }
        
        return UIColor(hue: h,
                       saturation: s,
                       brightness: b,
                       alpha: 1.0)
        
        
        //return lighterColor(removeSaturation: 0.2, resultAlpha: 0)
    }
    
    func lighterColor(removeSaturation val: CGFloat, resultAlpha alpha: CGFloat) -> UIColor {
        var h: CGFloat = 0, s: CGFloat = 0
        var b: CGFloat = 0, a: CGFloat = 0
        
        guard getHue(&h, saturation: &s, brightness: &b, alpha: &a)
            else {return self}
        
        return UIColor(hue: h,
                       saturation: max(s - val, 0.0),
                       brightness: b,
                       alpha: 1.0)
    }
}
