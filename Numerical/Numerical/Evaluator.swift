//
//  NUMEvaluator.swift
//  Numerical2
//
//  Created by Andrew J Clark on 24/06/2015.
//  Copyright (c) 2015 Andrew J Clark. All rights reserved.
//

import Foundation

class OperandTerm {
    var operand: Character?
    
    func complete() -> Bool {
        if let _ = operand {
            return true
        } else {
            return false
        }
    }
    
    func processTerm(term: String) -> Bool {
        
        if Glossary.isStringOperator(term) {
            let startIndex = term.startIndex
            let character = term[startIndex]
            operand = character
            return true
        } else {
            reset()
            return false
        }
    }
    
    func stringValue() -> String {
        if let theOperand = operand {
            return String(theOperand)
        } else {
            return ""
        }
    }
    
    func characterValue() -> Character {
        if let theOperand = operand {
            return theOperand
        } else {
            return " "
        }
    }
    
    
    func reset() {
        operand = nil
    }
    
    
}

class NumberTerm {
    var negative = false
    var number: String?
    
    func complete() -> Bool {
        if let _ = number {
            return true
        } else {
            return false
        }
    }
    
    func processTerm(term: String) -> Bool {
        if term == "-" {
            if negative {
                // - and - = +
                negative = false
            } else {
                // + and - = -
                negative = true
            }
            
        } else if term == "+" {
            if negative {
                // - and + = -
                negative = true
            } else {
                // + and + = -
                negative = false
            }
        } else if Glossary.isStringNumber(term) {
            number = term
        } else {
            // Not a valid number
            reset()
            return false
        }
        
        return true
    }
    
    func stringValue() -> String {
        if let theNumber = number {
            if negative {
                return "-" + theNumber
            } else {
                return theNumber
            }
        } else {
            return ""
        }
    }
    
    func reset() {
        negative = false
        number = nil
    }
}



public class Evaluator {
    
    class func balanceBracketsForQuestionDisplay(string: String) -> String {
        
        var pairHeight = 0
        var openBrackets = 0
//        var closeBrackets = 0
        
        for character in string.characters {
            
            if character == "(" {
                pairHeight += 1
            } else if character == ")" {
                if(pairHeight == 0) {
                    
                    openBrackets += 1
                } else {
                    pairHeight -= 1
                }
            }
        }
        
        if pairHeight > 0 {
//            closeBrackets = pairHeight
        }
        
        var newString = ""
        
        if(openBrackets > 0) {
            for _ in 1...openBrackets {
                newString += "("
            }
        }
        
        newString += string
        
//        if (closeBrackets > 0) {
//            for _ in 1...closeBrackets {
//                newString += ")"
//            }
//        }
        
        return newString
    }
    
    
    /*
    class func balanceBracketsInString(string: String) -> String {

        var pairHeight = 0
        var openBrackets = 0
        var closeBrackets = 0
        
        for character in string.characters {
            
            if character == "(" {
                pairHeight += 1
            } else if character == ")" {
                if(pairHeight == 0) {
                    
                    openBrackets += 1
                } else {
                    pairHeight -= 1
                }
            }
        }
        
        if pairHeight > 0 {
            closeBrackets = pairHeight
        }
        
        var newString = ""
        
        if(openBrackets > 0) {
            for _ in 1...openBrackets {
                newString += "("
            }
        }
        
        newString += string
        
        if (closeBrackets > 0) {
            for _ in 1...closeBrackets {
                newString += ")"
            }
        }
        
        return newString
    }
    */
    
    class func solveString(string: String) -> (String?) {
        // First solve the brackets, then solve the string
        
        print("solve string: \(string)", appendNewline: false)
        
        let cleanedString = cleanString(string)
        
        if let bracketsResolvedString = solveBracketsInString(cleanedString) {
            return solveOperatorsInString(bracketsResolvedString)
        } else {
            return nil
        }
        
    }
    
    class func cleanString(string:String) -> String {
        
        // Inserts "*" between brackets and numbers
        
        var termArray = termArrayFromString(string, allowNonLegalCharacters: false)
        
        if termArray.count > 1 {
            var index = 0
            
            while index < termArray.count - 1 {
                let term = termArray[index]
                let nextTerm = termArray[index + 1]
                
                print("term: \(term)  nextTerm: \(nextTerm)", appendNewline: false)
                
                if term == ")" && nextTerm == "(" {
                    termArray.insert("*", atIndex: index + 1)
                } else if term == ")" && Glossary.isStringNumber(nextTerm) {
                    termArray.insert("*", atIndex: index + 1)
                } else if Glossary.isStringNumber(term) && nextTerm == "(" {
                    termArray.insert("*", atIndex: index + 1)
                }
                
                index += 1
            }
            return "".join(termArray)
        }
        
        return string
    }
    
    class func solveBracketsInString(string: String) -> (String?) {
        
        // Iterate through the string and find the ground floor offset - ie. how far "outside" of the string do the brackets go.
        
        let stringToSolve = string
        
