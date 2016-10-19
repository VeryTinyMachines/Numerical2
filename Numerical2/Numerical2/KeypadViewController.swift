//
//  KeypadViewController.swift
//  Numerical2
//
//  Created by Andrew J Clark on 31/07/2015.
//  Copyright © 2015 Very Tiny Machines. All rights reserved.
//

import UIKit

public enum KeypadLayout {
    case compactStandard
    case compactScientific
    case regular
    case all
}

protocol KeypadDelegate {
    func pressedKey(_ key: Character, sourceView: UIView?)
}



class KeypadViewController: UIViewController {
    
    @IBOutlet var buttons: [CalcButton]!
    
    var delegate: KeypadDelegate?
    
    var keyCharacters:Array<Character> = []
    
    var layoutType = KeypadLayout.compactStandard
    
    var originLayoutType = KeypadLayout.all
    
    var currentLegalKeys:Set<Character> = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        view.backgroundColor = UIColor.clearColor()
        setupKeys()
        
        // Connect all the buttons
        
        for button in buttons {
            button.addTarget(self, action: #selector(KeypadViewController.pressedPressedDown(_:) ), for: UIControlEvents.touchDown)
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(KeypadViewController.updateLegalKeys), name: Notification.Name(rawValue: PremiumCoordinatorNotification.premiumStatusChanged), object: nil)
    }
    
    @IBAction func pressedPressedDown(_ sender: UIButton) {
        initateButtonPress(sender: sender)
    }
    
    func setupKeys() {
        
        if layoutType == KeypadLayout.compactStandard {
            keyCharacters = SymbolCharacter.compactStandard
        } else if layoutType == KeypadLayout.compactScientific {
            keyCharacters = SymbolCharacter.compactScientific
        } else if layoutType == KeypadLayout.regular {
            if NumericalHelper.isDevicePad() {
                keyCharacters = SymbolCharacter.regularPad
            } else {
                keyCharacters = SymbolCharacter.regularPhone
            }
        }
        
        for button in buttons {
            let tag = button.tag
            
            if tag < keyCharacters.count {
                let character = keyCharacters[tag]
                
                button.alpha = 1.0
                button.isEnabled = true
                
                if character == " " {
                    button.setTitle("", for: UIControlState())
                    button.alpha = 0.0
                    button.isEnabled = false
                } else {
                    let formattedCharacter = Glossary.formattedStringForCharacter(character)
                    
                    button.setTitle(formattedCharacter, for: UIControlState())
                }
            }
        }
        
//        updateLegalKeys()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupKeys()
        updateLegalKeys()
    }
    
    
    @IBAction func pressedKey(_ sender: UIButton) {
        
    }
    
    func initateButtonPress(sender: UIButton) {
        
        var character = keyCharacters[sender.tag]
        
        print("pressedKey with tag \(sender.tag) with character \(character)")
        
        // If this is a smart bracket button then figure out what kind of bracket it is
        
        if character == SymbolCharacter.smartBracket {
            if currentLegalKeys.contains("(") {
                character = "("
            } else if currentLegalKeys.contains(")") {
                character = ")"
            } else {
                character = "("
            }
        }
        
        if let keyDelegate = delegate {
            keyDelegate.pressedKey(character, sourceView: sender)
        }
    }
    
    
    func setLegalKeys(_ legalKeys: Set<Character>) {
        print("setLegalKeys: \(legalKeys)")
        
        currentLegalKeys = legalKeys
        updateLegalKeys()
    }
    
    
    func updateLegalKeys() {
        if let theButtons = buttons {
            
            print("currentLegalKeys: \(currentLegalKeys)")
            
            for button in theButtons {
                
                let tag = button.tag
                
                if tag < keyCharacters.count {
                    let character = keyCharacters[tag]
                    
                    print("tag: \(tag)  character: \(character)  contains: \(currentLegalKeys.contains(character))")
                    
                    
                    // Change button design depending on the user state
                    if let style = PremiumCoordinator.shared.keyStyleFor(character: character) {
                        button.keyStyle = style
                        button.isEnabled = currentLegalKeys.contains(character)
                    }
                    
                    button.updateEnabledState()
                    
                    // Set the smart bracket button
                    if character == SymbolCharacter.smartBracket {
                        if currentLegalKeys.contains("(") {
                            button.setTitle("(", for: UIControlState())
                        } else if currentLegalKeys.contains(")") {
                            button.setTitle(")", for: UIControlState())
                        } else {
                            button.setTitle("(", for: UIControlState())
                        }
                    }
                    
                    // If the character is for either of the brackets then FORCE these to be available.
                    if character == "(" {
                        button.setTitle("(", for: UIControlState())
                        button.alpha = 1.0
                        button.isEnabled = true
                    } else if character == ")" {
                        button.setTitle(")", for: UIControlState())
                        button.alpha = 1.0
                        button.isEnabled = true
                    }
                }
            }
        }

        
        
    }
    
    
    
}
