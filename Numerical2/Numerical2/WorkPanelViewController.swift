//
//  WorkPanelViewController.swift
//  Numerical2
//
//  Created by Andrew J Clark on 1/08/2015.
//  Copyright © 2015 Very Tiny Machines. All rights reserved.
//

import UIKit

class WorkPanelViewController: UIViewController, KeypadDelegate, EquationTextFieldDelegate {
    
    var currentEquation: Equation?
    
    var equationView:EquationViewController?
    var keyPanelView:KeyPanelViewController?
    
    var delegate: KeypadDelegate?
    
    func questionChanged(newQuestion: String, overwrite: Bool) {
//        updateLegalKeys()
    }
    
    func updateViews() {
        
        if let theView = equationView {
            
            if let question = currentEquation?.question {
                theView.setQuestion(question)
                
                // Solve this question
                
                CalculatorBrain.sharedBrain.solveStringInQueue(question, completion: { (answer) -> Void in
                    self.currentEquation?.answer = answer.answer
                    EquationStore.sharedStore.save()
                    
                    if let equation = self.currentEquation {
                        equation.answer = answer.answer
                    }
                    
                    theView.setAnswer(answer)
                    
                })
                
            } else {
                theView.setQuestion("")
                theView.setAnswer(AnswerBundle(number: ""))
            }
        }
    }
    
    
    func pressedKey(key: Character) {
        
        if key == SymbolCharacter.clear {
            if let equation = currentEquation {
                // Clear - Need to load a new equation from the EquationStore
                
                equation.lastModifiedDate = NSDate()
                currentEquation = nil
            }
        } else {
            
            if currentEquation == nil {
                currentEquation = EquationStore.sharedStore.newEquation()
            }
        }
        
        if let equation = currentEquation {
            
            
            if key == SymbolCharacter.delete {
                // Delete
                
                if let question = equation.question {
                    if question.characters.count > 0 {
                        equation.question = question.substringToIndex(question.endIndex.predecessor())
                    }
                }
                
            } else if key == SymbolCharacter.smartBracket {
                
                if var question = currentEquation?.question {
                    if let legalKeys = Glossary.legalCharactersToAppendString(question) {
                        if legalKeys.contains(")") {
                            question.append(Character(")"))
                        } else if legalKeys.contains("(") {
                            question.append(Character("("))
                        }
                    }
                    
                    equation.question = question
                }
                
            } else {
                
                if var question = equation.question {
                    
                    if Glossary.shouldAddClosingBracketToAppendString(question, newOperator: key) {
                        question.append(Character(")"))
                    }
                    
                    question.append(key)
                    
                    equation.question = question
                    
                } else {
                    equation.question = String(key)
                }
            }
        }
        
        EquationStore.sharedStore.save()
        
        updateViews()
        updateLegalKeys()
        
        if let theDelegate = delegate {
            theDelegate.pressedKey(key)
        }
        
    }
    
    
//    func updateEquationView() {
//        
//        
//        if let view = equationView {
//            
//            if let question = currentEquation?.question {
//                view.setQuestion(question)
//            }
//            
//            if let answer = currentEquation?.answer {
//                view.setAnswer(AnswerBundle(number: answer))
//            }
//            
//            
//        }
//        
//        
//        
//    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        updateLegalKeys()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        // Setup notifiction for UIContentSizeCategoryDidChangeNotification
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "dynamicTypeChanged", name: UIContentSizeCategoryDidChangeNotification, object: nil)
        
        // Find out how many equations are in the equation store.
        
        if let equations = EquationStore.sharedStore.equationArrayForPad(nil) {
            
            for equation in equations {
                print("\(equation.question) = \(equation.answer)")
                
            }
            
            if let lastEquation = equations.last {
                print("retrieved equation from store")
                currentEquation = lastEquation
            }
            
        }
        
        
        updateViews()
        
        
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
        if let question = currentEquation?.question {
            if let legalKeys = Glossary.legalCharactersToAppendString(question), theKeyPanel = keyPanelView {
                theKeyPanel.setLegalKeys(legalKeys)
            }
        }
        
        
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let keyPad = segue.destinationViewController as? KeyPanelViewController {
            keyPad.delegate = self
            keyPanelView = keyPad
        } else if let theView = segue.destinationViewController as? EquationViewController {
            
            theView.delegate = self
            equationView = theView
            
            if let question = currentEquation?.question {
                equationView?.currentQuestion = question
            }
        }
    }
    
}
