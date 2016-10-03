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
    func pressedKey(_ key: Character)
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
    }
    
    @IBAction func pressedPressedDown(_ sender: UIButton) {
        initateButtonPress(sender: sender)
    }
    
    func setupKeys() {
        
        let compactStandard = [SymbolCharacter.clear,"7","4","1","0",SymbolCharacter.percentage, "8", "5", "2", ".", SymbolCharacter.fraction, "9", "6", "3", SymbolCharacter.smartBracket, SymbolCharacter.delete, SymbolCharacter.divide, SymbolCharacter.multiply, SymbolCharacter.subtract, SymbolCharacter.add]
        
        let compactScientific = [SymbolCharacter.clear, SymbolCharacter.ee, SymbolCharacter.sin, SymbolCharacter.cos, SymbolCharacter.tan, "^", SymbolCharacter.sqrt, SymbolCharacter.sinh, SymbolCharacter.cosh, SymbolCharacter.tanh, SymbolCharacter.factorial, SymbolCharacter.log, SymbolCharacter.log2, SymbolCharacter.log10, "(", SymbolCharacter.delete, SymbolCharacter.pi, SymbolCharacter.e, SymbolCharacter.infinity, ")"]
        
        let regular = [" ", SymbolCharacter.ee, SymbolCharacter.sin, SymbolCharacter.cos, SymbolCharacter.tan, "^", SymbolCharacter.sqrt, SymbolCharacter.sinh, SymbolCharacter.cosh, SymbolCharacter.tanh, SymbolCharacter.factorial, SymbolCharacter.log, SymbolCharacter.log2, SymbolCharacter.log10, "(", " ", SymbolCharacter.pi, SymbolCharacter.e, SymbolCharacter.infinity, ")", SymbolCharacter.clear,"7","4","1","0",SymbolCharacter.percentage, "8", "5", "2", ".", SymbolCharacter.fraction, "9", "6", "3", SymbolCharacter.smartBracket, SymbolCharacter.delete, SymbolCharacter.divide, SymbolCharacter.multiply, SymbolCharacter.subtract, SymbolCharacter.add]
        
        if layoutType == KeypadLayout.compactStandard {
            keyCharacters = compactStandard
        } else if layoutType == KeypadLayout.compactScientific {
            keyCharacters = compactScientific
        } else if layoutType == KeypadLayout.regular {
            keyCharacters = regular
        }
        
        for button in buttons {
            let tag = button.tag
            
            if tag < keyCharacters.count {
                let character = keyCharacters[tag]
                
                button.alpha = 1.0
                button.isEnabled = true
                
                if character == SymbolCharacter.clear {
                    button.setTitle("C", for: UIControlState())
                    
                } else if character == "d" {
                    button.setTitle("⬅︎", for: UIControlState())
                    button.baseColor = UIColor(red: 0 / 255, green: 122/255, blue: 255/255, alpha: 1.0)
                    button.highlightColor = UIColor(red: 166 / 255, green: 183/255, blue: 255/255, alpha: 1.0)
                    
                } else if character == " " {
                    button.setTitle("", for: UIControlState())
                    button.alpha = 0.0
                    button.isEnabled = false
                } else {
                    let formattedCharacter = Glossary.formattedStringForCharacter(character)
                    
                    button.setTitle(formattedCharacter, for: UIControlState())
                }
                
                print(button.bounds.size)
                button.titleLabel?.font = StyleFormatter.preferredFontForButtonOfSize(button.bounds.size)
            }
        }
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
            keyDelegate.pressedKey(character)
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
                    
                    if currentLegalKeys.contains(character) {
                        // This button is legal
                        button.alpha = 1.0
                        button.isEnabled = true
                    } else {
                        if button.titleLabel?.text == "" {
                            // This button is not legal
                            button.alpha = 0.0
                            button.isEnabled = false
                        } else {
                            // This button is not legal
                            button.alpha = 0.8
                            button.isEnabled = false
                        }
                    }
                    
                    // Set the smart bracket button
                    if character == SymbolCharacter.smartBracket {
                        print("")
                        
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
                    
                    button.titleLabel?.font = StyleFormatter.preferredFontForButtonOfSize(button.frame.size)
                }
            }
        }

        
        
    }
    
    
    
}
