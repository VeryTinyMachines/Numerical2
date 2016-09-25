//
//  NumericalTheme.swift
//  Numerical2
//
//  Created by Andrew J Clark on 24/09/2016.
//  Copyright © 2016 Very Tiny Machines. All rights reserved.
//

import UIKit

public struct PremiumCoordinatorNotification {
    public static let themeChanged = "PremiumCoordinatorNotification.themeChanged"
}

class Theme {
    var themeID = ""
    var title = ""
}

class PremiumCoordinator {
    
    static let shared = PremiumCoordinator()
    private init() {} //This prevents others from using the default '()' initializer for this class.
    
    lazy var themes:[Theme] = {
        
        var newThemes = [Theme]()
        
        if let path = Bundle.main.path(forResource: "ThemesList", ofType: "plist") {
            if let array = NSArray(contentsOfFile: path) {
                
                for item in array {
                    if let item = item as? NSDictionary {
                        print(item)
                        print("")
                        
                        let newTheme = Theme()
                        
                        if let obj = item["themeID"] as? String {
                            newTheme.themeID = obj
                            
                            if let obj = item["title"] as? String {
                                newTheme.title = obj
                                
                                newThemes.append(newTheme)
                            }
                        }
                    }
                }
            }
        }
        
        return newThemes
    }()
    
    func themePackPurchased() -> Bool {
        if let themePackString = UserDefaults.standard.object(forKey: "ThemePack001") as? String {
            if themePackString == "YES" {
                return true
            }
        }
        
        return false
    }
    
    
    func currentTheme() -> String {
        if let string = UserDefaults.standard.object(forKey: "CurrentTheme") as? String {
            return string
        }
        
        // No current theme picked, return the default.
        return "pink001"
    }
    
    
    func imageForTheme(string: String) -> UIImage? {
        
        if let image = UIImage(named: string + "@2x.jpg") {
            return image
        } else {
            return nil
        }
    }
    
    
    func imageForCurrentTheme() -> UIImage? {
        
        return imageForTheme(string: currentTheme())
        
        return nil
    }
    
    func setTheme(string: String?) {
        if let string = string {
            UserDefaults.standard.set(string, forKey: "CurrentTheme")
        } else {
            UserDefaults.standard.removeObject(forKey: "CurrentTheme")
        }
        
        UserDefaults.standard.synchronize()
        
        DispatchQueue.main.async {
            NotificationCenter.default.post(name: Notification.Name(rawValue: PremiumCoordinatorNotification.themeChanged), object: nil)
        }
    }
}

