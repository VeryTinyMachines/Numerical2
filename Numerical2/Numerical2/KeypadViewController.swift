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
    func unpressedKey(_ key: Character, sourceView: UIView?)
}



class KeypadViewController: UIViewController {
    
    @IBOutlet var buttons: [CalcButton]!
    
    var delegate: KeypadDelegate?
    
    var keyCharacters:Array<Character> = []
    
    var layoutType = KeypadLayout.compactStandard
    
    var originLayoutType = KeypadLayout.all
    
    var currentLegalKeys:Set<Character> = []
    
    var holdTimer:Timer?
    var holdTimerInterval = 1.0
    
    var currentButton:UIButton?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupKeys()
        
        // Connect all the buttons
        for button in buttons {
            button.addTarget(self, action: #selector(KeypadViewController.pressedPressedDown(_:) ), for: UIControlEvents.touchDown)
            
            button.addTarget(self, action: #selector(KeypadViewController.pressedCancel(_:) ), for: UIControlEvents.touchCancel)
            
            button.addTarget(self, action: #selector(KeypadViewController.pressedPressedUp(_:) ), for: UIControlEvents.touchUpInside)
            
            button.addTarget(self, action: #selector(KeypadViewController.pressedCancel(_:) ), for: UIControlEvents.touchDragExit)
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(KeypadViewController.updateLegalKeys), name: Notification.Name(rawValue: PremiumCoordinatorNotification.premiumStatusChanged), object: nil)
    }
    
    @IBAction func pressedPressedDown(_ sender: UIButton) {
        
        currentButton = sender
        
        holdTimer?.invalidate()
        
        holdTimerInterval = 0.4
        
        holdTimer = Timer.scheduledTimer(withTimeInterval: holdTimerInterval, repeats: false, block: { (timer) in
            self.holdFireTimer()
        })
    }
    
    @IBAction func pressedPressedUp(_ sender: UIButton) {
        currentButton = nil
        
        holdTimer?.invalidate()
        
        initateButtonPress(sender: sender)
    }
    
    @IBAction func pressedCancel(_ sender: UIButton) {
        holdTimer?.invalidate()
        
        currentButton = nil
        
        uninitateButtonPress(sender: sender)
    }
    
    func holdFireTimer() {
        if let currentButton = currentButton {
            initateButtonPress(sender: currentButton)
            
            holdTimer?.invalidate()
            
            if holdTimerInterval > 0.2 {
                holdTimerInterval -= 0.1
            }
            
            holdTimer = Timer.scheduledTimer(withTimeInterval: holdTimerInterval, repeats: false, block: { (timer) in
                self.holdFireTimer()
            })
        }
    }
    
    
    func setupKeys() {
        
        if layoutType == KeypadLayout.compactStandard {
            keyCharacters = SymbolCharacter.compactStandard
        } else if layoutType == KeypadLayout.compactScientific {
            keyCharacters = SymbolCharacter.compactScientific
        } else if layoutType == KeypadLayout.regular {
            if NumericalViewHelper.isDevicePad() {
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
        
        updateLegalKeys()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupKeys()
        updateLegalKeys()
        
        DispatchQueue.main.async {
            self.setupKeys()
            self.updateLegalKeys()
        }
    }
    
    
    @IBAction func pressedKey(_ sender: UIButton) {
        
    }
    
    func initateButtonPress(sender: UIButton) {
        if let character = characterForSenderTag(tag: sender.tag) {
            delegate?.pressedKey(character, sourceView: sender)
        }
    }
    
    
    func uninitateButtonPress(sender: UIButton) {
        if let character = characterForSenderTag(tag: sender.tag) {
            delegate?.unpressedKey(character, sourceView: sender)
        }
    }
    
    func characterForSenderTag(tag: Int) -> Character? {
        var character = keyCharacters[tag]
        
        print("pressedKey with tag \(tag) with character \(character)")
        
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
        
        return character
    }
    
    
    func setLegalKeys(_ legalKeys: Set<Character>) {
        currentLegalKeys = legalKeys
        updateLegalKeys()
    }
    
    
    func updateLegalKeys() {
        if let theButtons = buttons {
            
            for button in theButtons {
                
                let tag = button.tag
                
                if tag < keyCharacters.count {
                    let character = keyCharacters[tag]
                    
                    // Change button design depending on the user state
                    if let style = PremiumCoordinator.shared.keyStyleFor(character: character) {
                        button.keyStyle = style
                        button.isEnabled = currentLegalKeys.contains(character)
                        
                        if button == currentButton && button.isEnabled == false {
                            // Need to invalidate the timer
                            holdTimer?.invalidate()
                            currentButton = nil
                        }
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
