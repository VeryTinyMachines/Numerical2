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

class WorkPanelViewController: NumericalViewController, KeypadDelegate, KeypadPageViewDelegate, EquationTextFieldDelegate, QuestionCollectionViewDelegate {
    
    func unpressedKey(_ key: Character, sourceView: UIView?) {
        
    }
    
    @IBOutlet weak var equationViewHeightConstraint: NSLayoutConstraint!
    
    var currentEquation: Equation?
    
    var equationView:EquationViewController?
    
    var keyPanelView:KeypadPageViewController?
    
    var delegate: KeypadDelegate?
    
    var showEquationView: Bool = true
    
    var workPanelDelegate: WorkPanelDelegate?
    
    var blurView: UIVisualEffectView?
    
    @IBOutlet weak var seperatorView: UIView!
    
    @IBOutlet weak var pageControl: UIPageControl!
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        updateLegalKeys()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Setup notifiction for UIContentSizeCategoryDidChangeNotification
        NotificationCenter.default.addObserver(self, selector: #selector(WorkPanelViewController.dynamicTypeChanged), name: NSNotification.Name.UIContentSizeCategoryDidChange, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(WorkPanelViewController.themeChanged), name: Notification.Name(rawValue: PremiumCoordinatorNotification.themeChanged), object: nil)
        
        currentEquation = EquationStore.sharedStore.currentEquation()
        workPanelDelegate?.updateEquation(currentEquation)
        
        updateViews(currentCursor: nil)
        
        self.themeChanged()
    }
    
    func themeChanged() {
        updateBlurView()
        
        // Set page control tint
        self.pageControl.pageIndicatorTintColor = ThemeCoordinator.shared.foregroundColorForCurrentTheme().withAlphaComponent(0.25)
        self.pageControl.currentPageIndicatorTintColor = ThemeCoordinator.shared.foregroundColorForCurrentTheme().withAlphaComponent(1.00)
        
//        self.seperatorView.backgroundColor = ThemeCoordinator.shared.foregroundColorForCurrentTheme().withAlphaComponent(0.25)
        self.seperatorView.isHidden = true
        
    }
    
    func updateBlurView() {
        if let currentBlurView = self.blurView {
            currentBlurView.removeFromSuperview()
            self.blurView = nil
        }
        
        let visualEffectView = ThemeCoordinator.shared.visualEffectViewForCurrentTheme()
        self.view.insertSubview(visualEffectView, at: 0)
        
        visualEffectView.bindFrameToSuperviewBounds()
        
        self.blurView = visualEffectView
    }
    
    func questionChanged(_ newQuestion: String, overwrite: Bool) {
        
    }
    
    func updatePageControl(_ currentPage: NSInteger, numberOfPages: NSInteger) {
        if numberOfPages > 1 {
            pageControl.isHidden = false
        } else {
            pageControl.isHidden = true
        }
        
        pageControl.numberOfPages = numberOfPages
        pageControl.currentPage = currentPage        
    }
    
    func updateViews(currentCursor: Int?) {
        
        if let theView = equationView {
            
            if let question = currentEquation?.question {
                theView.setQuestion(question, cursorPosition: currentCursor)
                
                // Solve this question
                
                let originalRequestEquation = currentEquation
                
                CalculatorBrain.sharedBrain.solveStringAsyncQueue(question, completion: { (answer: AnswerBundle) -> Void in
                    
                    if self.currentEquation == originalRequestEquation {
                        
                        if let error = answer.errorType {
                            self.currentEquation?.answer = error.rawValue
                        } else {
                            self.currentEquation?.answer = answer.answer
                        }
                        
                        theView.setAnswer(answer)
                        
                        EquationStore.sharedStore.queueSave()
                    }
                })
                
            } else {
                theView.setQuestion("", cursorPosition: nil)
                theView.setAnswer(AnswerBundle(number: ""))
            }
        }
    }
    
