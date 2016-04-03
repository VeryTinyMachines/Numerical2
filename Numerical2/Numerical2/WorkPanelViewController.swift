//
//  WorkPanelViewController.swift
//  Numerical2
//
//  Created by Andrew J Clark on 1/08/2015.
//  Copyright © 2015 Very Tiny Machines. All rights reserved.
//

import UIKit

protocol WorkPanelDelegate {
    func updateEquation(equation: Equation?)
}

class WorkPanelViewController: UIViewController, KeypadDelegate, KeypadPageViewDelegate, EquationTextFieldDelegate {
    
    @IBOutlet weak var equationViewHeightConstraint: NSLayoutConstraint!
    
    var currentEquation: Equation?
    
    var equationView:EquationViewController?
    
    var keyPanelView:KeypadPageViewController?
    
    var delegate: KeypadDelegate?
    
    var showEquationView: Bool = true
    
    var workPanelDelegate: WorkPanelDelegate?
    
    @IBOutlet weak var pageControl: UIPageControl!
    
    func questionChanged(newQuestion: String, overwrite: Bool) {
        
    }
    
    func updatePageControl(currentPage: NSInteger, numberOfPages: NSInteger) {
        pageControl.numberOfPages = numberOfPages
        pageControl.currentPage = currentPage        
    }
    
    func updateViews() {
        
        if let theView = equationView {
            
            if let question = currentEquation?.question {
                theView.setQuestion(question)
                
                // Solve this question
                
                CalculatorBrain.sharedBrain.solveStringAsyncQueue(question, completion: { (answer: AnswerBundle) -> Void in
                    self.currentEquation?.answer = answer.answer
                    EquationStore.sharedStore.save()
                    
                    if let equation = self.currentEquation {
                        equation.answer = answer.answer
                    }
                    
                    theView.setAnswer(answer)
                    
                    
                    var latestEquationDict = [String:String]()
                    latestEquationDict[EquationStringKey] = question
                    
                    if let theAnswer = answer.answer {
                        latestEquationDict[AnswerStringKey] = theAnswer
                    } else {
                        latestEquationDict[AnswerStringKey] = "Error"
                    }
                    
                    print("latestEquationDict (to send): \(latestEquationDict)")
                    WatchCommunicator.latestEquationDict = latestEquationDict
                })
                
            } else {
                theView.setQuestion("")
                theView.setAnswer(AnswerBundle(number: ""))
            }
        }
    }
    
    
    func pressedKey(key: Character) {
        print("pressedKey in WPVC")
        if key == SymbolCharacter.clear {
            if let equation = currentEquation {
                // Clear - Need to load a new equation from the EquationStore
                
                equation.lastModifiedDate = NSDate()
                currentEquation = nil
                
                if let theWorkPanelDelegate = workPanelDelegate {
                    theWorkPanelDelegate.updateEquation(currentEquation)
                }
                
            }
        } else {
            
            if currentEquation == nil {
                currentEquation = EquationStore.sharedStore.newEquation()
                
                if let theWorkPanelDelegate = workPanelDelegate {
                    theWorkPanelDelegate.updateEquation(currentEquation)
                }
            }
        }
        
        if let equation = currentEquation {
            
            if key == SymbolCharacter.delete {
                // Delete
                
                if let question = equation.question {
                    if question.characters.count > 0 {
                        equation.question = question.substringToIndex(question.endIndex.predecessor())
                        
                        // If this equation is now empty then we need to delete the equation from the store.
                        if "" == equation.question {
                            EquationStore.sharedStore.deleteEquation(equation)
                            currentEquation = nil
                            
                            if let theWorkPanelDelegate = workPanelDelegate {
                                theWorkPanelDelegate.updateEquation(currentEquation)
                            }
                        }
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
    
    func viewIsWide() -> Bool {
        return false
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
//        view.backgroundColor = UIColor(red: 38 / 255, green: 47/255, blue: 58/255, alpha: 1.0)
        
        updateLegalKeys()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Setup notifiction for UIContentSizeCategoryDidChangeNotification
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "dynamicTypeChanged", name: UIContentSizeCategoryDidChangeNotification, object: nil)
        
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
        } else {
            if let legalKeys = Glossary.legalCharactersToAppendString(""), theKeyPanel = keyPanelView {
                theKeyPanel.setLegalKeys(legalKeys)
            }
        }
    }
    
    
    func updateEquationViewSize() {
//        if showEquationView {
//            equationViewHeightConstraint.constant = 110
//        } else {
//            equationViewHeightConstraint.constant = 0
//        }
    }
    
    
    func updateLayout() {
        
//        if let keyPanel = keyPanelView {
//            keyPanel.updateKeyLayout()
//        }
        
        if let theEquationView = equationView {
            theEquationView.updateView()
        }
        
        
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let keyPad = segue.destinationViewController as? KeypadPageViewController {
            keyPad.delegate = self
            keyPad.pageViewDelegate = self
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
