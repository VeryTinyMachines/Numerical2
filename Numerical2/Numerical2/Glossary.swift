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
    public static let e:Character = "e"
    public static let infinity:Character = "∞"
    
    public static let sin:Character = "s"
    public static let cos:Character = "c"
    public static let tan:Character = "t"
    
    public static let sinh:Character = "S"
    public static let cosh:Character = "C"
    public static let tanh:Character = "T"
    
    public static let ee:Character = "E"
    public static let sqrt:Character = "√"
    
    public static let log:Character = "l" // "log(x) in c is what most calculators call "ln"
    public static let log2:Character = "L" // log2(x) in c is what most calculators call "log"
    public static let log10:Character = "N" // TODO - Need a better symbol for this
    
    public static let factorial:Character = "!"
    public static let fraction:Character = "\\"
    public static let percentage:Character = "%"
    public static let random:Character = "r"
    
    public static let preOperator:Character = "⟜"
    public static let postOperator:Character = "⟞"
    public static let midOperator:Character = "⟝"
    
    public static let delete:Character = "⟬"
    public static let clear:Character = "⟭"
    
    public static let smartBracket:Character = "⟠"
    
    public static let divide:Character = "/"
    
    public static let add:Character = "+"
    
    public static let subtract:Character = "-"
    
    public static let multiply:Character = "*"
    public static let exponent:Character = "^"
    
    public static let numbers:Set<Character> = ["0","1","2","3","4","5","6","7","8","9",".",SymbolCharacter.pi, SymbolCharacter.e, SymbolCharacter.infinity, SymbolCharacter.fraction]
    
    public static let operators:Set<Character> = [SymbolCharacter.add, SymbolCharacter.subtract, SymbolCharacter.multiply, SymbolCharacter.divide, SymbolCharacter.exponent, SymbolCharacter.percentage, SymbolCharacter.sin, SymbolCharacter.cos, SymbolCharacter.tan, SymbolCharacter.sinh, SymbolCharacter.cosh, SymbolCharacter.tanh, SymbolCharacter.ee, SymbolCharacter.sqrt, SymbolCharacter.log, SymbolCharacter.log2, SymbolCharacter.log10, SymbolCharacter.factorial, SymbolCharacter.percentage]
    
    public static let preOperatorCharacters:Set<Character> = [SymbolCharacter.cos,SymbolCharacter.log, SymbolCharacter.log10, SymbolCharacter.log2, SymbolCharacter.sin, SymbolCharacter.sqrt, SymbolCharacter.tan, SymbolCharacter.sinh,SymbolCharacter.cosh,SymbolCharacter.tanh]
    
    public static let midOperatorCharacters:Set<Character> = [SymbolCharacter.add, SymbolCharacter.subtract, SymbolCharacter.multiply, SymbolCharacter.divide, SymbolCharacter.exponent, SymbolCharacter.fraction, SymbolCharacter.ee]
    
    public static let postOperatorCharacters:Set<Character> = [SymbolCharacter.factorial, SymbolCharacter.percentage]
    
    public static let preOperatorStringArray:[String] = [String(SymbolCharacter.sqrt), String(SymbolCharacter.sin), String(SymbolCharacter.cos), String(SymbolCharacter.tan), String(SymbolCharacter.log), String(SymbolCharacter.log2), String(SymbolCharacter.log10), String(SymbolCharacter.sinh), String(SymbolCharacter.cosh), String(SymbolCharacter.tanh)]
    
    public static let midOperatorStringArray:[String] = [String(SymbolCharacter.add), String(SymbolCharacter.subtract), String(SymbolCharacter.multiply), String(SymbolCharacter.divide), String(SymbolCharacter.exponent), String(SymbolCharacter.fraction), String(SymbolCharacter.ee)]
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
        SymbolCharacter.add:"+",
        SymbolCharacter.subtract:"-",
        SymbolCharacter.multiply:"×",
        SymbolCharacter.divide:"÷",
        SymbolCharacter.exponent:"^",
        SymbolCharacter.sqrt:"√"
    
    
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
        "÷":SymbolCharacter.divide,
        "×":SymbolCharacter.multiply,
        "^":SymbolCharacter.exponent,
        "+":SymbolCharacter.add,
        "-":SymbolCharacter.subtract
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
        
        if string == ErrorType.divideByZero.rawValue {
            formattedString = "Division By Zero"
        } else if string == ErrorType.imaginaryNumbersRequiredToSolve.rawValue {
            formattedString = "Imaginary Number Required To Solve"
        } else if string == ErrorType.overflow.rawValue {
            formattedString = "Overflow Error"
        } else if string == ErrorType.underflow.rawValue {
            formattedString = "Underflow Error"
        } else if string == ErrorType.unknown.rawValue {
            formattedString = "Error"
        } else {
            for character in string.characters {
                formattedString += formattedStringForCharacter(character)
            }
        }
        
        return formattedString
    }

    /*
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
    */
    
    class func formattedStringForCharacter(_ character: Character) -> String {
        if let formattedChar = self.formattedLookup[character] {
            return String(formattedChar)
        }
        
        return String(character)
    }

    /*
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
    */
    
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
        
        if string == "" || string == String(SymbolCharacter.subtract) {
            return false
        }
        
        var counter = 0
        for character in string.characters {
            
            if counter == 0 && character == SymbolCharacter.subtract {
                // This is a leading - and can be safely ignored
            } else if SymbolCharacter.numbers.contains(character) == false {
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
        
        if string.characters.count > 1 {
            return false
        }
        
        for character in string.characters {
            if SymbolCharacter.operators.contains(character) == false {
                return false
            }
        }
        
        return true
    }
    
    class func isStringInfinity(_ string: String) -> InfinityType {
        let numbers:Set<Character> = [SymbolCharacter.infinity]
        
        if string == "" || string == String(SymbolCharacter.subtract) {
            return InfinityType.notInfinity
        }
        
        var counter = 0
        var negative = false
        
        for character in string.characters {
            
            if counter == 0 && character == SymbolCharacter.subtract {
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
        
        if newOperator == SymbolCharacter.multiply || newOperator == SymbolCharacter.divide {
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
                                
                                if characterOperator == SymbolCharacter.add || characterOperator == SymbolCharacter.subtract {
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
        
        print("legalCharactersToAppendString: \(string)")
        
        var string = string
        
        if string == "" {
            string = " "
        }
        
        let pre = SymbolCharacter.preOperator
        let post = SymbolCharacter.postOperator
        let mid = SymbolCharacter.midOperator
        let clear = Character("Z")
        let delete = Character("X")
        
        // Replace lastCharacter with pre/post/mid if appropriate
        
        var legalCombinations:[Character: String] =
           ["n":"n\(mid))\(clear)\(delete)\(pre)\(post)",
            "(":"n-\(clear)\(delete)\(pre)",
            ")":"n)(\(clear)\(delete)\(pre)\(mid)\(post)",
            "+":"n-+(\(clear)\(delete)\(pre)",
            "-":"n-+(\(clear)\(delete)\(pre)",
            mid: "n-(\(clear)\(delete)\(pre)",
            pre: "n-(\(clear)\(delete)",
            post:"n-+()\(clear)\(delete)\(pre)\(mid)\(post)",
            " ":"n-(\(pre)",
            "?":"n)(\(clear)\(delete)\(pre)\(mid)\(post)"]

        
        if var theLastCharacter = string.characters.last {
            print("theLastCharacter: \(theLastCharacter)")
            
            if SymbolCharacter.preOperatorCharacters.contains(theLastCharacter) {
                theLastCharacter = pre
            } else if SymbolCharacter.midOperatorCharacters.contains(theLastCharacter) && theLastCharacter != SymbolCharacter.add && theLastCharacter != SymbolCharacter.subtract {
                theLastCharacter = mid
            } else if SymbolCharacter.postOperatorCharacters.contains(theLastCharacter) {
                theLastCharacter = post
            }
            
            var lastCharacterGeneric = theLastCharacter
            
            if SymbolCharacter.numbers.contains(theLastCharacter) {
                lastCharacterGeneric = "n"
            }
            
            if let combination = legalCombinations[lastCharacterGeneric] {
                
                print("combination: \(combination)")
                
                // Convert combination into a set of characters
                
                var legalCharacterSet = Set<Character>()
                
//                print("legalCharacterSet: \(legalCharacterSet)", appendNewLine: true)
                
                print("1 legalCharacterSet: \(legalCharacterSet)")
                
                for character in combination.characters {
                    legalCharacterSet.insert(character)
                }
                
                print("2 legalCharacterSet: \(legalCharacterSet)")
                
                // Add the pre operators
                if legalCharacterSet.contains(SymbolCharacter.preOperator) {
                    for preOperator in SymbolCharacter.preOperatorCharacters {
                        legalCharacterSet.insert(preOperator)
                    }
                }
                
                print("3 legalCharacterSet: \(legalCharacterSet)")
                
                // Add the post operators
                if legalCharacterSet.contains(SymbolCharacter.postOperator) {
                    for postOperator in SymbolCharacter.postOperatorCharacters {
                        legalCharacterSet.insert(postOperator)
                    }
                }
                
                print("4 legalCharacterSet: \(legalCharacterSet)")
                
                // Add the mid operators
                if legalCharacterSet.contains(SymbolCharacter.midOperator) {
                    for midOperator in SymbolCharacter.midOperatorCharacters {
                        legalCharacterSet.insert(midOperator)
                    }
                }
                
                print("5 legalCharacterSet: \(legalCharacterSet)")
                
                // Add clear
                if legalCharacterSet.contains(clear) {
                    legalCharacterSet.insert(SymbolCharacter.clear)
                }
                
                print("6 legalCharacterSet: \(legalCharacterSet)")
                
                // Add delete
                if legalCharacterSet.contains(delete) {
                    legalCharacterSet.insert(SymbolCharacter.delete)
                }
                
                print("7 legalCharacterSet: \(legalCharacterSet)")
                
                // Add smart bracket
                if legalCharacterSet.contains("(") || legalCharacterSet.contains(")") {
                    legalCharacterSet.insert(SymbolCharacter.smartBracket)
                }
                
                print("8 legalCharacterSet: \(legalCharacterSet)")
                
                if legalCharacterSet.contains("n") {
                    
                    // Add all the number characters to the set
                    for numberCharacter in SymbolCharacter.numbers {
                        legalCharacterSet.insert(numberCharacter)
                    }
                    
                    // If this is an initial string then get rid of the fraction. That's too dumb.
                    if string == " " {
                        legalCharacterSet.remove(SymbolCharacter.fraction)
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
                
                print("9 legalCharacterSet: \(legalCharacterSet)")
                
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
