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

public enum KeyStyle {
    case Available // A normal button
    case AvailablePremium // A usually premium button that is now available (trial mode)
    case PremiumRequired // A premium button, locked from the user.
}

class PremiumCoordinator {
    
    static let shared = PremiumCoordinator()
    
    lazy var legacyThemeUser: Bool = {
        return UserDefaults.standard.bool(forKey: "ThemePack001")
    }()
    
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
    
    func canAccessThemes() -> Bool {
        if isUserPremium() || isUserInTrial() || self.legacyThemeUser {
            return true
        }
        return false
    }
    
    
    func isUserPremium() -> Bool {
        return false
    }
    
    
    func isUserInTrial() -> Bool {
        return false
    }
    
    
    func canAccessKey(character: Character) -> Bool {
        // temp - pretend all operators are premium
        if SymbolCharacter.operators.contains(character) {
            return false
        }
        
        return true
    }
    
    
    func keyStyleFor(character: Character) -> KeyStyle? {
        if canAccessKey(character: character) {
            // This is a normal key
            return KeyStyle.Available
        } else {
            // This key is usually premium, determine what kind of style is required.
            
            if isUserPremium() {
                // This user is premium and can access everything.
                return KeyStyle.Available
            } else if isUserInTrial() {
                // This user isn't premium but they are in a trial.
                return KeyStyle.AvailablePremium
            } else {
                // This is a non premium, non trial user, they cannot access this key.
                return KeyStyle.PremiumRequired
            }
        }
    }
}

