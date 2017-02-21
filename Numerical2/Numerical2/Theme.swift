//
//  Theme.swift
//  Numerical2
//
//  Created by Andrew Clark on 22/01/2017.
//  Copyright © 2017 Very Tiny Machines. All rights reserved.
//

import UIKit

public enum ThemeStyle:String {
    case normal = "normal" // Blur layer is light, text is white
    case dark = "dark" // Blue layer is dark, text is white
    case bright = "bright" // Blur layer is bright, foreground elements are black.
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
