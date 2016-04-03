//
//  KeypadViewController.swift
//  Numerical2
//
//  Created by Andrew J Clark on 31/07/2015.
//  Copyright © 2015 Very Tiny Machines. All rights reserved.
//

import UIKit

public enum KeypadLayout {
    case CompactStandard
    case CompactScientific
    case Regular
    case All
}

protocol KeypadDelegate {
    func pressedKey(key: Character)
}



class KeypadViewController: UIViewController {
    
    @IBOutlet var buttons: [CalcButton]!
    
    var delegate: KeypadDelegate?
    
    var keyCharacters:Array<Character> = []
    
    var layoutType = KeypadLayout.CompactStandard
    
    var originLayoutType = KeypadLayout.All
    
    var currentLegalKeys:Set<Character> = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        view.backgroundColor = UIColor.clearColor()
        setupKeys()
    }
    
    func setupKeys() {
        
        let compactStandard = [SymbolCharacter.clear,"7","4","1","0",SymbolCharacter.percentage, "8", "5", "2", ".", SymbolCharacter.fraction, "9", "6", "3", SymbolCharacter.smartBracket, SymbolCharacter.delete, "/", "*", "-", "+"]
        
        let compactScientific = [SymbolCharacter.clear, SymbolCharacter.ee, SymbolCharacter.sin, SymbolCharacter.cos, SymbolCharacter.tan, "^", SymbolCharacter.sqrt, SymbolCharacter.sinh, SymbolCharacter.cosh, SymbolCharacter.tanh, SymbolCharacter.factorial, SymbolCharacter.log, SymbolCharacter.log2, SymbolCharacter.log10, "(", SymbolCharacter.delete, SymbolCharacter.pi, SymbolCharacter.e, SymbolCharacter.infinity, ")"]
        
        let regular = [" ", SymbolCharacter.ee, SymbolCharacter.sin, SymbolCharacter.cos, SymbolCharacter.tan, "^", SymbolCharacter.sqrt, SymbolCharacter.sinh, SymbolCharacter.cosh, SymbolCharacter.tanh, SymbolCharacter.factorial, SymbolCharacter.log, SymbolCharacter.log2, SymbolCharacter.log10, "(", " ", SymbolCharacter.pi, SymbolCharacter.e, SymbolCharacter.infinity, ")", SymbolCharacter.clear,"7","4","1","0",SymbolCharacter.percentage, "8", "5", "2", ".", SymbolCharacter.fraction, "9", "6", "3", SymbolCharacter.smartBracket, SymbolCharacter.delete, "/", "*", "-", "+"]
        
        if layoutType == KeypadLayout.CompactStandard {
            keyCharacters = compactStandard
        } else if layoutType == KeypadLayout.CompactScientific {
            keyCharacters = compactScientific
        } else if layoutType == KeypadLayout.Regular {
            keyCharacters = regular
        }
        
        for button in buttons {
            let tag = button.tag
            
            if tag < keyCharacters.count {
                let character = keyCharacters[tag]
                
                button.alpha = 1.0
                button.enabled = true
                
                if character == "c" {
                    button.setTitle("C", forState: UIControlState.Normal)
                    
                } else if character == "d" {
                    button.setTitle("⬅︎", forState: UIControlState.Normal)
                    button.baseColor = UIColor(red: 0 / 255, green: 122/255, blue: 255/255, alpha: 1.0)
                    button.highlightColor = UIColor(red: 166 / 255, green: 183/255, blue: 255/255, alpha: 1.0)
                    
                } else if character == " " {
                    button.setTitle("", forState: UIControlState.Normal)
                    button.alpha = 0.0
                    button.enabled = false
                } else {
                    let formattedCharacter = Glossary.stringForCharacter(character)
                    
                    button.setTitle(formattedCharacter, forState: UIControlState.Normal)
                }
                
                print(button.bounds.size)
                button.titleLabel?.font = StyleFormatter.preferredFontForButtonOfSize(button.bounds.size)
            }
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        setupKeys()
        updateLegalKeys()
    }
    
    
    @IBAction func pressedKey(sender: UIButton) {
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
    
    
    func setLegalKeys(legalKeys: Set<Character>) {
        print("setLegalKeys: \(legalKeys)")
        
        currentLegalKeys = legalKeys
        updateLegalKeys()
    }
    
    
    func updateLegalKeys() {
        if let theButtons = buttons {
            for button in theButtons {
                
                let tag = button.tag
                
                if tag < keyCharacters.count {
                    let character = keyCharacters[tag]
                    
                    if currentLegalKeys.contains(character) {
                        // This button is legal
                        button.alpha = 1.0
                        button.enabled = true
                    } else {
                        if button.titleLabel == "" {
                            // This button is not legal
                            button.alpha = 0.0
                            button.enabled = false
                        } else {
                            // This button is not legal
                            button.alpha = 0.8
                            button.enabled = false
                        }
                    }
                    
                    // Set the smart bracket button
                    if character == SymbolCharacter.smartBracket {
                        print("")
                        
                        if currentLegalKeys.contains("(") {
                            button.setTitle("(", forState: UIControlState.Normal)
                        } else if currentLegalKeys.contains(")") {
                            button.setTitle(")", forState: UIControlState.Normal)
                        } else {
                            button.setTitle("(", forState: UIControlState.Normal)
                        }
                    }
                    
                    button.titleLabel?.font = StyleFormatter.preferredFontForButtonOfSize(button.frame.size)
                }
            }
        }

        
        
    }
    
    
    
}
