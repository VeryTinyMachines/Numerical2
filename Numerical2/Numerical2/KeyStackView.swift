//
//  KeyStackView.swift
//  Numerical2
//
//  Created by Andrew J Clark on 6/08/2015.
//  Copyright © 2015 Very Tiny Machines. All rights reserved.
//

import UIKit

protocol KeyStackViewDelegate {
    func pressedKey(key: Character)
}

class KeyStackView: UIStackView {
    
    @IBOutlet var keys: [UIButton]!
    
    var delegate:KeyStackViewDelegate?
    
    var keyCharacters:Array<Character> = [] {
        didSet {
            updateKeys()
        }
    }
    
    func updateKeys() {
        for key in keys {
            let tag = key.tag
            if tag < keyCharacters.count {
                let theCharacter = keyCharacters[tag]
                let formattedCharacter = Glossary.stringForCharacter(theCharacter)
                
                key.setTitle(formattedCharacter, forState: UIControlState.Normal)
                
                let headlineFont = UIFont.preferredFontForTextStyle(UIFontTextStyleHeadline)
                let newTitleFont = UIFont(name: headlineFont.fontName, size: headlineFont.pointSize * 1.2)
                
                if key.titleLabel?.font != newTitleFont {
                    key.titleLabel?.font = newTitleFont
                }
            }
        }
    }
    
    @IBAction func pressedKey(sender: UIButton) {
        if let theDelegate = delegate {
            let tag = sender.tag
            if tag < keyCharacters.count {
                let theCharacter = keyCharacters[tag]
                theDelegate.pressedKey(theCharacter)
            }
        }
    }
    
    func setLegalKeys(legalKeys: Set<Character>) {
//        print("setLegalKeys: \(legalKeys)", appendNewline: true)
        
        for key in keys {
            
            let headlineFont = UIFont.preferredFontForTextStyle(UIFontTextStyleHeadline)
            let newTitleFont = UIFont(name: headlineFont.fontName, size: headlineFont.pointSize * 1.2)
            
            if key.titleLabel?.font != newTitleFont {
                key.titleLabel?.font = newTitleFont
            }
            
            
            let keyTag = key.tag
            
            if keyTag < keyCharacters.count {
                
                let keyCharacter = keyCharacters[keyTag]
                
                if keyCharacter == SymbolCharacter.smartBracket {
                    
                    if legalKeys.contains(")") {
                        key.setTitle(Glossary.stringForCharacter(")"), forState: UIControlState.Normal)
                    } else if legalKeys.contains("(") {
                        key.setTitle(Glossary.stringForCharacter("("), forState: UIControlState.Normal)
                    }
                    
                    
                    
                }
                
                if legalKeys.contains(keyCharacter) {
                    key.enabled = true
                    key.alpha = 1.0
                } else {
                    key.enabled = false
                    key.alpha = 1.0
                }
                
            }
        }

        
    }
    
    
}