        if stringToSolve.characters.contains("(") || string.characters.contains(")") {
            // Determine the heightOffset
            var pairHeight = 0
            var heightOffset = 0
            
            for character in stringToSolve.characters {
                if character == "(" {
                    pairHeight += 1
                } else if character == ")" {
                    pairHeight -= 1
                    
                    if pairHeight < heightOffset {
                        heightOffset = pairHeight
                    }
                }
            }
            
            // Solve any section of the string that ends and begins with height of 0
            
            pairHeight = 0 - heightOffset
            
            var mainBuffer = ""
            var bracketBuffer = ""
            
            for character in stringToSolve.characters {
                if character == "(" {
                    pairHeight += 1
                    
                    if pairHeight > 1 {
                        // This ensures the bracket set we are solving does not become part of the bracketBuffer and thus result in a loop.
                        bracketBuffer.append(character)
                    }
                    
                } else if character == ")" {
                    
                    if pairHeight > 1 {
                        // This ensures the bracket set we are solving does not become part of the bracketBuffer and thus result in a loop.
                        bracketBuffer.append(character)
                    }
                    
                    pairHeight -= 1
                    
                } else {
                    
                    if(pairHeight == 0) {
                        // We are on the ground floor, out of the scope of any brackets.
                        
                        if bracketBuffer.characters.count > 0 {
                            // If there is something in the bracketBuffer then we are ready to solve it.
                            
                            
                            
                            if let answer = solveString(bracketBuffer) {
                                mainBuffer += answer
                            }
                            
                            bracketBuffer = ""
                        }
                        
                        mainBuffer.append(character)
                        
                    } else {
                        // We are in a bracket.
                        bracketBuffer.append(character)
                    }
                }
            }
            
            // Finished, may still have something in bracketBuffer that needs solving
            if bracketBuffer.characters.count > 0 {
                if let answer = solveString(bracketBuffer) {
                    mainBuffer += answer
                }
            }
            
            return mainBuffer

        } else {
            // String does not contain any brackets, so just return it.
            return stringToSolve
        }
    }
    
    
    class func processTermArray(var termArray: Array<String>, theOperator: String, operatorType: OperatorType) -> Array<String>? {
        
        print("processTermArray: \(termArray)", appendNewline: false)
        
        let leftTerm = NumberTerm()
        let operandTerm = OperandTerm()
        let rightTerm = NumberTerm()
        let endPercentage = OperandTerm()
        
        var requireLeftTerm = false
        var requireOperator = false
        var requireRightTerm = false
        var requireEndPercentageTerm = false
//        var requirePostOperator = false
        
        if operatorType == .PreOperator {
            requireOperator = true
            requireRightTerm = true
        } else if operatorType == .MidOperator {
            requireLeftTerm = true
            requireOperator = true
            requireRightTerm = true
        } else if operatorType == .PostOperator {
            requireLeftTerm = true
            requireOperator = true
        } else if operatorType == .PercentageCombine {
            requireLeftTerm = true
            requireOperator = true
            requireRightTerm = true
            requireEndPercentageTerm = true
        }
        
        var counter = 0
        var startIndex = -1
        
        leftTerm.reset()
        operandTerm.reset()
        rightTerm.reset()
        
        
            for term in termArray {
                
//                print("processing term: \(term) with startIndex: \(startIndex)")
                
                if Glossary.isStringNumber(term) || Glossary.isStringOperator(term) {
                    // The term is a valid string or operator
                    
                    if leftTerm.complete() == false && requireLeftTerm {
                        // We are solving the left hand term
                        if leftTerm.processTerm(term) == false {
                            // Processed term and resulted in a reset, therefore we need to reset everything.
                            leftTerm.reset()
                            operandTerm.reset()
                            rightTerm.reset()
                            startIndex = -1
                        } else {
                            // The processed term was accepted, need to set startIndex IF it has not already been set.
                            if startIndex == -1 {
                                startIndex = counter
                            }
                            
                        }
                    } else if operandTerm.complete() == false && requireOperator {
                        
                        // We are searching for theOperator
                        if term == theOperator {
                            // It IS the operand we need.
                            operandTerm.processTerm(term)
                            
                            if operatorType == OperatorType.PreOperator {
                                startIndex = counter
                            }
                        } else {
                            // We needed to find the primary operator but we did not, reset it all
                            leftTerm.reset()
                            operandTerm.reset()
                            rightTerm.reset()
                            startIndex = -1
                        }
                    } else if rightTerm.complete() == false && requireRightTerm {
                        
                        if rightTerm.processTerm(term) == false {
                            // Processed term and resulted in a reset.
                            // However as we are simply waiting for a valid number and will ignore superfluous additional operators we can reset the rightTerm and continue.
                            
                            rightTerm.reset()
                        }
                        
                    } else if endPercentage.complete() == false && requireEndPercentageTerm {
                        
                        if term == String(SymbolCharacter.percentage) {
                            // It IS the operand we need.
                            if endPercentage.processTerm(term) == false {
                                leftTerm.reset()
                                operandTerm.reset()
                                rightTerm.reset()
                                endPercentage.reset()
                                startIndex = -1
                            }
                            
                        } else {
                            // We needed to find the percentage operator but we did not, reset it all
                            leftTerm.reset()
                            operandTerm.reset()
                            rightTerm.reset()
                            endPercentage.reset()
                            startIndex = -1
                        }
                        
                    }
                    
                    if leftTerm.complete() == requireLeftTerm && operandTerm.complete() == requireOperator && rightTerm.complete() == requireRightTerm && endPercentage.complete() == requireEndPercentageTerm && startIndex > -1 {
                        // We now have all the terms we need - solve it!
                        
                        let endIndex = counter
                        
                        var answer:String?
                        
                        if operatorType == OperatorType.MidOperator
                        {
                            answer = solveUnknownNumber(leftTerm.stringValue(), theOperator: operandTerm.characterValue(), numberB: rightTerm.stringValue(), operatorType: operatorType, endPercentage: false)
                        }
                        else if operatorType == OperatorType.PreOperator
                        {
                            answer = solveUnknownNumber(nil, theOperator: operandTerm.characterValue(), numberB: rightTerm.stringValue(), operatorType: operatorType, endPercentage: false)
                        }
                        else if operatorType == OperatorType.PostOperator
                        {
                            answer = solveUnknownNumber(leftTerm.stringValue(), theOperator: operandTerm.characterValue(), numberB: nil, operatorType: operatorType, endPercentage: false)
                        }
                        else if operatorType == OperatorType.PercentageCombine
                        {
                            answer = solveUnknownNumber(leftTerm.stringValue(), theOperator: operandTerm.characterValue(), numberB: rightTerm.stringValue(), operatorType: operatorType, endPercentage: true)
                        }
                        
                        if let theAnswer = answer {
                            
                            let range = Range(start: startIndex, end: endIndex + 1)
                            termArray.removeRange(range)
                            termArray.insert(theAnswer, atIndex: startIndex)
                            
                            // Set the answer as the leftNumber
                            counter = startIndex
                            
                            leftTerm.reset()
                            operandTerm.reset()
                            rightTerm.reset()
                            
                            // Set the leftNumber as the answer
                            leftTerm.processTerm(theAnswer)
                            
                        } else {
                            leftTerm.reset()
                            operandTerm.reset()
                            rightTerm.reset()
                            startIndex = -1
                            
                            return nil
                        }
                    }
                }
                
                counter += 1
            }
        
