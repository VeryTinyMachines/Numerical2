//
//  WorkPanelViewController.swift
//  Numerical2
//
//  Created by Andrew J Clark on 1/08/2015.
//  Copyright © 2015 Very Tiny Machines. All rights reserved.
//

import UIKit
import Crashlytics

protocol WorkPanelDelegate {
    func updateEquation(_ equation: Equation?)
}

class WorkPanelViewController: NumericalViewController, KeypadDelegate, KeypadPageViewDelegate, EquationTextFieldDelegate, QuestionCollectionViewDelegate {
    
    func unpressedKey(_ key: Character, sourceView: UIView?) {
        
    }
    
    @IBOutlet weak var equationViewHeightConstraint: NSLayoutConstraint!
    
    var inTutorial = false
    var tutorialPage = 0
    var tutorialPages = [String]()
    var tutorialTimer:Timer?
    
    var currentEquation: Equation?
    
    var equationView:EquationViewController?
    
    var keyPanelView:KeypadPageViewController?
    
    var delegate: KeypadDelegate?
    
    var showEquationView: Bool = true
    
    var workPanelDelegate: WorkPanelDelegate?
    
    var blurView: UIVisualEffectView?
    
    @IBOutlet weak var tutorialLabel: UILabel!
    
    @IBOutlet weak var seperatorView: UIView!
    
    @IBOutlet weak var pageControl: UIPageControl!
    
    @IBOutlet weak var tutorialButton: UIButton!
    
    @IBOutlet weak var separatorView: UIView!
    @IBOutlet weak var separatorViewHeight: NSLayoutConstraint!
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        updateLegalKeys()
        
        var needsTutorial = false
        
