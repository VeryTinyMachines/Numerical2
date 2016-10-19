//
//  NaturalLanguageParser.swift
//  Numerical2
//
//  Created by Andrew J Clark on 27/07/2015.
//  Copyright © 2015 Andrew J Clark. All rights reserved.
//

import Foundation

open class NaturalLanguageParser {
    
    var singleTermDictionary = [String: String]()
    
    var legalCharacters = Set<Character>()
    
    static let sharedInstance = NaturalLanguageParser()
    fileprivate init() {
    
//        print("", appendNewline: true)
        
        /*
        for character in " abcdefghijklmnopqrstuvwxyz".characters {
            legalCharacters.insert(character)
        }
        
        // Load the dictionary
        singleTermDictionary = [String: String]()
        
        if let filePath = Bundle.main.path(forResource: "Dictionary_English", ofType: "plist") {
            if let myDict = NSDictionary(contentsOfFile: filePath) as? [String:Array<String>] {
                for (outputTerm,inputTermArray) in myDict {
                    
                    singleTermDictionary[outputTerm] = outputTerm
                    
                    // Add the output term characters to legalCharacters
                    for character in outputTerm.characters {
                        legalCharacters.insert(character)
                    }
                    
                    
                    for inputTerm in inputTermArray {
                        
                        singleTermDictionary[inputTerm] = outputTerm
                        
                        // Add the characters from inputTerm to the legalCharacters set
                        for character in inputTerm.characters {
                            legalCharacters.insert(character)
                        }
                    }
                }
            } else {
//                print("Error: Dictionary could not be loaded", appendNewline: false)
            }
        }
        */
        
        // Setup a legal character array
        
//        print("legalCharacters: \(legalCharacters)", appendNewline: true)
        
        
    }
    
    
    public func translateString(_ string: String) -> String? {
        var string = string
        
        // Remove any instances of double spaces
        
        while string.range(of: "  ") != nil {
            string = string.replacingOccurrences(of: "  ", with: " ")
        }
        
        
        print("string: \(string)")
        
        
        
        // Remove non legal characters
        
        var newString = ""
        
        for character in string.characters {
            
            if legalCharacters.contains(character) {
                newString.append(character)
            }
            
        }
        
        string = newString
        
        var wordArray = Evaluator.termArrayFromString(string.lowercased(), allowNonLegalCharacters: true, treatConstantsAsNumbers: false)
        
//        print("wordArray: \(wordArray)", appendNewline: false)
        
        // Check that any five word combo's do not need to be replaced
        
        if wordArray.count > 4 {
            for var index in 0...wordArray.count - 4 {
                
                if index < wordArray.count - 4 {
                    
                    let word = wordArray[index]
                    let nextWord = wordArray[index + 1]
                    let finalWord = wordArray[index + 2]
                    let lastWord = wordArray[index + 3]
                    let fifthWord = wordArray[index + 4]
                    
                    print("index: \(index)  word: \(word) \(nextWord)")
                    
                    let phrase = "\(word) \(nextWord) \(finalWord) \(lastWord) \(fifthWord)"
                    
                    if let result = singleTermDictionary[phrase] {
                        let newRange = (index ..< index + 5)
                        wordArray.replaceSubrange(newRange, with: [result])
                        index -= 1
                    }
                }
            }
        }
        
        // Check that any four word combo's do not need to be replaced
        
        if wordArray.count > 3 {
            for var index in 0...wordArray.count - 3 {
                
                if index < wordArray.count - 3 {
                    
                    let word = wordArray[index]
                    let nextWord = wordArray[index + 1]
                    let finalWord = wordArray[index + 2]
                    let lastWord = wordArray[index + 3]
                    
                    print("index: \(index)  word: \(word) \(nextWord)")
                    
                    let phrase = "\(word) \(nextWord) \(finalWord) \(lastWord)"
                    
                    if let result = singleTermDictionary[phrase] {
                        let newRange = (index ..< index + 4)
                        wordArray.replaceSubrange(newRange, with: [result])
                        index -= 1
                    }
                }
            }
        }
        
        
        // Check that any three word combo's do not need to be replaced
        
        if wordArray.count > 2 {
            for var index in 0...wordArray.count - 2 {
                
                if index < wordArray.count - 2 {
                    
                    let word = wordArray[index]
                    let nextWord = wordArray[index + 1]
                    let finalWord = wordArray[index + 2]
                    
                    print("index: \(index)  word: \(word) \(nextWord)")
                    
                    let phrase = "\(word) \(nextWord) \(finalWord)"
                    
                    if let result = singleTermDictionary[phrase] {
                        let newRange = (index ..< index + 3)
                        wordArray.replaceSubrange(newRange, with: [result])
                        index -= 1
                    }
                }
            }
        }
        
        // Check that any two word combo's do not need to be replaced
        if wordArray.count > 1 {
            for var index in 0...wordArray.count - 1 {
                
                if index < wordArray.count - 1 {
                    
                    let word = wordArray[index]
                    let nextWord = wordArray[index + 1]
                    
                    print("index: \(index)  word: \(word) \(nextWord)")
                    
                    let phrase = "\(word) \(nextWord)"
                    
                    if let result = singleTermDictionary[phrase] {
                        let newRange = (index ..< index + 2)
                        wordArray.replaceSubrange(newRange, with: [result])
                        index -= 1
                    }
                }
            }
        }
        
        print("wordArray: \(wordArray)")
        
        var newTermArray:[String] = []
        
        for word in wordArray {
            if let result = singleTermDictionary[word] {
                newTermArray.append(result)
            } else if Glossary.isStringNumber(word) {
                newTermArray.append(word)
            }
        }
        
        // If there is the word teen proceeded by a single digit number convert the digit number into a teen number
        
//        print("newTermArray: \(newTermArray)", appendNewline: false)
        
        if newTermArray.count > 0 {
            var index = 0
            while index < newTermArray.count - 1 {
                let word = newTermArray[index]
                let nextWord = newTermArray[index + 1]
                
                // If number followed by "." combine into single number.
                if nextWord == "." && Glossary.isStringNumber(word) {
                    let newRange = (index ..< index + 2)
                    let newNumber = "\(word)\(nextWord)"
                    newTermArray.replaceSubrange(newRange, with: [newNumber])
                    //                index -= 1
                    continue
                }
                
                // If number followed by number combine into single number.
                if Glossary.stringContainsDecimal(word) && Glossary.isStringNumber(nextWord) {
                    let newRange = (index ..< index + 2)
                    let newNumber = "\(word)\(nextWord)"
                    newTermArray.replaceSubrange(newRange, with: [newNumber])
                    //                index -= 1
                    continue
                }
                
                // If single number followed by word teen make into a teenage number.
                if word.characters.count == 1 && Glossary.isStringNumber(word) && nextWord == "teen" {
                    let newRange = (index ..< index + 2)
                    let newNumber = "1\(word)"
                    newTermArray.replaceSubrange(newRange, with: [newNumber])
                    //                index -= 1
                    continue
                }
                
                // Convert number into hundred
                if Glossary.isStringNumber(word) && nextWord == "hundred" {
                    let newRange = (index ..< index + 2)
                    
                    let answerBundle = Evaluator.solveUnknownNumber(word, theOperator: "*", numberB: "100", operatorType: OperatorType.midOperator, endPercentage: false)
                    
                    if let newNumber = answerBundle.answer {
                        newTermArray.replaceSubrange(newRange, with: [newNumber])
//                        print("newTermArray after replacement: \(newTermArray)", appendNewline: false)
                        //                            index -= 1
                        continue
                    }
                }
                
                // Convert number into thousand
                if Glossary.isStringNumber(word) && nextWord == "thousand" {
                    let newRange = (index ..< index + 2)
                    let newNumber = "\(word)000"
                    newTermArray.replaceSubrange(newRange, with: [newNumber])
                    //                index -= 1
                    continue
                }
                
                // Convert number into million
                if Glossary.isStringNumber(word) && nextWord == "million" {
                    let newRange = (index ..< index + 2)
                    let newNumber = "\(word)000000"
                    newTermArray.replaceSubrange(newRange, with: [newNumber])
                    //                index -= 1
                    continue
                }
                
                // Convert number into billion
                if Glossary.isStringNumber(word) && nextWord == "billion" {
                    let newRange = (index ..< index + 2)
                    let newNumber = "\(word)000000000"
                    newTermArray.replaceSubrange(newRange, with: [newNumber])
                    //                index -= 1
                    continue
                }
                
//                print("word: \(word)  nextWord: \(nextWord)", appendNewline: false)
                
                // Combine instances of a number with some zeroes at the end with the following number
                if Glossary.isStringNumber(word) && Glossary.isStringNumber(nextWord) {
                    
                    if word.characters.count > nextWord.characters.count {
                        
                        var zeroStringKey = ""
                        
                        while zeroStringKey.characters.count < nextWord.characters.count {
                            zeroStringKey += "0"
                        }
                        
                        
                        
                        if word.substring(from: word.characters.index(word.startIndex, offsetBy: word.characters.count - nextWord.characters.count)) == zeroStringKey {
                            let newRange = (index ..< index + 2)
                            
                            let answerBundle = Evaluator.solveUnknownNumber(word, theOperator: "+", numberB: nextWord, operatorType: OperatorType.midOperator, endPercentage: false)
                            
                            if let newNumber = answerBundle.answer {
                                newTermArray.replaceSubrange(newRange, with: [newNumber])
//                                print("newTermArray after replacement: \(newTermArray)")
                                //                            index -= 1
                                continue
                            }
                            
                        }
                    }
                }
                
                index += 1
            }
            
        }
        
        // Deal with special words...
        
        // If a special word is next to a pre-existing operator, such as multiply, then they are simply indicating grammar and are not needed (except for when by/with is followed by a “-“, in which case they mean multiply.
        
        if (newTermArray.count > 0) {
            
            var index = 0
            
            while index < newTermArray.count - 1 {
                let term = newTermArray[index]
                let nextTerm = newTermArray[index + 1]
                
//                print("term: \(term)  nextTerm: \(nextTerm)", appendNewline: false)
                
                if Glossary.isStringSpecialWord(term) && Glossary.isStringOperator(nextTerm) {
                    // Remove the term
                    newTermArray.remove(at: index)
                    index -= 1
                } else if Glossary.isStringOperator(term) && Glossary.isStringSpecialWord(nextTerm) {
                    // Remove the second term
                    newTermArray.remove(at: index + 1)
                    index -= 1
                }
                index += 1
            }
            
        }
        
        // TODO: Deal with times when the word "from" is used in a way that implies A from B = B - A. Will probably need to change "negative" into it's own term, not simply another way of saying "-"
        
        
        
        // Set undefined brackets "|" appropriately.
        
        var lastTerm:String?
        
        if (newTermArray.count > 0) {
            for index in 0...newTermArray.count - 1 {
                
                let term = newTermArray[index]
                
                if term == "|" {
                    
                    if let theLastTerm = lastTerm {
//                        print("", appendNewline: false)
                        
                        if let legalKeys = Glossary.legalCharactersToAppendString(theLastTerm) {
                            
                            if legalKeys.contains(")") {
                                newTermArray[index] = ")"
                            } else {
                                newTermArray[index] = "("
                            }
                            
                        } else {
                            newTermArray[index] = "("
                        }
                        
                    } else {
                        // First term, just add a "("
                        newTermArray[index] = "("
                    }
                }
                
                lastTerm = term
            }
        }
        
        // There is a special case where an operator starts a sentence, followed by a number, a special, and a number. In THIS case the special simply inherits the first operator. The start of a sentence is wordArray[0] OR an opening bracket.
        
        if (newTermArray.count > 0) {
            
            var index = 0
            var currentLevel = 0
            var lastTerm = ""
            var levelSet = Dictionary<Int,SubstitutionSet>()
            
            while index < newTermArray.count - 1 {
                
                let term = newTermArray[index]
//                print("term: \(term)", appendNewline: false)
                
//                print("current levelSet: \(levelSet)", appendNewline: false)
                
                if var subSet = levelSet[currentLevel] {
                    if term == "(" && subSet.foundBracketsAsNumbers == false && subSet.number.complete() == false {
//                        print("Found a starting bracket", appendNewline: false)
                        subSet.foundBracketsAsNumbers = true
                        levelSet[currentLevel] = subSet
                    }
                }
                
                if term == "(" {
                    currentLevel += 1
                } else if term == ")" {
                    currentLevel -= 1
                }
                
                if term == "*" || term == "-" || term == "/" || term == "+" {
                    if index == 0 || lastTerm == "(" {
                        // This is potentially the start of a set
                        
                        var subSet = SubstitutionSet()
                        subSet.index = index
                        
                        levelSet[currentLevel] = subSet
                    } else {
                        levelSet[currentLevel] = nil
                    }
                } else {
                    
//                    print("term is not a starting term", appendNewline: false)
                    
                    if var subSet = levelSet[currentLevel] {
                        // we DO have a set going for this level
//                        print("we have a subset", appendNewline: false)
                        if Glossary.isStringSpecialWord(term) {
//                            print("'and' found", appendNewline: false)
                            
                            if subSet.number.complete() || subSet.foundBracketsAsNumbers == true {
                                // We have reached an 'and' and the number is complete - let's do the swap!
                                
                                newTermArray[index] = newTermArray[subSet.index]
                                newTermArray.remove(at: subSet.index)
                                levelSet[currentLevel] = nil
                                
                            } else {
                                // Just ignore premature special words that are too early.
                            }
                            
                        } else {
//                            print("not an and, need to process \(term)", appendNewline: false)
                            
                            if term == "(" || term == ")" {
//                                print("We've found a bracket", appendNewline: false)
                                // This is a bracket and we can safely ignore it
                                subSet.foundBracketsAsNumbers = true
                            } else {
                                if subSet.number.processTerm(term) == false {
                                    // We processed this term but it destroyed this number, therefore we should nil it
                                    levelSet[currentLevel] = nil
                                } else {
//                                    print("number processed term successfully", appendNewline: false)
                                }
                            }
                        }
                    }
                }
                
                index += 1
                lastTerm = term
            }
        }
        
        // Now replace any remaining special's with their default meanings.
        
        if (newTermArray.count > 0) {
            
            var index = 0
            
            while index < newTermArray.count - 1 {
                let term = newTermArray[index]
                
                if term == "and" {
                    // and = +
                    newTermArray[index] = "+"
                } else if term == "by" {
                    // by = *
                    newTermArray[index] = "*"
                } else if term == "with" {
                    // with = *
                    newTermArray[index] = "*"
                }
                
                index += 1
            }
        }
        
        // Automatically add brackets where appropriate.
        
        if NumericalHelper.isSettingEnabled(string: NumericalHelperSetting.autoBrackets) {
            if (newTermArray.count > 0) {
                var stringBuffer = ""
                
                var index = 0
                
                while index < newTermArray.count - 1 {
                    let term = newTermArray[index]
                    
                    //                print("term: \(term)", appendNewline: false)
                    if Glossary.isStringOperator(term) {
                        if Glossary.shouldAddClosingBracketToAppendString(stringBuffer, newOperator: Character(term)) {
                            // Need to add a bracket
                            newTermArray.insert(")", at: index)
                            stringBuffer += ")"
                            index += 1
                            //                        print("Need to add a bracket", appendNewline: false)
                        }
                    }
                    
                    stringBuffer += term
                    index += 1
                }
            }
        }
        
        let finalString = newTermArray.joined(separator: "")
        
        return finalString
    }
    
    struct SubstitutionSet {
        var number = NumberTerm()
        var index = 0
        var foundBracketsAsNumbers = false
    }
    
}