        // We have reached the end of termArray for the operator supplied to this method. If we have a leftTerm and an operand we should replace from startIndex with the leftTerm
        if operatorType == OperatorType.MidOperator && leftTerm.complete() && operandTerm.complete() && rightTerm.complete() == false && startIndex > -1 {
            let endIndex = counter
            
            let answer = leftTerm.stringValue()
            
            let range = Range(start: startIndex, end: endIndex)
            termArray.removeRange(range)
            termArray.insert(answer, atIndex: startIndex)
        }
        
        return termArray
    }
    
    
    class func solveTermArray(var termArray: Array<String>, var operatorArray: Array<String>, operatorType: OperatorType) -> Array<String>? {
        
        while operatorArray.count > 0 {
            
            if let theOperator = operatorArray.first {
                
                if termArray.contains(theOperator) {
                    if let newTermArray = self.processTermArray(termArray, theOperator: theOperator, operatorType: operatorType) {
                        termArray = newTermArray
                    } else {
                        return nil
                    }
                }
            }
            
            operatorArray.removeAtIndex(0)
        }
        
        return termArray
    }
    
    
    class func solveOperatorsInString(string: String) -> (String?) {
        
        // Convert the string into a termArray
        var termArray = termArrayFromString(string, allowNonLegalCharacters: false)
        
        // Solve PreOperators
        let preOperatorArray = [String(SymbolCharacter.sqrt), String(SymbolCharacter.sin), String(SymbolCharacter.cos), String(SymbolCharacter.tan), String(SymbolCharacter.log), String(SymbolCharacter.log2), String(SymbolCharacter.log10)]
        
        if let newTermArray = solveTermArray(termArray, operatorArray: preOperatorArray, operatorType: OperatorType.PreOperator) {
            termArray = newTermArray
        } else {
            return nil
        }
        
        // This is where we should solve the smart percentage stuff.
        
        // Solve Smart Percentage Operator
        let percentageOperatorArray = ["/", "*", "+" , "-"]
        
        if let newTermArray = solveTermArray(termArray, operatorArray: percentageOperatorArray, operatorType: OperatorType.PercentageCombine) {
            termArray = newTermArray
        } else {
            return nil
        }
        
        
        // Solve PostOperators
        let postOperatorArray = [String(SymbolCharacter.factorial), String(SymbolCharacter.percentage)]
        
        if let newTermArray = solveTermArray(termArray, operatorArray: postOperatorArray, operatorType: OperatorType.PostOperator) {
            termArray = newTermArray
        } else {
            return nil
        }
        
        // Add Multiply's between naked numbers
        termArray = insertMultiplyBetweenNumbers(termArray)
        
        // Solve regular operators
        let operatorArray = [String(SymbolCharacter.ee),"^", "/", "*", "+" , "-"]
        
        if let newTermArray = solveTermArray(termArray, operatorArray: operatorArray, operatorType: OperatorType.MidOperator) {
            termArray = newTermArray
        } else {
            return nil
        }
        
        
        return cleanUpAnswer(termArray)
    }
    
    
    
    class func reduceFraction(string: String) -> String? {
        
        let components = fractionComponents(string)
        
        let numerator = NSDecimalNumber(string: components.numerator).doubleValue
        let denominator = NSDecimalNumber(string: components.denominator).doubleValue
        
        print("Original Answer: \(numerator) over \(denominator)", appendNewline: false)
        
        if numerator % 1 == 0 && denominator % 1 == 0 {
            // These are whole numbers
            
            if denominator == 1 {
                return components.numerator
            } else if denominator == 0 {
                let infinity = SymbolCharacter.infinity
                
                if numerator > 0 {
                    return "\(infinity)"
                } else if numerator < 0 {
                    return "-\(infinity)"
                } else {
                    // Numerator and denominator are 0.
                    return "NaN"
                }
            } else {
                // Reduce this denominator
                
                var u = Int(numerator)
                var v = Int(denominator)
                
                while v > 0 {
                    print("v: \(v)", appendNewline: false)
                    let temp = u % v
                    u = v
                    v = temp
                }
                
                let numeratorAnswer = Int(numerator) / u
                let denominatorAnswer = Int(denominator) / u
                
                print("Reduced Answer: \(numeratorAnswer) over \(denominatorAnswer)", appendNewline: false)
                
                let fraction = SymbolCharacter.fraction
                
                return "\(numeratorAnswer)\(fraction)\(denominatorAnswer)"
                
                
            }
        }
        
