//
//  WorkPanelViewController.swift
//  Numerical2
//
//  Created by Andrew J Clark on 1/08/2015.
//  Copyright © 2015 Very Tiny Machines. All rights reserved.
//

import UIKit

protocol WorkPanelDelegate {
    func updateEquation(_ equation: Equation?)
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
    
    func questionChanged(_ newQuestion: String, overwrite: Bool) {
        
    }
    
    func updatePageControl(_ currentPage: NSInteger, numberOfPages: NSInteger) {
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
//                    EquationStore.sharedStore.save()
                    
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
//                    WatchCommunicator.latestEquationDict = latestEquationDict
                })
                
            } else {
                theView.setQuestion("")
                theView.setAnswer(AnswerBundle(number: ""))
            }
        }
    }
    
    
    func pressedKey(_ key: Character) {
        print("pressedKey in WPVC")
        if key == SymbolCharacter.clear {
            if let equation = currentEquation {
                // Clear - Need to load a new equation from the EquationStore
                
                equation.lastModifiedDate = NSDate()
                currentEquation = nil
                EquationStore.sharedStore.equationUpdated(equation: equation)
                
                if let theWorkPanelDelegate = workPanelDelegate {
                    theWorkPanelDelegate.updateEquation(currentEquation)
                }
            }
        } else {
            
            if currentEquation == nil {
                
                let theNewEquation = EquationStore.sharedStore.newEquation()
                
                currentEquation = theNewEquation
                
                EquationStore.sharedStore.equationUpdated(equation: currentEquation!)
                
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
                        equation.question = question.substring(to: question.characters.index(before: question.endIndex))
                        
                        // If this equation is now empty then we need to delete the equation from the store.
                        if "" == equation.question {
                            
                            EquationStore.sharedStore.deleteEquation(equation: equation)
                            
                            currentEquation = nil
                            
                            if let theWorkPanelDelegate = workPanelDelegate {
                                theWorkPanelDelegate.updateEquation(currentEquation)
                            }
                        } else {
                            EquationStore.sharedStore.equationUpdated(equation: equation)
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
                    EquationStore.sharedStore.equationUpdated(equation: equation)
                }
                
            } else {
                
                if var question = equation.question {
                    
                    if Glossary.shouldAddClosingBracketToAppendString(question, newOperator: key) {
                        question.append(Character(")"))
                    }
                    
                    question.append(key) // ZZZ
                    
                    equation.question = question
                    EquationStore.sharedStore.equationUpdated(equation: equation)
                } else {
                    equation.question = String(key)
                    EquationStore.sharedStore.equationUpdated(equation: equation)
                }
            }
        }
        
        
        updateViews()
        updateLegalKeys()
        
        if let theDelegate = delegate {
            theDelegate.pressedKey(key)
        }
    }
    
    func viewIsWide() -> Bool {
        return false
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
//        view.backgroundColor = UIColor(red: 38 / 255, green: 47/255, blue: 58/255, alpha: 1.0)
        
        updateLegalKeys()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Setup notifiction for UIContentSizeCategoryDidChangeNotification
        NotificationCenter.default.addObserver(self, selector: #selector(WorkPanelViewController.dynamicTypeChanged), name: NSNotification.Name.UIContentSizeCategoryDidChange, object: nil)
        
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
            if let legalKeys = Glossary.legalCharactersToAppendString(question), let theKeyPanel = keyPanelView {
                theKeyPanel.setLegalKeys(legalKeys)
            }
        } else {
            if let legalKeys = Glossary.legalCharactersToAppendString(""), let theKeyPanel = keyPanelView {
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
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let keyPad = segue.destination as? KeypadPageViewController {
            keyPad.delegate = self
            keyPad.pageViewDelegate = self
            keyPanelView = keyPad
        } else if let theView = segue.destination as? EquationViewController {
            
            theView.delegate = self
            equationView = theView
            
            if let question = currentEquation?.question {
                equationView?.currentQuestion = question
            }
        }
    }
    
}