    func currentSelectedRange() -> (lower: Int, upper: Int)? {
        
        if questionTextFieldIsEditting() {
            if let textField = equationView?.questionView?.textField {
                
                if let selectedRange = textField.selectedTextRange {
                    
                    let cursorStartPosition = textField.offset(from: textField.beginningOfDocument, to: selectedRange.start)
                    let cursorEndPosition = textField.offset(from: textField.beginningOfDocument, to: selectedRange.end)
                    
                    print(cursorStartPosition)
                    print(cursorEndPosition)
                    
                    if cursorEndPosition > cursorStartPosition {
                        return (lower: cursorStartPosition, upper: cursorEndPosition)
                    }
                }
            }
        }
        
        return nil
    }
    
    func currentCursorPosition() -> Int? {
        
        if questionTextFieldIsEditting() {
            if let textField = equationView?.questionView?.textField {
                let selectedRange: UITextRange? = textField.selectedTextRange
                
                if let selectedRange = selectedRange {
                    let cursorPosition = textField.offset(from: textField.beginningOfDocument, to: selectedRange.start)
                    return cursorPosition
                }
            }
        }
        
        return nil
    }
    
    func questionTextFieldIsEditting() -> Bool {
        if let questionView = equationView?.questionView {
            return questionView.isEditing
        }
        
        return false
    }
    
    func pressedKey(_ key: Character, sourceView: UIView?) {
        
        if key == SymbolCharacter.clear {
            SoundManager.playSound(sound: .clear)
        } else {
            SoundManager.playSound(sound: .click)
        }
        
        // Check if the edit menu needed dismissing
        if needsEditMenuDismissal() {
            return
        }
        
        // Check if this key is the settings button
        if key == SymbolCharacter.settings {
            // show settings view
            self.presentSettings(sourceView: sourceView)
            return
        }
        
        // Check if this key is premium and what the expected behaviour is.
        if PremiumCoordinator.shared.canUserAccessKey(character: key) == false {
            self.presentSalesScreen(type: SalesScreenType.scientificKey)
            return
        }
        
        // A key has been pressed, determine if we should be inserting this character at the end of the string or somewhere in the middle
        var newCursorPosition:Int?
        
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
            
            EquationStore.sharedStore.setCurrentEquationID(string: nil)
        } else {
            if currentEquation == nil {
                
                let theNewEquation = EquationStore.sharedStore.newEquation()
                
                EquationStore.sharedStore.setCurrentEquationID(string: theNewEquation.identifier)
                
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
                newCursorPosition = updateCurrentQuestionByDeletingCurrentRange()
                
            } else if key == SymbolCharacter.smartBracket {
                
                if let question = currentEquation?.question {
                    if let legalKeys = Glossary.legalCharactersToAppendString(question) {
                        if legalKeys.contains(")") {
                            newCursorPosition = updateCurrentQuestionByAppendingCharacters(characters: [Character(")")])
                        } else if legalKeys.contains("(") {
                            newCursorPosition = updateCurrentQuestionByAppendingCharacters(characters: [Character("(")])
                        }
                    }
                    
                    EquationStore.sharedStore.equationUpdated(equation: equation)
                }
                
            } else {
                
                if let question = equation.question {
                    
                    if Glossary.shouldAddClosingBracketToAppendString(question, newOperator: key) {
                        newCursorPosition = updateCurrentQuestionByAppendingCharacters(characters: [Character(")"), key])
                    } else {
                        newCursorPosition = updateCurrentQuestionByAppendingCharacters(characters: [key])
                    }
                    
                    EquationStore.sharedStore.equationUpdated(equation: equation)
                } else {
                    equation.question = String(key)
                    EquationStore.sharedStore.equationUpdated(equation: equation)
                }
            }
        }
        
        updateViews(currentCursor: newCursorPosition)
        updateLegalKeys()
        