        return nil
    }
    
    class func reduceFraction(string: String, minimumDenominatorA: Int, minimumDenominatorB: Int) -> String? {
        
        let components = fractionComponents(string)
        
        let numerator = NSDecimalNumber(string: components.numerator).doubleValue
        let denominator = NSDecimalNumber(string: components.denominator).doubleValue
        
        print("Original Answer: \(numerator) over \(denominator)", appendNewline: false)
        
        if numerator % 1 == 0 && denominator % 1 == 0 {
            // These are whole numbers
            
            if denominator == 1 {
                return components.numerator
            } else if denominator == 0 {
                let infinity = SymbolCharacter.infinity
                
                if numerator > 0 {
                    return "\(infinity)"
                } else if numerator < 0 {
                    return "-\(infinity)"
                } else {
                    // Numerator and denominator are 0.
                    return "NaN"
                }
            } else {
                // Reduce this denominator
                
                var reduceFactorA = 1;
                var reduceFactorB = 1;
                
                let numeratorInt = Int(numerator)
                let denominatorInt = Int(denominator)
                
                // Need to find out IF this numerator and denominator can be reduced to either of the supplied minimum Denominators, and pick the lowest one
                
                // minimumDenominatorA
                
                if numeratorInt % minimumDenominatorA  == 0 {
                    if denominatorInt % minimumDenominatorA == 0 {
                        reduceFactorA = denominatorInt / minimumDenominatorA
                    }
                }
                
                if numeratorInt % minimumDenominatorB  == 0 {
                    if denominatorInt % minimumDenominatorB == 0 {
                        reduceFactorB = denominatorInt / minimumDenominatorB
                    }
                }
                
                
                var reduceFactor = 1
                
                if reduceFactorA > reduceFactorB {
                    reduceFactor = reduceFactorB
                } else {
                    reduceFactor = reduceFactorA
                }
                
                let numeratorAnswer = Int(numerator) / reduceFactor
                let denominatorAnswer = Int(denominator) / reduceFactor
                
                if denominatorAnswer == minimumDenominatorA || denominatorAnswer == minimumDenominatorB {
                    let fraction = SymbolCharacter.fraction
                    print("Reduced Answer: \(numeratorAnswer) over \(denominatorAnswer)", appendNewline: false)
                    return "\(numeratorAnswer)\(fraction)\(denominatorAnswer)"
                } else {
                    return nil
                }
            }
        }
        
        return nil
    }
    
    
    class func insertMultiplyBetweenNumbers(var termArray: Array<String>) -> Array<String> {
        var lastTerm:String?
        
        var counter = 0
        
        for term in termArray {
            
            if let theLastTerm = lastTerm {
                
                // We have a term and a lastTerm check if they are both numbers, if they are insert a "*"
                if Glossary.isStringNumber(term) && Glossary.isStringNumber(theLastTerm) {
                    // They are both numbers
                    
                    termArray.insert("*", atIndex: counter)
                    counter += 1
                }
            }
            
            lastTerm = term
            counter += 1
        }
        
        return termArray
    }
    
    class func cleanUpAnswer(termArray: Array<String>) -> String? {
        if termArray.count > 1 {
            
            // The remaining terms may still be resolvable into a single number, for example: "-", "10" should become "-10"
            // Iterate through the remaining terms and see if a single NumberTerm can be found.
            
            let remainingTerm = NumberTerm()
            
            for term in termArray {
                if remainingTerm.processTerm(term) == false {
                    // Processed term and resulted in a reset, therefore we cannot resolve the remaining terms into a single number
                    break
                }
            }
            
            if remainingTerm.complete() {
                // The remaining terms were resolvable into a single number.
                
                // Need to process number by adding it to 0, this will turn any special symbols into their string values.
                let answer = remainingTerm.stringValue()
                
                return Glossary.replaceConstant(answer)
                
            } else {
                // Remaining terms were NOT resolvable. Abort.
                return nil
            }
            
        } else if termArray.count == 0 {
            return "0"
        } else {
            // We have a single term for the answer. If it is a number we should return it. If it is an operator however we should NOT return it. An operator on it's own is an error.
            
            if let term = termArray.first {
                
                if Glossary.isStringNumber(term) {
                    
                    return Glossary.replaceConstant(term)
                    
                    // Need to process number by adding it to 0, this will turn any special symbols into their string values.
//                    return solveUnknownNumber(term, theOperator: "+", numberB: "0", operatorType: OperatorType.MidOperator, endPercentage: false)
                } else {
                    return nil
                }
            } else {
                return nil
            }
        }
    }
    
    
    class func termArrayFromString(string: String, allowNonLegalCharacters: Bool) -> (Array<String>) {
        
//        print("string: \(string)")
        
        // Divide the string into terms and solve.
        var terms = [String]()
        
        var evaluationString = string
        
