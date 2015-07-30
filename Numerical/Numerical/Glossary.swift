//
//  Glossary.swift
//  Numerical2
//
//  Created by Andrew J Clark on 27/07/2015.
//  Copyright © 2015 Andrew J Clark. All rights reserved.
//

import Foundation

public enum TermType {
    case Number
    case Operator
    case Unknown
}

public enum OperatorType {
    case PreOperator
    case MidOperator
    case PostOperator
    case PercentageCombine
}

public enum InfinityType {
    case Positive
    case Negative
    case NotInfinity
}

public struct SymbolConstant {
    public static let piValue = "3.14159265358979323846"
    public static let eulerValue = "2.71828182845904523536"
}

public struct SymbolCharacter {
    public static let pi:Character = "π"
    public static let e:Character = "ℇ"
    public static let infinity:Character = "∞"
    
    public static let sin:Character = "⟁"
    public static let cos:Character = "⟃"
    public static let tan:Character = "⟄"
    public static let ee:Character = "⟅"
    public static let sqrt:Character = "√"
    
    public static let log:Character = "⟉" // "log(x) in c is what most calculators call "ln"
    public static let log2:Character = "⟇" // log2(x) in c is what most calculators call "log"
    public static let log10:Character = "⟈"
    
    public static let factorial:Character = "!"
    public static let fraction:Character = "⟋"
    public static let percentage:Character = "%"
    
    public static let preOperator:Character = "⟜"
    public static let postOperator:Character = "⟞"
}

public class Glossary {
    
    class func isStringSpecialWord(string: String) -> Bool {
        if string == "and" || string == "by" || string == "with" {
            return true
        } else {
            return false
        }
    }
    
    class func isStringFractionNumber(string: String) -> Bool {
        
        if string.rangeOfString(String(SymbolCharacter.fraction)) == nil {
            // This is definitely not a fraction
            return false
        } else {
            // This string contains the fraction symbol, now just need to ensure that all the other characters are numbers
            return isStringNumber(string)
        }
    }
    
    class func isStringNumber(string: String) -> Bool {
        
        let numbers:Set<Character> = ["0","1","2","3","4","5","6","7","8","9",".",SymbolCharacter.pi, SymbolCharacter.e, SymbolCharacter.infinity, SymbolCharacter.fraction]
        
        if string == "" || string == "-" {
            return false
        }
        
        var counter = 0
        for character in string.characters {
            
            if counter == 0 && character == "-" {
                // This is a leading - and can be safely ignored
            } else if numbers.contains(character) == false {
                return false
            }
            
            counter += 1
        }
        
        return true
        
    }
    
    class func stringContainsDecimal(string: String) -> Bool {
        
        if let _ = string.rangeOfString(".") {
            return true
        } else {
            return false
        }
    }
    
    class func isStringOperator(string: String) -> Bool {
        
        let operators:Set<Character> = ["^","/","*","-","+","%", SymbolCharacter.sin, SymbolCharacter.cos, SymbolCharacter.tan, SymbolCharacter.ee, SymbolCharacter.sqrt, SymbolCharacter.log, SymbolCharacter.log2, SymbolCharacter.log10, SymbolCharacter.factorial, SymbolCharacter.percentage]
        
        if string.characters.count > 1 {
            return false
        }
        
        for character in string.characters {
            if operators.contains(character) == false {
                return false
            }
        }
        
        return true
    }
    
    class func isStringInfinity(string: String) -> InfinityType {
        let numbers:Set<Character> = [SymbolCharacter.infinity]
        
        if string == "" || string == "-" {
            return InfinityType.NotInfinity
        }
        
        var counter = 0
        var negative = false
        
        for character in string.characters {
            
            if counter == 0 && character == "-" {
                // This is a leading - and can be safely ignored
                negative = true
            } else if numbers.contains(character) == false {
                return InfinityType.NotInfinity
            }
            
            counter += 1
        }
        
        // It IS infinity - not determine the type.
        if negative {
            return InfinityType.Negative
        } else {
            return InfinityType.Positive
        }
    }
    
    class func isStringInteger(string: String) -> Bool {
        
        if isStringNumber(string) {
            if string.characters.contains(".") {
                return false
            } else {
                return true
            }
        }
        
        return true
    }
    
    
    class func shouldAddClosingBracketToAppendString(string: String, newOperator: Character) -> Bool {
        
