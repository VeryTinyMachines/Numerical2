//
//  Glossary.swift
//  Numerical2
//
//  Created by Andrew J Clark on 27/07/2015.
//  Copyright © 2015 Andrew J Clark. All rights reserved.
//

import Foundation

public enum TermType {
    case number
    case `operator`
    case unknown
}

public enum OperatorType {
    case preOperator
    case midOperator
    case postOperator
    case percentageCombine
}

public enum InfinityType {
    case positive
    case negative
    case notInfinity
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
    
    public static let sinh:Character = "⟢"
    public static let cosh:Character = "⟣"
    public static let tanh:Character = "⟤"
    
    public static let ee:Character = "⟅"
    public static let sqrt:Character = "√"
    
    public static let log:Character = "⟉" // "log(x) in c is what most calculators call "ln"
    public static let log2:Character = "⟇" // log2(x) in c is what most calculators call "log"
    public static let log10:Character = "⟈"
    
    public static let factorial:Character = "!"
    public static let fraction:Character = "⟆"
    public static let percentage:Character = "%"
    public static let random:Character = "⟡"
    
    public static let preOperator:Character = "⟜"
    public static let postOperator:Character = "⟞"
    public static let midOperator:Character = "⟝"
    
    public static let delete:Character = "⟬"
    public static let clear:Character = "⟭"
    
    public static let smartBracket:Character = "⟠"
}


open class Glossary {
    
    static let formattedLookup = [
        SymbolCharacter.e:"e",
        SymbolCharacter.sin:"sin",
        SymbolCharacter.cos:"cos",
        SymbolCharacter.tan:"tan",
        SymbolCharacter.ee:"EE",
        SymbolCharacter.log:"ln",
        SymbolCharacter.log2:"log2",
        SymbolCharacter.log10:"log10",
        SymbolCharacter.clear:"CE",
        SymbolCharacter.delete:"Del",
        SymbolCharacter.fraction:"/",
        SymbolCharacter.random:"rand",
        SymbolCharacter.sinh:"sinh",
        SymbolCharacter.cosh:"cosh",
        SymbolCharacter.tanh:"tanh",
        SymbolCharacter.factorial:"!",
        SymbolCharacter.infinity:"∞",
        SymbolCharacter.pi:"π",
        Character("/"):"÷",
        Character("*"):"×",
        Character("^"):"^",
        Character("+"):"+",
        Character("-"):"-"
    ]
    
    static let reverseFormattedLookup = [
        "e":SymbolCharacter.e,
        "sin":SymbolCharacter.sin,
        "cos":SymbolCharacter.cos,
        "tan":SymbolCharacter.tan,
        "EE":SymbolCharacter.ee,
        "ln":SymbolCharacter.log,
        "log2":SymbolCharacter.log2,
        "log10":SymbolCharacter.log10,
        "CE":SymbolCharacter.clear,
        "Del":SymbolCharacter.delete,
        "/":SymbolCharacter.fraction,
        "rand":SymbolCharacter.random,
        "sinh":SymbolCharacter.sinh,
        "cosh":SymbolCharacter.cosh,
        "tanh":SymbolCharacter.tanh,
        "!":SymbolCharacter.factorial,
        "∞":SymbolCharacter.infinity,
        "π":SymbolCharacter.pi,
        "÷":Character("/"),
        "×":Character("*"),
        "^":Character("^"),
        "+":Character("+"),
        "-":Character("-")
    ]
    
    
    
    
    class func possibleAnswersFromString(_ answerString: String) -> Array<String> {
        var answerString = answerString
        var answersArray:Array<String> = []
        
        if answerString.characters.count > 0 && answerString.substring(from: answerString.characters.index(before: answerString.endIndex)) == String(SymbolCharacter.fraction) {
            answerString += "1"
        }
        
        if Glossary.isStringFractionNumber(answerString) {
            
            // This is a fraction - only add it if it has no decimal.
            if answerString.range(of: ".") == nil {
                answersArray.append(answerString)
            }
            
            // Let's try and reduce it and add it if it's different (and has no decimal)
            if let reducedAnswer = Evaluator.reduceFraction(answerString) {
                if answerString != reducedAnswer {
                    
                    if reducedAnswer.range(of: ".") == nil {
                        answersArray.append(reducedAnswer)
                    }
                }
            }
            
            // Let's also express it as a decimal
            if let decimalAnswer = Evaluator.decimalFromFraction(answerString) {
                
                if answersArray.contains(decimalAnswer) == false {
                    answersArray.append(decimalAnswer)
                }
            }
        } else {
            answersArray.append(answerString)
        }
        
        return answersArray
    }
    
    
    class func isStringFrationWithDenominatorOfOne(_ string: String) -> Bool {
        return false
    }
    
    
    class func formattedStringForQuestion(_ string: String) -> String {
        
        var formattedString = ""
        