        var lastTermType = TermType.Unknown
        
        
        while evaluationString.characters.count > 0 {
            
            let startIndex = evaluationString.startIndex
            let character = evaluationString[startIndex]
            
            let operatorSet: Set<Character> = Set(["+","-","*","/","^","%","(",")",SymbolCharacter.sin, SymbolCharacter.cos, SymbolCharacter.tan, SymbolCharacter.ee, SymbolCharacter.sqrt, SymbolCharacter.log, SymbolCharacter.log2, SymbolCharacter.log10, SymbolCharacter.factorial, SymbolCharacter.pi, SymbolCharacter.e, SymbolCharacter.infinity, SymbolCharacter.percentage])
            
            let numberSet = Set([Character("1"),Character("2"),Character("3"),Character("4"),Character("5"),Character("6"),Character("7"),Character("8"),Character("9"),Character("0"),Character("."),SymbolCharacter.fraction])
            
            if(operatorSet.contains(character)) {
                // It's an operator
                
                // Add it as a new object to the array, and make a new line
                
                let newString = String(character)
                
                terms.append(newString)
                
                lastTermType = .Operator
                
                
            } else if numberSet.contains(character) {
                
                // It's a number
                
                // Append it to the last object in the array, or make it a new term
                
                if lastTermType != .Number {
                    terms.append("")
                }
                
                if var lastTerm = terms.last {
                    
                    lastTerm.append(character)
                    terms.removeLast()
                    terms.append(lastTerm)
                    
                } else {
                    // This is the first term being added
                    let newString = String(character)
                    
                    terms.append(newString)
                }
                
                
                
                
                lastTermType = .Number
                
            } else if allowNonLegalCharacters {
                // Invalid Character - Just skip it
                
                if character == " " {
                    terms.append("")
                } else {
                    
                    if lastTermType != .Unknown {
                        terms.append("")
                    }
                    
                    if var lastTerm = terms.last {
                        
                        lastTerm.append(character)
                        terms.removeLast()
                        terms.append(lastTerm)
                        
                    } else {
                        // This is the first term being added
                        let newString = String(character)
                        
                        terms.append(newString)
                    }
                }
                
                lastTermType = .Unknown
            }
            
            let newStartIndex = advance(evaluationString.startIndex, 1)
            let newEndIndex = evaluationString.endIndex
            
            evaluationString = evaluationString.substringWithRange(newStartIndex..<newEndIndex)
        }
        
        print("terms: \(terms)", appendNewline: false)
        
        return terms
    }
    
    
    
    class func solveUnknownNumber(numberA: String?, theOperator: Character?, numberB: String?, operatorType: OperatorType, endPercentage: Bool) -> String? {
        // Determine if any number here is a fraction, if not send it to solveNonFraction
        
        var fractionFound = false
        
        if let theNumberA = numberA {
            if Glossary.isStringFractionNumber(theNumberA) {
                fractionFound = true
            }
        }
        
        if let theNumberB = numberB {
            if Glossary.isStringFractionNumber(theNumberB) {
                fractionFound = true
            }
        }
        
        if fractionFound {
            // Solve with fraction solver
            
            if let fractionAnswer = solveFraction(numberA, theOperator: theOperator, numberB: numberB, operatorType: operatorType, endPercentage: endPercentage) {
                
                // We have a fraction answer. Let's first try and reduce it to one of numberA's denominator (if it has one)
                
                var fractionA:Int = 1
                var fractionB:Int = 1
                
                
                let theNumberA = fractionComponents(numberA!)
                let theNumberB = fractionComponents(numberB!)
                
                // Convert these numbers into Ints if possible.
                
                let numberFormatter = NSNumberFormatter()
                
                if Glossary.isStringInteger(theNumberA.denominator) {
                    if let number = numberFormatter.numberFromString(theNumberA.denominator) {
                        fractionA = number.integerValue
                    }
                }
                
                if Glossary.isStringInteger(theNumberB.denominator) {
                    if let number = numberFormatter.numberFromString(theNumberB.denominator) {
                        fractionB = number.integerValue
                    }
                }
                
                if fractionA == 1 {
                    fractionA == fractionB
                }
                
                if fractionB == 1 {
                    fractionB == fractionA
                }
                
                
                // ZZZ
                print("fractionA: \(fractionA)  fractionB: \(fractionB)", appendNewline: false)
                
                if let reducedAnswer = reduceFraction(fractionAnswer, minimumDenominatorA: fractionA, minimumDenominatorB: fractionB) {
                    return reducedAnswer
                } else {
                    return fractionAnswer
                }
            } else {
                return nil
            }
            
        } else {
            // Solve with non fraction solver
            return solveNonFraction(numberA, theOperator: theOperator, numberB: numberB, operatorType: operatorType, endPercentage: endPercentage)
        }
        
    }
    
    
    class func solveFraction(numberA: String?, theOperator: Character?, numberB: String?, operatorType: OperatorType, endPercentage: Bool) -> String? {
        
        
        print("solveFraction \(numberA) \(theOperator) \(numberB) ", appendNewline: false)
        
