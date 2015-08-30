//
//  WorkPanelViewController.swift
//  Numerical2
//
//  Created by Andrew J Clark on 1/08/2015.
//  Copyright © 2015 Very Tiny Machines. All rights reserved.
//

import UIKit

class WorkPanelViewController: UIViewController, KeypadDelegate, EquationTextFieldDelegate {
    
    var question: String = "1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1"
    
    var answer: String = ""
    
    var equationView:EquationViewController?
    var keyPanelView:KeyPanelViewController?
    
    func questionChanged(newQuestion: String, overwrite: Bool) {
        
        question = newQuestion
        
        if overwrite {
            if let translatedString = NaturalLanguageParser.sharedInstance.translateString(newQuestion) {
                question = translatedString
            }
        }

        
        if let theView = equationView {
            theView.setQuestion(question)
        }
        
        updateLegalKeys()
        
    }
    
    func pressedKey(key: Character) {
        
        
//        question.append(key)
        

        if key == SymbolCharacter.clear {
            // Clear
            question = ""
        } else if key == SymbolCharacter.delete {
            // Delete
            
            if question.characters.count > 0 {
                question = question.substringToIndex(question.endIndex.predecessor())
            }
            
        } else if key == SymbolCharacter.smartBracket {
            
            
            if let legalKeys = Glossary.legalCharactersToAppendString(question) {
                if legalKeys.contains(")") {
                    question.append(Character(")"))
                } else if legalKeys.contains("(") {
                    question.append(Character("("))
                }
            }
            
        } else {
            
            
            if Glossary.shouldAddClosingBracketToAppendString(question, newOperator: key) {
                question.append(Character(")"))
            }
            
            question.append(key)
        }

        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            if let theView = self.equationView {
                theView.setQuestion(self.question)
            }
        })
        

//        print(question)
        
        updateLegalKeys()


    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        updateLegalKeys()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Setup notifiction for UIContentSizeCategoryDidChangeNotification
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "dynamicTypeChanged", name: UIContentSizeCategoryDidChangeNotification, object: nil)
        
        questionChanged(question, overwrite: true)
        
    }
    
    func dynamicTypeChanged() {
        //
        
        if let theEquationView = equationView {
            theEquationView.updateView()
        }
        
        updateLegalKeys()
        
        
    }
    
    
    func updateLegalKeys() {
        // Determine Legal Keys
        
        if let legalKeys = Glossary.legalCharactersToAppendString(question), theKeyPanel = keyPanelView {
            theKeyPanel.setLegalKeys(legalKeys)
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let keyPad = segue.destinationViewController as? KeyPanelViewController {
            keyPad.delegate = self
            keyPanelView = keyPad
        } else if let theView = segue.destinationViewController as? EquationViewController {
            
            theView.delegate = self
            equationView = theView
            equationView?.currentQuestion = question
            
        }
    }
    
}
