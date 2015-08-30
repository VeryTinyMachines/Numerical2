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



class KeypadViewController: UIViewController, KeyStackViewDelegate {
    
    var delegate: KeypadDelegate?
    
    @IBOutlet weak var stackView: UIStackView!
    
    var keyStackViews:Array<KeyStackView> = []
    var keyStackArrays:Array<KeyStackType> = []
    
    var keyCharacters:Array<Character> = []
    
    var standardCharacters:Array<Character> = ["c","(",")","d","7","8","9","/","4","5","6","*","1","2","3","-","0",".","%","+"]
    
    var scientificCharacters:Array<Character> = ["c", "^", SymbolCharacter.fraction, "d", SymbolCharacter.sqrt, SymbolCharacter.log, SymbolCharacter.pi, "/", SymbolCharacter.sin, SymbolCharacter.log2, SymbolCharacter.e, "*", SymbolCharacter.cos, SymbolCharacter.log10, SymbolCharacter.infinity, "-", SymbolCharacter.tan, SymbolCharacter.ee, SymbolCharacter.factorial, "+"]
    
    var scientificKeySet = false
    
    var layoutType = KeypadLayout.CompactStandard
    
    var originLayoutType = KeypadLayout.CompactStandard
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupKeys()
    }
    
    func setupKeys() {
        
        
        // Iterate through the keypad array and add stacks IF needed, remove unneeded ones.
        
        // When going from the compact layout to scientific + basic we need to insert the scientific ones.
        // When going from wide layout to compact we need to remove the unneeded ones.
        
        if let theStackView = self.stackView {
            var counter = 0
            
            for characterStack in KeypadConstructor.sharedInstance.keypadArray(KeypadLayout.All) {
                
                if keyStackArrays.contains(characterStack) {
                    
                    // This stack is accounted for
                    
                } else if let stack = NSBundle.mainBundle().loadNibNamed("KeyStackView", owner: self, options: nil)[0] as? KeyStackView {
                    
                    stack.backgroundColor = UIColor.blackColor()
                    
                    let newKeyCharacters = KeypadConstructor.sharedInstance.keyStack(characterStack)
                    
                    if newKeyCharacters.count > 0 {
                        stack.keyCharacters = newKeyCharacters
                        stack.delegate = self
                        
                        theStackView.insertArrangedSubview(stack, atIndex: counter)
                        
                        keyStackViews.insert(stack, atIndex: counter)
                        
                        keyStackArrays.insert(characterStack, atIndex: counter)
                    }
                }
                
                counter += 1
            }
            
            // Need to go through all of the characterStacks, and hide/unhide the relevant views
            
            let keypadArray = KeypadConstructor.sharedInstance.keypadArray(layoutType)
            
            counter = 0
            
            for characterStack in self.keyStackArrays {
                
                let theView = self.keyStackViews[counter]
                
                if keypadArray.contains(characterStack) {
                    theView.hidden = false
                } else {
                    theView.hidden = true
                }
                counter += 1
            }
        }

    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.setupKeys()
    }
    
    
    @IBAction func pressedKey(sender: UIButton) {
        print("pressedKey with tag \(sender.tag)")
        
        if let keyDelegate = delegate {
            
            let character = keyCharacters[sender.tag]
            keyDelegate.pressedKey(character)
        }
    }
    
    func pressedKey(key: Character) {
        if let keyDelegate = delegate {
            
            keyDelegate.pressedKey(key)
        }
    }
    
    func setLegalKeys(legalKeys: Set<Character>) {
//        print("setLegalKeys: \(legalKeys)", appendNewline: true)
        
        for keyStack in keyStackViews {
            keyStack.setLegalKeys(legalKeys)
        }
    }
    
    
    
}
