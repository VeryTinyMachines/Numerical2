//
//  KeypadConstructor.swift
//  Numerical2
//
//  Created by Andrew J Clark on 7/08/2015.
//  Copyright © 2015 Very Tiny Machines. All rights reserved.
//

import Foundation

public enum KeypadType {
    case Standard
    case Scientific
}

public enum KeyStackType {
    case Standard1
    case Standard2
    case Standard3
    case Standard4
    case Scientific1
    case Scientific1Wide
    case Scientific2
    case Scientific3
    case Scientific4
    case Scientific4Wide
}



public class KeypadConstructor {
    
    static let sharedInstance = KeypadConstructor()
    private init() {} //This prevents others from using the default '()' initializer for this class.
    
    public func keypadArray(layout: KeypadLayout) -> Array<KeyStackType> {
        
        var keypadArray:Array<KeyStackType> = []
        
        if layout == KeypadLayout.CompactStandard {
            // Basic
            keypadArray.append(KeyStackType.Standard1)
            keypadArray.append(KeyStackType.Standard2)
            keypadArray.append(KeyStackType.Standard3)
            keypadArray.append(KeyStackType.Standard4)
        } else if layout == KeypadLayout.CompactScientific {
            keypadArray.append(KeyStackType.Scientific1)
            keypadArray.append(KeyStackType.Scientific2)
            keypadArray.append(KeyStackType.Scientific3)
            keypadArray.append(KeyStackType.Scientific4)
        } else if layout == KeypadLayout.Regular {
            // Wide
            keypadArray.append(KeyStackType.Scientific1Wide)
            keypadArray.append(KeyStackType.Scientific2)
            keypadArray.append(KeyStackType.Scientific3)
            keypadArray.append(KeyStackType.Scientific4Wide)
            
            keypadArray.append(KeyStackType.Standard1)
            keypadArray.append(KeyStackType.Standard2)
            keypadArray.append(KeyStackType.Standard3)
            keypadArray.append(KeyStackType.Standard4)
        } else if layout == KeypadLayout.All {
            keypadArray.append(KeyStackType.Scientific1)
            keypadArray.append(KeyStackType.Scientific1Wide)
            keypadArray.append(KeyStackType.Scientific2)
            keypadArray.append(KeyStackType.Scientific3)
            keypadArray.append(KeyStackType.Scientific4)
            keypadArray.append(KeyStackType.Scientific4Wide)
            
            keypadArray.append(KeyStackType.Standard1)
            keypadArray.append(KeyStackType.Standard2)
            keypadArray.append(KeyStackType.Standard3)
            keypadArray.append(KeyStackType.Standard4)
            
        }
        
        return keypadArray
    }
    
    func keyStack(type: KeyStackType) -> Array<Character> {
        
        switch type {
        case .Standard1:
            return [SymbolCharacter.clear, "7", "4", "1", "0"]
        case .Standard2:
            return [SymbolCharacter.percentage, "8", "5", "2", "."]
        case .Standard3:
            return [SymbolCharacter.fraction, "9", "6", "3", SymbolCharacter.smartBracket]
        case .Standard4:
            return  [SymbolCharacter.delete, "/", "*", "-", "+"]
        case .Scientific1:
            return [SymbolCharacter.clear, SymbolCharacter.ee, SymbolCharacter.sin, SymbolCharacter.cos, SymbolCharacter.tan]
        case .Scientific1Wide:
            return [" ", SymbolCharacter.ee, SymbolCharacter.sin, SymbolCharacter.cos, SymbolCharacter.tan]
        case .Scientific2:
            return ["^", SymbolCharacter.sqrt, SymbolCharacter.sinh, SymbolCharacter.cosh, SymbolCharacter.tanh]
        case .Scientific3:
            return [SymbolCharacter.factorial, SymbolCharacter.log, SymbolCharacter.log2, SymbolCharacter.log10, "("]
        case .Scientific4:
            return  [SymbolCharacter.delete, SymbolCharacter.pi, SymbolCharacter.e, SymbolCharacter.infinity, ")"]
        case .Scientific4Wide:
            return [" ", SymbolCharacter.pi, SymbolCharacter.e, SymbolCharacter.infinity, ")"]
        }
    }
    
    
}