        if newOperator == "*" || newOperator == "/" {
            let termArray = Evaluator.termArrayFromString(string, allowNonLegalCharacters: false)
            
            if termArray.count > 1 {
                
                // Iterate backwards through the term array.
                
                var currentBracketLevel = 0
                let theOperator = OperandTerm()
                let theNumber = NumberTerm()
                
                for index in 1...termArray.count {
                    
                    
                    let currentIndex = termArray.count - index
                    let currentTerm = termArray[currentIndex]
                    print(termArray[currentIndex], appendNewline: false)
                    
                    if currentTerm == ")" {
                        currentBracketLevel += 1
                    } else if currentTerm == "(" {
                        currentBracketLevel -= 1
                        if currentBracketLevel < 0 {
                            break
                        }
                    } else {
                        
                        // Need to find the first operator that is preceeded by a number.
                        // If we finds
                        
                        if theOperator.complete() {
                            // Now process this next thing, which could be a number or an operator
                            if theNumber.processTerm(currentTerm) {
                                // We have theOperator AND theNumber - now we can check what the operator is
                                
                                let characterOperator = theOperator.characterValue()
                                
                                if characterOperator == "+" || characterOperator == "-" {
                                    print("NEED A BRACKET", appendNewline: false)
                                    return true
                                } else {
                                    return false
                                }
                                
                                
                            } else {
                                theOperator.processTerm(currentTerm)
                            }
                            
                        } else {
                            theOperator.processTerm(currentTerm)
                        }
                    }
                }
                
            }
        }
        
        return false
    }
    
    
    class func replaceConstant(number: String?) -> String? {
        
        if let theNumber = number {
            if theNumber == String(SymbolCharacter.e) {
                return SymbolConstant.eulerValue
            } else if theNumber == String(SymbolCharacter.pi) {
                return SymbolConstant.piValue
            }
        }
        
        return number
    }
    
    class func legalCharactersToAppendString(string: String) -> Set<Character>? {
        
        let lastCharacter = string.characters.last
        
        let numberCharacters:Set<Character> = ["0","1","2","3","4","5","6","7","8","9","0",".",SymbolCharacter.pi, SymbolCharacter.e, SymbolCharacter.infinity]
        
        // TODO - What happens if you try and add numbers to a symbol? "1pi3" is a weird yet valid number
        
        let pre = SymbolCharacter.preOperator
        let post = SymbolCharacter.postOperator
        
        
        var legalCombinations:[Character: String] =
        ["n":"n+-/*^)cd\(post)",
            "(":"n-)cd\(pre)",
            ")":"n+-/*^)(cd\(post)",
            "+":"n-+(cd\(pre)",
            "-":"n-+(cd\(pre)",
            "*":"n-(cd\(pre)",
            "/":"n-(cd\(pre)",
            "^":"n-(cd\(pre)",
            " ":"n-/*^(\(pre)"]
        
        if let theLastCharacter = lastCharacter {
            
            var lastCharacterGeneric = theLastCharacter
            
            if numberCharacters.contains(theLastCharacter) {
                lastCharacterGeneric = "n"
            }
            
            let combinationReturn = legalCombinations[lastCharacterGeneric]
            
            if let combination = combinationReturn {
                
                // Convert combination into a set of characters
                
                var legalCharacterSet = Set<Character>()
                
                for character in combination.characters {
                    legalCharacterSet.insert(character)
                }
                
                
                if legalCharacterSet.contains("n") {
                    // If the lastCharacter is a "n" we need to determine if the end of the string is a number and if that number contains a decimal - if not
                    if lastCharacterGeneric == "n" {
                        let termArray = Evaluator.termArrayFromString(string, allowNonLegalCharacters: false)
                        
                        if let lastTerm = termArray.last {
                            
                            if lastTerm.rangeOfString(".") != nil {
                                // There IS a decimal here.
                            } else {
                                // Insert the decimal
                                legalCharacterSet.insert(".")
                            }
                            
                        } else {
                            // Insert the decimal
                            legalCharacterSet.insert(".")
                        }
                        
                    } else {
                        // Insert the decimal
                        legalCharacterSet.insert(".")
                    }
                }
                
                return legalCharacterSet
                
            } else {
                
                return nil
            }
            
        } else {
            
            // There are no characters in this string.
            
            if let emptyLegalCharacters = legalCombinations[" "] {
                var legalCharacterSet = Set<Character>()
                
                for character in emptyLegalCharacters.characters {
                    legalCharacterSet.insert(character)
                }
                
                // Insert the decimal
                legalCharacterSet.insert(".")
                
                return legalCharacterSet
            } else {
                return nil
            }
            
        }
    }
}