        if let theDelegate = delegate {
            theDelegate.pressedKey(key, sourceView: sourceView)
        }
    }
    
    func updateCurrentQuestionByAppendingCharacters(characters: [Character]) -> Int? {
        
        var newCursorPosition:Int?
        if let equation = currentEquation {
            if var question = equation.question {
                
                if let range = currentSelectedRange() {
                    // Delete this range
                    
                    var newQuestion = ""
                    
                    var count = 0
                    
                    for character in question.characters {
                        if count < range.lower {
                            newQuestion.append(character)
                        }
                        
                        if count >= range.upper {
                            newQuestion.append(character)
                        }
                        
                        count += 1
                    }
                    
                    // We have removed these items, now insert those characters at the index
                    
                    print(newQuestion)
                    
                    for character in characters {
                        newQuestion.insert(character, at: newQuestion.index(newQuestion.startIndex, offsetBy: range.lower))
                    }
                    
                    currentEquation?.question = newQuestion
                    
                    newCursorPosition = range.lower + characters.count
                    
                    print(currentEquation?.question)
                    print("")
                    
                } else if let index = currentCursorPosition() {
                    
                    print(index)
                    
                    var newQuestion = question
                    
                    for character in characters {
                        newQuestion.insert(character, at: newQuestion.index(newQuestion.startIndex, offsetBy: index))
                    }
                    
                    currentEquation?.question = newQuestion
                    
                    newCursorPosition = index + characters.count
                    
                } else {
                    // Just delete from the end
//                    equation.question = question.substring(to: question.characters.index(before: question.endIndex))
                    
                    let stringToInsert = String(characters)
                    
                    question += stringToInsert
                    
                    currentEquation?.question = question
                    
                }
            }
        }
        
        // If there is a selected range we need to replace that range with these characters
        
        // If there is a cursor somewhere we need to insert these characters there
        
        // If there is no cursor then just append it
        
        return newCursorPosition
    }
    
    func updateCurrentQuestionByDeletingCurrentRange() -> Int? { // Returns a new cursor position if needed
        var newCursorPosition: Int?
        
        if let equation = currentEquation {
            if var question = equation.question {
                if question.characters.count > 0 {
                    
                    // Here is where we delete the relevant area.
                    
                    if let range = currentSelectedRange() {
                        // Delete this range
                        
                        var newQuestion = ""
                        
                        var count = 0
                        
                        for character in question.characters {
                            if count < range.lower || count >= range.upper {
                                newQuestion.append(character)
                            }
                            
                            count += 1
                        }
                        
                        currentEquation?.question = newQuestion
                        
                        newCursorPosition = range.lower
                        
                    } else if let index = currentCursorPosition() {
                        
                        print(index)
                        
                        if index > 0 {
                            // Remove the character before this index
                            
                            var newQuestion = ""
                            
                            var count = 0
                            
                            for character in question.characters {
                                if count != index-1 {
                                    newQuestion.append(character)
                                }
                                
                                count += 1
                            }
                            
                            currentEquation?.question = newQuestion
                            
                            newCursorPosition = index - 1
                        }
                        
                    } else {
                        // Just delete from the end
                        equation.question = question.substring(to: question.characters.index(before: question.endIndex))
                    }
                    
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
        }
        
        return newCursorPosition
    }
    
    
    
    func viewIsWide() -> Bool {
        return false
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
            
            var currentlyEditing = false
            
            if let equationView = equationView {
                print("The equation view")
                if equationView.isQuestionEditting() == true {
                    currentlyEditing = true
                }
            }
            
            if currentlyEditing {
                if let legalKeys = Glossary.legalCharactersToAppendString("?"), let theKeyPanel = keyPanelView {
                    theKeyPanel.setLegalKeys(legalKeys)
                }
            } else {
                if let legalKeys = Glossary.legalCharactersToAppendString(question), let theKeyPanel = keyPanelView {
                    theKeyPanel.setLegalKeys(legalKeys)
                }
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
            theView.questionTextDelegate = self
            
            equationView = theView
            
            if let question = currentEquation?.question {
                equationView?.currentQuestion = question
            }
        }
    }
    
    func textFieldChanged(string: String, view: QuestionCollectionViewController) {
        if let currentEquation = currentEquation {
            currentEquation.question = string
            updateViews(currentCursor: nil)
        }
        
        updateLegalKeys()
    }
    
    func isQuestionEditing() -> Bool {
        if let equationView = equationView {
            return equationView.isQuestionEditting()
        }
        return false
    }
}