        if operatorType == OperatorType.MidOperator, let theNumberA = numberA, theNumberB = numberB, fractionOperator = theOperator {
            // This is a Midoperator and we have 2 valid strings.
            
//            fractionA = fractionComponents(numberA), fractionB = fractionComponents(numberB) {
            
            let fractionA =  fractionComponents(theNumberA)
            let fractionB =  fractionComponents(theNumberB)
            
            print("fractionA: \(fractionA)", appendNewline: false)
            print("fractionB: \(fractionB)", appendNewline: false)
            
            if fractionOperator == "+" || fractionOperator == "-" {
                
                // Add: a/b + c/d = (a * c + b * d) / (b * d)
                // Subtract: a/b - c/d = (a * c - b * d) / (b * d)
                
                if let topNumber = solveString("\(fractionA.numerator)*\(fractionB.denominator)\(fractionOperator)\(fractionA.denominator)*\(fractionB.numerator)"), bottomNumber = solveString("\(fractionA.denominator)*\(fractionB.denominator)") {
                    
                    return "\(topNumber)\(SymbolCharacter.fraction)\(bottomNumber)"
                } else {
                    return nil
                }
                
            } else if fractionOperator == "*" {
                // Multiply: a/b * c/d = (a * c) / (b * d)
                
                if let topNumber = solveString("\(fractionA.numerator)*\(fractionB.numerator)"), bottomNumber = solveString("\(fractionA.denominator)*\(fractionB.denominator)") {
                    
                    return "\(topNumber)\(SymbolCharacter.fraction)\(bottomNumber)"
                } else {
                    return nil
                }
            } else if fractionOperator == "/" {
                // Multiply: a/b / c/d = a*d/b*c
                
                if let topNumber = solveString("\(fractionA.numerator)*\(fractionB.denominator)"), bottomNumber = solveString("\(fractionA.denominator)*\(fractionB.numerator)") {
                    
                    return "\(topNumber)\(SymbolCharacter.fraction)\(bottomNumber)"
                } else {
                    return nil
                }
            }
        } else if operatorType == OperatorType.PercentageCombine, let theNumberA = numberA, let theNumberB = numberB {
                
                // Solve Percentage Combine
                
            if theOperator == "+" {
                return solveString("\(theNumberA)+(\(theNumberA)*\(theNumberB)/100)")
            } else if theOperator == "-" {
                return solveString("\(theNumberA)-(\(theNumberA)*\(theNumberB)/100)")
            } else if theOperator == "*" {
                return solveString("\(theNumberA)*(\(theNumberB)/100)")
            } else if theOperator == "/" {
                return solveString("\(theNumberA)/(\(theNumberB)/100)")
            }
        }
            
    
            
            
        // We couldn't solve this using fraction specific math. Resolve the incoming numbers into decimals and solve
        
        
        var decimalFractionA:String?
        var decimalFractionB:String?
        
        if let theNumberA = numberA {
            decimalFractionA = decimalFromFraction(theNumberA)
        }
        
        if let theNumberB = numberB {
            decimalFractionB = decimalFromFraction(theNumberB)
        }
        
        return solveUnknownNumber(decimalFractionA, theOperator: theOperator, numberB: decimalFractionB, operatorType: operatorType, endPercentage: endPercentage)
    }
    
    
    class func decimalFromFraction(number: String) -> String? {
        
        let theComponents = fractionComponents(number)
        
        if let decimalForm = solveUnknownNumber(theComponents.numerator, theOperator: "/", numberB: theComponents.denominator, operatorType: OperatorType.MidOperator, endPercentage: false) {
            return decimalForm
        } else {
            return nil
        }
    }
    
    
    class func fractionComponents(number: String) -> (numerator: String, denominator: String) {
        
        if number == "0" {
            return ("0","1")
        }
        
        var components = number.componentsSeparatedByString(String(SymbolCharacter.fraction))
        
        if components.count == 0 {
            return ("0","1")
        } else if components.count == 1 {
            return (number, "1")
        } else if components.count == 2 {
            if components[1] == "" {
                return (components[0], "1")
            } else {
                return (components[0], components[1])
            }
        } else {
            // We have more than 2 components, need to convert into a series of mulitplies: 1/c and solve.
            // For example: 1 over 2 over 3 over 4 = 1 over (2*3*4)
            
            while components.count > 2 {
                // Multiply [1] and [2]
                
                let numberA = components[1]
                let numberB = components[2]
                
                components.removeAtIndex(1)
                components.removeAtIndex(1)
                
                if let newAnswer = solveUnknownNumber(numberA, theOperator: "*", numberB: numberB, operatorType: OperatorType.MidOperator, endPercentage: false) {
                    components.insert(newAnswer, atIndex: 1)
                } else {
                    // Could not resolve
                    print("Could not resolve multi-part fraction", appendNewline: false)
                    break
                }
            }
            
            // We should now have 2 components
            
            if components.count == 2 {
                return (components[0], components[1])
            }
        }
        
        
        
        return ("","")
    }
    
    class func solveNonFraction(numberA: String?, theOperator: Character?, numberB: String?, operatorType: OperatorType, endPercentage: Bool) -> String? {
        
        
        var infinityFound = false
        
        if let theNumberA = numberA {
            if Glossary.isStringInfinity(theNumberA) != InfinityType.NotInfinity {
                infinityFound = true
            }
        }
        
        if let theNumberB = numberB {
            if Glossary.isStringInfinity(theNumberB) != InfinityType.NotInfinity {
                infinityFound = true
            }
        }
        
        if infinityFound {
            // Solve with infinity solver
            return solveInfinity(numberA, theOperator: theOperator, numberB: numberB, operatorType: operatorType, endPercentage: endPercentage)
        } else {
            // Solve with real number solver
            return solveRealNumber(numberA, theOperator: theOperator, numberB: numberB, operatorType: operatorType, endPercentage: endPercentage)
        }
    }
    
    class func solveInfinity(var numberA: String?, theOperator: Character?, var numberB: String?, operatorType: OperatorType, endPercentage: Bool) -> String? {
        
