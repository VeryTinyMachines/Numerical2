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
    func viewIsWide() -> Bool
}



class KeypadViewController: UIViewController {
    
    @IBOutlet var buttons: [CalcButton]!
    
    var delegate: KeypadDelegate?
    
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
        
        let standardLayout = ["c","7","4","1","0",SymbolCharacter.percentage, "8", "5", "2", ".", SymbolCharacter.fraction, "9", "6", "3", ")", "d", "/", "*", "-", "+"]
        
        for button in buttons {
            let tag = button.tag
            
            if tag < standardLayout.count {
                let character = standardLayout[tag]
                
                if character == "c" {
                    button.setTitle("CE", forState: UIControlState.Normal)
                    
                } else if character == "d" {
                    button.setTitle("Del", forState: UIControlState.Normal)
                    
                } else {
                    let formattedCharacter = Glossary.stringForCharacter(character)
                    
                    button.setTitle(formattedCharacter, forState: UIControlState.Normal)
                }
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
    
    func setLegalKeys(legalKeys: Set<Character>) {
//        print("setLegalKeys: \(legalKeys)", appendNewline: true)
        
    }
    
    
    
}
