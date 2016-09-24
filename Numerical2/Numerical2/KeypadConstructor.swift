//
//  KeypadConstructor.swift
//  Numerical2
//
//  Created by Andrew J Clark on 7/08/2015.
//  Copyright © 2015 Very Tiny Machines. All rights reserved.
//

import Foundation

public enum KeypadType {
    case standard
    case scientific
}

public enum KeyStackType {
    case standard1
    case standard2
    case standard3
    case standard4
    case scientific1
    case scientific1Wide
    case scientific2
    case scientific3
    case scientific4
    case scientific4Wide
}



open class KeypadConstructor {
    
    static let sharedInstance = KeypadConstructor()
    fileprivate init() {} //This prevents others from using the default '()' initializer for this class.
    
    open func keypadArray(_ layout: KeypadLayout) -> Array<KeyStackType> {
        
        var keypadArray:Array<KeyStackType> = []
        
        if layout == KeypadLayout.compactStandard {
            // Basic
            keypadArray.append(KeyStackType.standard1)
            keypadArray.append(KeyStackType.standard2)
            keypadArray.append(KeyStackType.standard3)
            keypadArray.append(KeyStackType.standard4)
        } else if layout == KeypadLayout.compactScientific {
            keypadArray.append(KeyStackType.scientific1)
            keypadArray.append(KeyStackType.scientific2)
            keypadArray.append(KeyStackType.scientific3)
            keypadArray.append(KeyStackType.scientific4)
        } else if layout == KeypadLayout.regular {
            // Wide
            keypadArray.append(KeyStackType.scientific1Wide)
            keypadArray.append(KeyStackType.scientific2)
            keypadArray.append(KeyStackType.scientific3)
            keypadArray.append(KeyStackType.scientific4Wide)
            
            keypadArray.append(KeyStackType.standard1)
            keypadArray.append(KeyStackType.standard2)
            keypadArray.append(KeyStackType.standard3)
            keypadArray.append(KeyStackType.standard4)
        } else if layout == KeypadLayout.all {
            keypadArray.append(KeyStackType.scientific1)
            keypadArray.append(KeyStackType.scientific1Wide)
            keypadArray.append(KeyStackType.scientific2)
            keypadArray.append(KeyStackType.scientific3)
            keypadArray.append(KeyStackType.scientific4)
            keypadArray.append(KeyStackType.scientific4Wide)
            
            keypadArray.append(KeyStackType.standard1)
            keypadArray.append(KeyStackType.standard2)
            keypadArray.append(KeyStackType.standard3)
            keypadArray.append(KeyStackType.standard4)
        }
        
        return keypadArray
    }
    
    func keyStack(_ type: KeyStackType) -> Array<Character> {
        
        switch type {
        case .standard1:
            return [SymbolCharacter.clear, "7", "4", "1", "0"]
        case .standard2:
            return [SymbolCharacter.percentage, "8", "5", "2", "."]
        case .standard3:
            return [SymbolCharacter.fraction, "9", "6", "3", SymbolCharacter.smartBracket]
        case .standard4:
            return  [SymbolCharacter.delete, "/", "*", "-", "+"]
        case .scientific1:
            return [SymbolCharacter.clear, SymbolCharacter.ee, SymbolCharacter.sin, SymbolCharacter.cos, SymbolCharacter.tan]
        case .scientific1Wide:
            return [" ", SymbolCharacter.ee, SymbolCharacter.sin, SymbolCharacter.cos, SymbolCharacter.tan]
        case .scientific2:
            return ["^", SymbolCharacter.sqrt, SymbolCharacter.sinh, SymbolCharacter.cosh, SymbolCharacter.tanh]
        case .scientific3:
            return [SymbolCharacter.factorial, SymbolCharacter.log, SymbolCharacter.log2, SymbolCharacter.log10, "("]
        case .scientific4:
            return  [SymbolCharacter.delete, SymbolCharacter.pi, SymbolCharacter.e, SymbolCharacter.infinity, ")"]
        case .scientific4Wide:
            return [" ", SymbolCharacter.pi, SymbolCharacter.e, SymbolCharacter.infinity, ")"]
        }
    }
    
    
}