        numberA = Glossary.replaceConstant(numberA)
        numberB = Glossary.replaceConstant(numberB)
        
//        if let theNumberA = numberA {
//            if theNumberA == String(SymbolCharacter.e) {
//                numberA = SymbolConstant.eulerValue
//            } else if theNumberA == String(SymbolCharacter.pi) {
//                numberA = SymbolConstant.piValue
//            }
//            
//            
//        }
//        
//        if let theNumberB = numberB {
//            if theNumberB == String(SymbolCharacter.e) {
//                numberB = SymbolConstant.eulerValue
//            } else if theNumberB == String(SymbolCharacter.pi) {
//                numberB = SymbolConstant.piValue
//            }
//        }
//        
        
        var theNumberA = ""
        var theNumberB = ""
        
        if let newA = numberA {
            theNumberA = newA
        }
        
        if let newB = numberB {
            theNumberB = newB
        }
        
        
        
        var leftDouble:Double = 0.0
        var rightDouble:Double = 0.0
        
        var answer:Double?
        
        print("evaluateInfinityStringNumber: \(numberA) \(theOperator) \(numberB)", appendNewline: false)
        
        print("numberA: \(numberA)", appendNewline: false)
        print("numberB: \(numberB)", appendNewline: false)
        
        if Glossary.isStringInfinity(theNumberA) == InfinityType.Positive {
            leftDouble = Double.infinity
        } else if Glossary.isStringInfinity(theNumberA) == InfinityType.Negative {
            leftDouble = Double.infinity * -1
        } else {
            leftDouble = NSDecimalNumber(string: theNumberA).doubleValue
        }
        
        if Glossary.isStringInfinity(theNumberB) == InfinityType.Positive {
            rightDouble = Double.infinity
        } else if Glossary.isStringInfinity(theNumberB) == InfinityType.Negative {
            rightDouble = Double.infinity * -1
        } else {
            rightDouble = NSDecimalNumber(string: theNumberB).doubleValue
        }
        
        if theOperator == "+" {
            answer = leftDouble + rightDouble
        } else if theOperator == "-" {
            answer = leftDouble - rightDouble
        } else if theOperator == "*" {
            answer = leftDouble * rightDouble
        } else if theOperator == "/" {
            answer = leftDouble / rightDouble
        } else if theOperator == "^" {
            answer = pow(leftDouble, rightDouble)
        } else if theOperator == SymbolCharacter.factorial {
            // Post Operator == Factorial
            answer = tgamma(leftDouble + 1) // Note: If leftDouble < 0 this is NaN
            
        } else if theOperator == SymbolCharacter.sin {
            // Pre Operator
            answer = sin(rightDouble)
        } else if theOperator == SymbolCharacter.cos {
            answer = cos(rightDouble)
        } else if theOperator == SymbolCharacter.tan {
            answer = tan(rightDouble)
        } else if theOperator == SymbolCharacter.sqrt {
            answer = sqrt(rightDouble)
        } else if theOperator == SymbolCharacter.ee {
            
            let exponentResult = pow(10, rightDouble)
            answer = leftDouble * exponentResult
        } else if theOperator == SymbolCharacter.log {
            answer = log(rightDouble)
        } else if theOperator == SymbolCharacter.log2 {
            answer = log2(rightDouble)
        } else if theOperator == SymbolCharacter.log10 {
            answer = log10(rightDouble)
        } else {
            return nil
        }
        
        print("answer: \(answer)", appendNewline: false)
        
        let infinitySymbol = SymbolCharacter.infinity
        
        if let theAnswer = answer {
            
            if theAnswer == Double.infinity {
                
                print("theAnswer == Double.infinity", appendNewline: false)
                return "\(infinitySymbol)"
                
            } else if theAnswer == Double.infinity * -1 {
                print("theAnswer == Double.infinity * -1", appendNewline: false)
                return "-\(infinitySymbol)"
            } else {
                print("theAnswer", appendNewline: false)
                return "\(theAnswer)"
            }
            
        } else {
            return nil
        }
    }
    
    
    class func solveRealNumber(var numberA: String?, theOperator: Character?, var numberB: String?, operatorType: OperatorType, endPercentage: Bool) -> String? {
        