        for character in string.characters {
            formattedString += formattedStringForCharacter(character)
        }
        
        return formattedString
    }
    
    class func unformattedStringForQuestion(_ string: String) -> String {
        
        // 1. Search and replace all characters
        // 2. Iterate through and check all remaining ones
        
        let keys = Array(reverseFormattedLookup)
        
        
        
        return "zzzzz"
//        
//        var formattedString = ""
//        
//        for character in string.characters {
//            formattedString += stringForCharacter(character)
//        }
//        
//        return formattedString
    }
    
    class func formattedStringForCharacter(_ character: Character) -> String {
        if let formattedChar = self.formattedLookup[character] {
            return String(formattedChar)
        }
        
        return String(character)
    }
    
    class func unformattedCharacterForString(_ string: String) -> Character? {
        if let formattedChar = self.reverseFormattedLookup[string] {
            return formattedChar
        }
        
        if string.characters.count == 1 {
            if let first = string.characters.first {
                return first
            }
        }
        
        // This provided string doesn't match anything so it can't be returned.
        
        return nil
    }
    
    class func isStringSpecialWord(_ string: String) -> Bool {
        if string == "and" || string == "by" || string == "with" {
            return true
        } else {
            return false
        }
    }
    
    class func isStringFractionNumber(_ string: String) -> Bool {
        
        if string.range(of: String(SymbolCharacter.fraction)) == nil {
            // This is definitely not a fraction
            return false
        } else {
            // This string contains the fraction symbol, now just need to ensure that all the other characters are numbers
            return isStringNumber(string)
        }
    }
    
    class func isStringNumber(_ string: String) -> Bool {
        
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
    
    class func stringContainsDecimal(_ string: String) -> Bool {
        
        if let _ = string.range(of: ".") {
            return true
        } else {
            return false
        }
    }
    
    class func isStringOperator(_ string: String) -> Bool {
        
        let operators:Set<Character> = ["^","/","*","-","+","%", SymbolCharacter.sin, SymbolCharacter.cos, SymbolCharacter.tan, SymbolCharacter.sinh, SymbolCharacter.cosh, SymbolCharacter.tanh, SymbolCharacter.ee, SymbolCharacter.sqrt, SymbolCharacter.log, SymbolCharacter.log2, SymbolCharacter.log10, SymbolCharacter.factorial, SymbolCharacter.percentage]
        
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
    
    class func isStringInfinity(_ string: String) -> InfinityType {
        let numbers:Set<Character> = [SymbolCharacter.infinity]
        
        if string == "" || string == "-" {
            return InfinityType.notInfinity
        }
        
        var counter = 0
        var negative = false
        
        for character in string.characters {
            
            if counter == 0 && character == "-" {
                // This is a leading - and can be safely ignored
                negative = true
            } else if numbers.contains(character) == false {
                return InfinityType.notInfinity
            }
            
            counter += 1
        }
        
        // It IS infinity - not determine the type.
        if negative {
            return InfinityType.negative
        } else {
            return InfinityType.positive
        }
    }
    
    class func isStringInteger(_ string: String) -> Bool {
        
        if isStringNumber(string) {
            if string.characters.contains(".") {
                return false
            } else {
                return true
            }
        }
        
        return true
    }
    
    
    class func shouldAddClosingBracketToAppendString(_ string: String, newOperator: Character) -> Bool {
        