        if inTutorial == false {
            if let lastTutorialScene = UserDefaults.standard.object(forKey: "HasSeenTutorial") as? String {
                if lastTutorialScene != "2.0.0" {
                    needsTutorial = true
                }
            } else {
                needsTutorial = true
            }
            
            if needsTutorial {
                
                PremiumCoordinator.shared.preventAd = true
                
                DispatchQueue.main.async {
                    self.tutorialTimer?.invalidate()
                    self.tutorialTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: false, block: { (timer) in
                        self.beginTutorial()
                    })
                }
            }
        }
    }
    
    override func viewDidLayoutSubviews() {
        // equationView?.view.transform = CGAffineTransform(scaleX: -1.0, y: 1.0) // FLIP!
    }
 
    func beginTutorial() {
        inTutorial = true
 
        tutorialPage = 0
        tutorialLabel.text = tutorialPages[tutorialPage]
 
        tutorialLabel.textColor = ThemeCoordinator.shared.foregroundColorForCurrentTheme()
        
        tutorialLabel.isHidden = false
        equationView?.view.isHidden = false
        self.tutorialButton.isHidden = false
        
        tutorialLabel.alpha = 0.0
        equationView?.view.alpha = 1.0
        
        UIView.animate(withDuration: 0.5, animations: {
            self.tutorialLabel.alpha = 1.0
            self.equationView?.view.alpha = 0.0
        }) { (complete) in
            self.tutorialLabel.isHidden = false
            self.equationView?.view.isHidden = true
            
            self.queueTutorialTimer()
        }
    }
    
    func nextTutorialPage() {
        UIView.animate(withDuration: 0.5, animations: {
            self.tutorialLabel.alpha = 0.0
            
        }) { (complete) in
            self.tutorialPage += 1
            
            self.tutorialLabel.textColor = ThemeCoordinator.shared.foregroundColorForCurrentTheme()
            
            if self.tutorialPage < self.tutorialPages.count {
                // We can show the next one
                
                self.tutorialLabel.text = self.tutorialPages[self.tutorialPage]
                
                UIView.animate(withDuration: 0.5, animations: { 
                    self.tutorialLabel.alpha = 1.0
                }, completion: { (complete) in
                    self.queueTutorialTimer()
                })
                
            } else {
                // No more pages, end the tutorial.
                self.endTutorialIfNeeded()
            }
        }
    }
    
    func queueTutorialTimer() {
        tutorialTimer?.invalidate()
        tutorialTimer = Timer.scheduledTimer(withTimeInterval: 3.0, repeats: false, block: { (timer) in
            self.nextTutorialPage()
        })
    }
    
    func endTutorialIfNeeded() {
        
        tutorialTimer?.invalidate()
        
        if inTutorial {
            UserDefaults.standard.set("2.0.0", forKey: "HasSeenTutorial")
            UserDefaults.standard.synchronize()
            
            inTutorial = false
            
            tutorialLabel.isHidden = false
            equationView?.view.isHidden = false
            self.tutorialButton.isHidden = true
            
            equationView?.view.alpha = 0.0
            
            UIView.animate(withDuration: 0.5, animations: {
                self.tutorialLabel.alpha = 0.0
                self.equationView?.view.alpha = 1.0
            }) { (complete) in
                self.tutorialLabel.isHidden = true
                self.equationView?.view.isHidden = false
            }
        }
    }
    
    @IBAction func userPressedTutorialButton(_ sender: UIButton) {
        self.endTutorialIfNeeded()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Setup notifiction for UIContentSizeCategoryDidChangeNotification
        NotificationCenter.default.addObserver(self, selector: #selector(WorkPanelViewController.dynamicTypeChanged), name: NSNotification.Name.UIContentSizeCategoryDidChange, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(WorkPanelViewController.themeChanged), name: Notification.Name(rawValue: PremiumCoordinatorNotification.themeChanged), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(WorkPanelViewController.themeChanged), name: NSNotification.Name.UIAccessibilityReduceTransparencyStatusDidChange, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(WorkPanelViewController.equationLogicChanged), name: Notification.Name(rawValue: EquationStoreNotification.equationLogicChanged), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(WorkPanelViewController.historyDeleted), name: Notification.Name(rawValue: EquationStoreNotification.historyDeleted), object: nil)
        
        currentEquation = EquationStore.sharedStore.currentEquation()
        workPanelDelegate?.updateEquation(currentEquation)
        
        updateViews(currentCursor: nil)
        
        self.themeChanged()
        
        // Setup tutorial pages
        if NumericalViewHelper.isDevicePad() {
            tutorialPages = ["Welcome to Numerical²!\nIt's still the calculator without equal.","Pull down to see your History.\nIt syncs with iCloud\n(or you can turn that off).", "Press the Menu button \nto get to Settings and\nthe Theme Creator.", "Thanks!"]
        } else {
            tutorialPages = ["Welcome to Numerical²!\nIt's still the calculator without equal.","Pull down to see your History.\nIt syncs with iCloud\n(or you can turn that off).", "Swipe Left to get to the scientific keys.\nSwipe again for Settings,\nand the Theme Creator.", "Thanks!"]
        }
        
        self.tutorialLabel.isHidden = true
        self.tutorialButton.isHidden = true
    }
    
    func historyDeleted() {
        // The history has been deleted, which means we now have an equation that needs to be nullified. However the user may still be working on the equation, so we should.
        
        currentEquation = nil
        updateViews(currentCursor: nil)
    }
    
    func equationLogicChanged() {
        updateViews(currentCursor: nil)
    }
    
    func themeChanged() {
        updateBlurView()
        
        // Set page control tint
        self.pageControl.pageIndicatorTintColor = ThemeCoordinator.shared.foregroundColorForCurrentTheme().withAlphaComponent(0.25)
        self.pageControl.currentPageIndicatorTintColor = ThemeCoordinator.shared.foregroundColorForCurrentTheme().withAlphaComponent(1.00)
        
        //self.seperatorView.isHidden = true
        self.separatorView.isHidden = false
        self.separatorView.backgroundColor = ThemeCoordinator.shared.foregroundColorForCurrentTheme().withAlphaComponent(0.25)
        self.separatorViewHeight.constant = 0.5
        
        tutorialLabel.textColor = ThemeCoordinator.shared.foregroundColorForCurrentTheme()
    }
    
    func updateBlurView() {
        if let currentBlurView = self.blurView {
            currentBlurView.removeFromSuperview()
            self.blurView = nil
        }
        
        if NumericalViewHelper.historyBesideKeypadNeeded() == false {
            if let visualEffectView = ThemeCoordinator.shared.visualEffectViewForCurrentTheme() {
                self.view.insertSubview(visualEffectView, at: 0)
                
                visualEffectView.bindFrameToSuperviewBounds()
                
                self.blurView = visualEffectView
            }
        }
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
        self.endTutorialIfNeeded()
        
        if key == SymbolCharacter.clear {
            SoundManager.playSound(sound: .clear)
        } else {
            SoundManager.playSound(sound: .click)
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
                        if legalKeys.contains(SymbolCharacter.smartBracketPrefersClose) {
                            newCursorPosition = updateCurrentQuestionByAppendingCharacters(characters: [Character(")")])
                        } else if legalKeys.contains(")") {
                            newCursorPosition = updateCurrentQuestionByAppendingCharacters(characters: [Character(")")])
                        } else if legalKeys.contains("(") {
                            newCursorPosition = updateCurrentQuestionByAppendingCharacters(characters: [Character("(")])
                        }
                    }
                    
                    EquationStore.sharedStore.equationUpdated(equation: equation)
                }
                
            } else {
                
                if let question = equation.question {
                    
                    if Glossary.shouldAddClosingBracketToAppendString(question, newOperator: key) && currentCursorPositionIsAtEnd() {
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
    
    func currentCursorPositionIsAtEnd() -> Bool {
        
        if let equation = currentEquation {
            if var question = equation.question {
                if currentSelectedRange() == nil {
                    if let index = currentCursorPosition() {
                        if index == question.characters.count {
                            // There is a currentCursorPosition but it's at the end, therefore we should add a closing bracket.
                            return true
                        }
                    } else {
                        // There is no currentCursorPosition so we are simply at the end
                        return true
                    }
                }
            }
        }
        
        return false
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
                    
                    for character in characters {
                        newQuestion.insert(character, at: newQuestion.index(newQuestion.startIndex, offsetBy: range.lower))
                    }
                    
                    currentEquation?.question = newQuestion
                    
                    newCursorPosition = range.lower + characters.count
                    
                } else if var index = currentCursorPosition() {
                    
                    var newQuestion = question
                    
                    for character in characters {
                        
                        newQuestion.insert(character, at: newQuestion.index(newQuestion.startIndex, offsetBy: index))
                        
                        index += 1
                    }
                    
                    currentEquation?.question = newQuestion
                    
                    newCursorPosition = index + characters.count - 1
                    
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
    
    func startNew(string: String, view: QuestionCollectionViewController) {
        // Start a new equation using this as a base.
        
        // Save this current equation
        if let equation = currentEquation {
            equation.lastModifiedDate = NSDate()
            currentEquation = nil
            EquationStore.sharedStore.equationUpdated(equation: equation)
        }
        
        // Start a new equation
        
        
        let theNewEquation = EquationStore.sharedStore.newEquation()
        
        EquationStore.sharedStore.setCurrentEquationID(string: theNewEquation.identifier)
        
        theNewEquation.question = string
        
        currentEquation = theNewEquation
        
        EquationStore.sharedStore.equationUpdated(equation: currentEquation!)
        
        if let theWorkPanelDelegate = workPanelDelegate {
            theWorkPanelDelegate.updateEquation(currentEquation)
        }
        
        updateViews(currentCursor: nil)
        updateLegalKeys()
    }
    
    func isQuestionEditing() -> Bool {
        if let equationView = equationView {
            return equationView.isQuestionEditting()
        }
        return false
    }
    
    func userPressedCopyAll() {
        if let equation = currentEquation {
            var string = ""
            
            if let question = equation.question {
                let bracketBalancedString = Evaluator.balanceBracketsForQuestionDisplay(question)
                
                string += Glossary.formattedStringForQuestion(bracketBalancedString)
            }
            
            if let answer = equation.answer {
                
                if string.characters.count > 0 {
                    string += " = "
                }
                
                string += Glossary.formattedStringForAnswer(answer)
            }
            
            let board = UIPasteboard.general
            board.string = string
        }
    }
}