        let errorHandler = DefaultErrorHandler()
        
//        if let theNumberA = numberA {
//            if theNumberA == String(SymbolCharacter.e) {
//                numberA = SymbolConstant.eulerValue
//            } else if theNumberA == String(SymbolCharacter.pi) {
//                numberA = SymbolConstant.piValue
//            }
//            
//            
//        }
//        
//        if let theNumberB = numberB {
//            if theNumberB == String(SymbolCharacter.e) {
//                numberB = SymbolConstant.eulerValue
//            } else if theNumberB == String(SymbolCharacter.pi) {
//                numberB = SymbolConstant.piValue
//            }
//        }
        numberA = Glossary.replaceConstant(numberA)
        numberB = Glossary.replaceConstant(numberB)
        
        
        if operatorType == OperatorType.MidOperator, let theNumberA = numberA, theNumberB = numberB {
            
            let leftDecimalNumber = NSDecimalNumber(string: theNumberA)
            let rightDecimalNumber = NSDecimalNumber(string: theNumberB)
            
//            print("leftDecimalNumber: \(leftDecimalNumber)")
//            print("rightDecimalNumber: \(rightDecimalNumber)")
//            
            if theOperator == "+" {
                
                let result = leftDecimalNumber.decimalNumberByAdding(rightDecimalNumber, withBehavior: errorHandler)
                
//                print("result: \(result)")
                
                return result.stringValue
                
            } else if theOperator == "-" {
                
                let result = leftDecimalNumber.decimalNumberBySubtracting(rightDecimalNumber, withBehavior: errorHandler)
                
                return result.stringValue
                
            } else if theOperator == "*" {
                
                let result = leftDecimalNumber.decimalNumberByMultiplyingBy(rightDecimalNumber, withBehavior: errorHandler)
                
                return result.stringValue
                
            } else if theOperator == "/" {
                
                if rightDecimalNumber == NSDecimalNumber.zero() {
                    return (nil)
                } else {
                    let result = leftDecimalNumber.decimalNumberByDividingBy(rightDecimalNumber, withBehavior: errorHandler)
                    
                    return result.stringValue
                }
            } else if theOperator == "^" {
                
                if rightDecimalNumber.doubleValue % 1 == 0 && rightDecimalNumber.doubleValue > 0 {
                    // Whole number
                    
                    let result = leftDecimalNumber.decimalNumberByRaisingToPower(rightDecimalNumber.integerValue, withBehavior: errorHandler)
                    
                    return result.stringValue
                    
                } else {
                    // Fractional power of
                    
                    let result = pow(leftDecimalNumber.doubleValue, rightDecimalNumber.doubleValue)
                    
                    // If the leftDecimalNumber is negative this results in NaN as it requires imaginary numbers to evaluate this.
                    
                    if leftDecimalNumber.doubleValue < 0 {
                        
                        return nil
                        
                    } else {
                        
                        print("result as double: \(result)", appendNewline: false)
                        
                        let resultNumber = NSDecimalNumber(double: result)
                        
                        return resultNumber.stringValue
                        
                    }
                    
                }
            } else if theOperator == SymbolCharacter.ee {
                
                // First work out 10 ^ numberB
                if let exponentStepResult = solveUnknownNumber("10", theOperator: "^", numberB: theNumberB, operatorType: OperatorType.MidOperator, endPercentage: false) {
                    // Then multiply that result * 10
                if let result = solveUnknownNumber(theNumberA, theOperator: "*", numberB: exponentStepResult, operatorType: OperatorType.MidOperator, endPercentage: false) {
                        return result
                    }
                }
            }
            
            
        } else if operatorType == OperatorType.PreOperator, let theNumberB = numberB {
            // Pre Operator Solutions
            
            let rightDecimalNumber = NSDecimalNumber(string: theNumberB)
            
            if theOperator == SymbolCharacter.sin {
                // Sin
                let result = sin(rightDecimalNumber.doubleValue)
                let resultNumber = NSNumber(double: result)
                return resultNumber.stringValue
                
            } else if theOperator == SymbolCharacter.cos {
                // Cos
                let result = cos(rightDecimalNumber.doubleValue)
                let resultNumber = NSNumber(double: result)
                return resultNumber.stringValue
                
            } else if theOperator == SymbolCharacter.tan {
                // Tan
                let result = tan(rightDecimalNumber.doubleValue)
                let resultNumber = NSNumber(double: result)
                return resultNumber.stringValue
                
            }  else if theOperator == SymbolCharacter.sqrt {
                // Squareroot
                let result = sqrt(rightDecimalNumber.doubleValue)
                let resultNumber = NSNumber(double: result)
                return resultNumber.stringValue
                
            } else if theOperator == SymbolCharacter.log2 {
                // Log2
                let result = log2(rightDecimalNumber.doubleValue)
                let resultNumber = NSNumber(double: result)
                return resultNumber.stringValue
                
            } else if theOperator == SymbolCharacter.log10 {
                // Log10
                let result = log10(rightDecimalNumber.doubleValue)
                let resultNumber = NSNumber(double: result)
                return resultNumber.stringValue
                
            } else if theOperator == SymbolCharacter.log {
                // Log
                let result = log(rightDecimalNumber.doubleValue)
                let resultNumber = NSNumber(double: result)
                return resultNumber.stringValue
            }
        } else if operatorType == OperatorType.PostOperator, let theNumberA = numberA {
            
            let leftDecimalNumber = NSDecimalNumber(string: theNumberA)
            
            if theOperator == SymbolCharacter.factorial {
                // Factorial
                
                let result = tgamma(leftDecimalNumber.doubleValue + 1)
                let resultNumber = NSNumber(double: result)
                return resultNumber.stringValue
                
            } else if theOperator == SymbolCharacter.percentage {
                
                
                let percentageNumber = NSDecimalNumber(integer: 100)
                let result = leftDecimalNumber.decimalNumberByDividingBy(percentageNumber, withBehavior: errorHandler)
                
                return result.stringValue
                
            }
        } else if operatorType == OperatorType.PercentageCombine, let theNumberA = numberA, let theNumberB = numberB {
            
            // Solve Percentage Combine
            
            if theOperator == "+" {
                return solveString("\(theNumberA)+(\(theNumberA)*\(theNumberB)/100)")
            } else if theOperator == "-" {
                return solveString("\(theNumberA)-(\(theNumberA)*\(theNumberB)/100)")
            } else if theOperator == "*" {
                return solveString("\(theNumberA)*(\(theNumberB)/100)")
            } else if theOperator == "/" {
                return solveString("\(theNumberA)/(\(theNumberB)/100)")
            }
        }
        
        return nil
    }
}



class DefaultErrorHandler : NSDecimalNumberBehaviors {
    @objc func exceptionDuringOperation(operation: Selector, error: NSCalculationError, leftOperand: NSDecimalNumber, rightOperand: NSDecimalNumber?) -> NSDecimalNumber? {
        
        return nil
    }
    
    @objc func roundingMode() -> NSRoundingMode {
        return NSRoundingMode.RoundPlain
    }
    
    @objc func scale() -> Int16 {
        return 16
    }
}