        if newOperator == "*" || newOperator == "/" {
            let termArray = Evaluator.termArrayFromString(string, allowNonLegalCharacters: false, treatConstantsAsNumbers: false)
            
            if termArray.count > 1 {
                
                // Iterate backwards through the term array.
                
                var currentBracketLevel = 0
                let theOperator = OperandTerm()
                let theNumber = NumberTerm()
                
                for index in 1...termArray.count {
                    
                    let currentIndex = termArray.count - index
                    let currentTerm = termArray[currentIndex]
                    
                    if currentTerm == ")" {
                        currentBracketLevel += 1
                    } else if currentTerm == "(" {
                        currentBracketLevel -= 1
                        if currentBracketLevel < 0 {
                            break
                        }
                    } else {
                        
                        // Need to find the first operator that is preceeded by a number.
                        
                        if theOperator.complete() {
                            // Now process this next thing, which could be a number or an operator
                            if theNumber.processTerm(currentTerm) {
                                // We have theOperator AND theNumber - now we can check what the operator is
                                
                                let characterOperator = theOperator.characterValue()
                                
                                if characterOperator == "+" || characterOperator == "-" {
                                    if currentBracketLevel == 0 {
                                        return true
                                    } else {
                                        theOperator.reset()
                                        theNumber.reset()
                                    }
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
    
    
    class func replaceConstant(_ number: String?) -> String? {
        
        if let theNumber = number {
            if theNumber == String(SymbolCharacter.e) {
                return SymbolConstant.eulerValue
            } else if theNumber == String(SymbolCharacter.pi) {
                return SymbolConstant.piValue
            }
        }
        
        return number
    }
    
    class func legalCharactersToAppendString(_ string: String) -> Set<Character>? {
        var string = string
        
        if string == "" {
            string = " "
        }
        
        let numberCharacters:Set<Character> = ["0","1","2","3","4","5","6","7","8","9","0",".",SymbolCharacter.pi, SymbolCharacter.e, SymbolCharacter.infinity]
        let preOperatorCharacters:Set<Character> = [SymbolCharacter.cos,SymbolCharacter.log, SymbolCharacter.log10, SymbolCharacter.log2, SymbolCharacter.sin, SymbolCharacter.sqrt, SymbolCharacter.tan, SymbolCharacter.sinh,SymbolCharacter.cosh,SymbolCharacter.tanh]
        let midOperatorCharacters:Set<Character> = ["+","-","*","/","^",SymbolCharacter.fraction, SymbolCharacter.ee]
        let postOperatorCharacters:Set<Character> = [SymbolCharacter.factorial, SymbolCharacter.percentage]
        
        // TODO - What happens if you try and add numbers to a symbol? "1pi3" is a weird yet valid number
        
        let pre = SymbolCharacter.preOperator
        let post = SymbolCharacter.postOperator
        let mid = SymbolCharacter.midOperator
        
        // Replace lastCharacter with pre/post/mid if appropriate
        
        
        var legalCombinations:[Character: String] =
           ["n":"n\(mid))cd\(pre)\(post)",
            "(":"n-cd\(pre)",
            ")":"n)(cd\(pre)\(mid)\(post)",
            "+":"n-+(cd\(pre)",
            "-":"n-+(cd\(pre)",
            mid: "n-(cd\(pre)",
            pre: "n-(cd",
            post:"n-+()cd\(pre)\(mid)\(post)",
            " ":"n-(\(pre)"]

        
        if var theLastCharacter = string.characters.last {
//            print("theLastCharacter: \(theLastCharacter)", appendNewline: true)
            
            if preOperatorCharacters.contains(theLastCharacter) {
                theLastCharacter = pre
            } else if midOperatorCharacters.contains(theLastCharacter) && theLastCharacter != "+" && theLastCharacter != "-" {
                theLastCharacter = mid
            } else if postOperatorCharacters.contains(theLastCharacter) {
                theLastCharacter = post
            }
            
            var lastCharacterGeneric = theLastCharacter
            
            if numberCharacters.contains(theLastCharacter) {
                lastCharacterGeneric = "n"
            }
            
            let combinationReturn = legalCombinations[lastCharacterGeneric]
            
            if let combination = combinationReturn {
                
                // Convert combination into a set of characters
                
                var legalCharacterSet = Set<Character>()
                
//                print("legalCharacterSet: \(legalCharacterSet)", appendNewLine: true)
                
                for character in combination.characters {
                    legalCharacterSet.insert(character)
                }
                
                // Add the pre operators
                if legalCharacterSet.contains(SymbolCharacter.preOperator) {
                    for preOperator in preOperatorCharacters {
                        legalCharacterSet.insert(preOperator)
                    }
                }
                
                // Add the post operators
                if legalCharacterSet.contains(SymbolCharacter.postOperator) {
                    for postOperator in postOperatorCharacters {
                        legalCharacterSet.insert(postOperator)
                    }
                }
                
                // Add the mid operators
                if legalCharacterSet.contains(SymbolCharacter.midOperator) {
                    for midOperator in midOperatorCharacters {
                        legalCharacterSet.insert(midOperator)
                    }
                }
                
                // Add clear
                if legalCharacterSet.contains("c") {
                    legalCharacterSet.insert(SymbolCharacter.clear)
                }
                
                // Add delete
                if legalCharacterSet.contains("d") {
                    legalCharacterSet.insert(SymbolCharacter.delete)
                }
                
                // Add smart bracket
                if legalCharacterSet.contains("(") || legalCharacterSet.contains(")") {
                    legalCharacterSet.insert(SymbolCharacter.smartBracket)
                }
                
                if legalCharacterSet.contains("n") {
                    
                    // Add all the number characters to the set
                    for numberCharacter in numberCharacters {
                        legalCharacterSet.insert(numberCharacter)
                    }
                    
                    // If the lastCharacter is a "n" we need to determine if the end of the string is a number and if that number contains a decimal - if not
                    if lastCharacterGeneric == "n" {
                        let termArray = Evaluator.termArrayFromString(string, allowNonLegalCharacters: false, treatConstantsAsNumbers: false)
                        
                        if let lastTerm = termArray.last {
                            
                            if lastTerm.range(of: ".") != nil {
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
                
                
                print(legalCharacterSet)
                return legalCharacterSet
                
            } else {
                
                return nil
            }

        } else {
            // Something went very very wrong
            return nil
        }
    }
}
