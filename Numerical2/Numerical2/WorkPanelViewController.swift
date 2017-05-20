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
    func updateEquation(_ equation: WorkingEquation?)
}

class WorkingEquation {
    var question = ""
    var answer:String?
    var hasChanged = false
}


class WorkPanelViewController: NumericalViewController, KeypadDelegate, KeypadPageViewDelegate, EquationTextFieldDelegate, QuestionCollectionViewDelegate {
    
    func unpressedKey(_ key: Character, sourceView: UIView?) {
        
    }
    
    @IBOutlet weak var equationViewHeightConstraint: NSLayoutConstraint!
    
    var inTutorial = false
    var tutorialPage = 0
    var tutorialPages = [String]()
    var tutorialTimer:Timer?
    
    //var currentEquation = WorkingEquation()
    
    var equationView:EquationViewController?
    
    var keyPanelView:KeypadPageViewController?
    
    var delegate: KeypadDelegate?
    
    var showEquationView: Bool = true
    
    var workPanelDelegate: WorkPanelDelegate?
    
    var blurView: UIVisualEffectView?
    var scrollPreventionTimer:Timer?
    
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
        
        // currentEquation = EquationStore.sharedStore.currentEquation()
        
        // initial equation
        //currentEquation.question = "2+2+2+2+2+2+2+2+2+2+2+2+2+2+2+2+2+2+2+2+2+2+2+2+2+2+"
        //currentEquation.question = "2+2+2+2+2+2+2+2+"
        
        self.loadCurrentEquationFromUserDefaults()
        
        //workPanelDelegate?.updateEquation(currentEquation)
        
        updateViews(currentCursor: nil)
        
        self.themeChanged()
        
        // Setup tutorial pages
        if NumericalViewHelper.isDevicePad() {
            tutorialPages = ["Welcome to Numerical²!\nIt's still the calculator without equal.","Your calculations are saved in your History List.\nIt syncs with iCloud\n(or you can turn that off).", "Press the Menu button \nto get to Settings and\nthe Theme Creator.", "You can also customise and\ntweak a lot of features.", "Thanks!"]
        } else {
            tutorialPages = ["Welcome to Numerical²!\nIt's still the calculator without equal.","Swipe Right to see your History.\nIt syncs with iCloud\n(or you can turn that off).", "Swipe Left to get to the scientific keys.\nSwipe again for Settings,\nand the Theme Creator.", "You can also customise and\ntweak a lot of features.", "Thanks!"]
        }
        
        self.tutorialLabel.isHidden = true
        self.tutorialButton.isHidden = true
    }
    
    
    func selectedQuestion(question: String) {
        self.saveCurrentEquationToHistoryIfNeeded()
        
        WorkingEquationManager.sharedManager.insertToHistory(question: question)
        
//        currentEquation = WorkingEquation()
//        currentEquation.question = question
        
        updateLegalKeys()
        
        updateViews(currentCursor: nil)
    }
    
    func historyDeleted() {
        // Do nothing
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
        
        let currentEquation = WorkingEquationManager.sharedManager.currentEquation()
        
        if let theView = equationView {
            
            theView.setQuestion(Evaluator.balanceBracketsForQuestionDisplay(currentEquation), cursorPosition: currentCursor)
            
            // Solve this question
            let originalRequestQuestion = currentEquation
            // solveStringSyncQueue
            
            TimeTester.shared.printTime(string: "6 - Begain evaluation")
            
            CalculatorBrain.sharedBrain.solveStringAsyncQueue(currentEquation, completion: { (answer: AnswerBundle) -> Void in
                
                if originalRequestQuestion == WorkingEquationManager.sharedManager.currentEquation() {
                    // Result is relevant
                    
//                    if let error = answer.errorType {
//                        self.currentEquation.answer = error.rawValue
//                    } else {
//                        self.currentEquation.answer = answer.answer
//                    }
                    
                    theView.setAnswer(answer)
                }
            })
        }
    }
    
    func currentSelectedRange() -> (lower: Int, upper: Int)? {
        
        //if questionTextFieldIsEditting() {
            if let textField = equationView?.questionView?.textField {
                
                if let selectedRange = textField.selectedTextRange {
                    
                    let cursorStartPosition = textField.offset(from: textField.beginningOfDocument, to: selectedRange.start)
                    let cursorEndPosition = textField.offset(from: textField.beginningOfDocument, to: selectedRange.end)
                    
                    if cursorEndPosition > cursorStartPosition {
                        return (lower: cursorStartPosition, upper: cursorEndPosition)
                    }
                }
            }
        //}
        
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
    
    func enableScrolling() {
        scrollPreventionTimer?.invalidate()
        scrollPreventionTimer = nil
        
        if let keyPanelView = keyPanelView {
            keyPanelView.enableScrolling()
        }
    }
    
    func pressedKey(_ key: Character, sourceView: UIView?) {
        // print("key: \(key)")
        
        TimeTester.shared.printTime(string: "2 - WorkPanelVC, pressed key \(key)")
        
        if let keyPanelView = keyPanelView {
            if keyPanelView.isPageScrolling() {
                // We are scrolling. Abort this.
                //return
            }
            
            // Disable the keyPanelView, set a timer to turn it back on.
            
            scrollPreventionTimer?.invalidate()
            
            scrollPreventionTimer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(WorkPanelViewController.enableScrolling), userInfo: nil, repeats: false)
            
            keyPanelView.disableScrolling()
        }
        
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
//        if PremiumCoordinator.shared.canUserAccessKey(character: key) == false {
//            self.presentSalesScreen(type: SalesScreenType.scientificKey)
//            return
//        }
        
        // A key has been pressed, determine if we should be inserting this character at the end of the string or somewhere in the middle
        var newCursorPosition:Int?
        
        if key == SymbolCharacter.clear {
            
            self.clearEquationAnimation()
            
            return // Don't do any updates as yet
            
        } else if key == SymbolCharacter.delete {
            
            // Delete
            newCursorPosition = updateCurrentQuestionByDeletingCurrentRange()
            
        } else if key == SymbolCharacter.smartBracket {
            
            let currentEquation = WorkingEquationManager.sharedManager.currentEquation()
            
            if let legalKeys = Glossary.legalCharactersToAppendString(currentEquation) {
                if legalKeys.contains(SymbolCharacter.smartBracketPrefersClose) {
                    newCursorPosition = updateCurrentQuestionByAppendingCharacters(characters: [Character(")")])
                } else if legalKeys.contains(")") {
                    newCursorPosition = updateCurrentQuestionByAppendingCharacters(characters: [Character(")")])
                } else if legalKeys.contains("(") {
                    newCursorPosition = updateCurrentQuestionByAppendingCharacters(characters: [Character("(")])
                }
            }
            
            //EquationStore.sharedStore.equationUpdated(equation: equation)
            
        } else {
            
            let currentEquation = WorkingEquationManager.sharedManager.currentEquation()
            
            TimeTester.shared.printTime(string: "4 - WorkPanelVC, add to existing equation")
            
            if Glossary.shouldAddClosingBracketToAppendString(currentEquation, newOperator: key) && currentCursorPositionIsAtEnd() {
                newCursorPosition = updateCurrentQuestionByAppendingCharacters(characters: [Character(")"), key])
            } else {
                newCursorPosition = updateCurrentQuestionByAppendingCharacters(characters: [key])
            }
            
            
            //newCursorPosition = updateCurrentQuestionByAppendingCharacters(characters: [key])
            
            //EquationStore.sharedStore.equationUpdated(equation: equation)
        }
        
        updateViews(currentCursor: newCursorPosition)
        
        TimeTester.shared.printTime(string: "100 - Legal keys need updating")
        
        updateLegalKeys()
        
        TimeTester.shared.printTime(string: "101 - Legal keys updated")
        
        if let theDelegate = delegate {
            theDelegate.pressedKey(key, sourceView: sourceView)
        }
        
        self.saveCurrentEquationToUserDefaults()
    }
    
    func clearEquationAnimation() {
        clearEquationAnimation(forceUp: false)
    }
    
    func clearEquationAnimation(forceUp: Bool) {
        // Animate the equation view moving.
        SoundManager.sharedStore.playSound(sound: SoundType.clear)
        
        if let equationView = equationView {
            
            UIView.animate(withDuration: 0.1, animations: {
                
                if self.currentEquationNeedsSave() || forceUp {
                    
                    let distance:CGFloat = 20
                    
                    if forceUp {
                        equationView.view.frame.origin.y -= distance
                    } else {
                        if NumericalViewHelper.historyBehindKeypadNeeded() {
                            // If history is behind keypad then move it up
                            equationView.view.frame.origin.y -= distance
                        } else if NumericalViewHelper.historyBesideKeypadNeeded() {
                            equationView.view.frame.origin.x -= distance
                        } else if NumericalViewHelper.historyKeypadNeeded() {
                            equationView.view.frame.origin.x += distance
                        }
                    }
                }
                
                equationView.view.alpha = 0.0
            }, completion: { (complete) in
                
                self.resetEquationViewPosition()
                equationView.view.alpha = 1.0
                
                if forceUp {
                    // Force the save
                    self.saveCurrentEquation()
                } else {
                    self.saveCurrentEquationToHistoryIfNeeded()
                }
                
                // Make a new equation
                WorkingEquationManager.sharedManager.insertToHistory(question: "") // Start a new equation.
                
                self.finishEquationChange()
            })
        }
    }
    
    func startNewFromAnswerAnimation() {
        
        CalculatorBrain.sharedBrain.solveStringSyncQueue(WorkingEquationManager.sharedManager.currentEquation()) { (bundle) in
            
            if let answer = bundle.answer {
                
                if let equationView = self.equationView {
                    
                    if answer == WorkingEquationManager.sharedManager.currentEquation() {
                        // Don't complete this animation, bump it.
                        
                        SoundManager.sharedStore.playSound(sound: SoundType.thud)
                        
                        let distance:CGFloat = 20
                        
                        UIView.animate(withDuration: 0.1, animations: {
                            
                            equationView.view.frame.origin.y += distance
                            
                        }, completion: { (complete) in
                            
                            UIView.animate(withDuration: 0.1, animations: {
                                
                                self.resetEquationViewPosition()
                                
                            }, completion: { (complete) in
                                
                            })
                        })
                        
                    } else {
                        // Animate the shift
                        
                        SoundManager.sharedStore.playSound(sound: SoundType.clear)
                        
                        UIView.animate(withDuration: 0.1, animations: {
                            
                            let distance:CGFloat = 20
                            
                            equationView.view.frame.origin.y += distance
                            
                            equationView.view.alpha = 0.0
                        }, completion: { (complete) in
                            
                            self.resetEquationViewPosition()
                            
                            self.saveCurrentEquationToHistoryIfNeeded()
                            
                            // Make a new equation
                            WorkingEquationManager.sharedManager.insertToHistory(question: answer) // Start a new equation.
                            
                            self.finishEquationChange()
                            
                            UIView.animate(withDuration: 0.1, animations: {
                                equationView.view.alpha = 1.0
                            }, completion: { (complete) in
                                
                            })
                            
                        })
                        
                    }
                }
                
            }
        }
    }
    
    func redoEquationAnimation() {
        // The user swiped right in order to restore.
        
        SoundManager.sharedStore.playSound(sound: SoundType.redo)
        
        if let equationView = equationView {
            
            let distance:CGFloat = 20
            
            UIView.animate(withDuration: 0.1, animations: {
                
                equationView.view.frame.origin.x += distance
                
                equationView.view.alpha = 0.0
                
            }, completion: { (complete) in
                
                self.resetEquationViewPosition()
                
                self.finishEquationChange() // This updates the legal keys and views.
                
                UIView.animate(withDuration: 0.1, animations: {
                    
                    equationView.view.alpha = 1.0
                    
                }, completion: { (complete) in
                    
                })
            })
        }
    }
    
    func undoEquationAnimation() {
        // The user swiped right in order to restore.
        
        SoundManager.sharedStore.playSound(sound: SoundType.undo)
        
        if let equationView = equationView {
            
            let distance:CGFloat = 20
            
            UIView.animate(withDuration: 0.1, animations: {
                
                equationView.view.frame.origin.x -= distance
                
                equationView.view.alpha = 0.0
            }, completion: { (complete) in
                
                self.resetEquationViewPosition()
                
                self.finishEquationChange() // This updates the legal keys and views.
                
                UIView.animate(withDuration: 0.1, animations: {
                    
                    equationView.view.alpha = 1.0
                    
                }, completion: { (complete) in
                    
                })
            })
        }
    }
    
    func redoEquationAnimationFailed() {
        // The user swiped right in order to restore but it failed.
        
        SoundManager.sharedStore.playSound(sound: SoundType.thud)
        
        if let equationView = equationView {
            
            let distance:CGFloat = 20
            
            UIView.animate(withDuration: 0.1, animations: {
                
                equationView.view.frame.origin.x += distance
                
            }, completion: { (complete) in
                
                UIView.animate(withDuration: 0.1, animations: {
                    
                    self.resetEquationViewPosition()
                    
                }, completion: { (complete) in
                    
                })
            })
        }
    }
    
    func undoEquationAnimationFailed() {
        // The user swiped right in order to restore but it failed.
        
        SoundManager.sharedStore.playSound(sound: SoundType.thud)
        
        if let equationView = equationView {
            
            let distance:CGFloat = 20
            
            UIView.animate(withDuration: 0.05, animations: {
                
                equationView.view.frame.origin.x -= distance
                
            }, completion: { (complete) in
                
                UIView.animate(withDuration: 0.05, animations: {
                    
                    equationView.view.alpha = 1.0
                    self.resetEquationViewPosition()
                    
                }, completion: { (complete) in
                    
                })
            })
        }
    }
    
    func resetEquationViewPosition() {
        if let equationView = equationView {
            equationView.view.frame = CGRect(x: 0, y: 0, width: equationView.view.frame.width, height: equationView.view.frame.height)
        }
    }
    
    func finishEquationChange() {
        self.updateLegalKeys()
        
        self.updateViews(currentCursor: nil)
    }
    
    func saveCurrentEquationToHistoryIfNeeded() {
        if self.currentEquationNeedsSave() {
            self.saveCurrentEquation()
        }
    }
    
    func saveCurrentEquation() {
        let equation = WorkingEquationManager.sharedManager.currentEquation()
        
        CalculatorBrain.sharedBrain.solveStringAsyncQueue(equation, completion: { (bundle) in
            
            EquationStore.sharedStore.newEquation(question: equation, answer: bundle.answer)
        })
    }
    
    func currentEquationNeedsSave() -> Bool {
        let currentEquation = WorkingEquationManager.sharedManager.currentEquation()
        
        if currentEquation.characters.count > 0 {
            
            var termArray = Evaluator.termArrayFromString(currentEquation, allowNonLegalCharacters: false, treatConstantsAsNumbers: false)
            
            // Remove leading -'s
            
            while termArray.count > 0 && (termArray.first == "-" || termArray.first == String(SymbolCharacter.subtract)) {
                termArray.removeFirst()
            }
            
            if termArray.count > 1 {
                return true
            }
        }
        
        return false
    }
    
    
    func loadCurrentEquationFromUserDefaults() {
        /* // todo
        if let equationID = UserDefaults.standard.string(forKey: EquationCodingKey.currentEquation) {
            // We have an ID, fetch it
            
            if let storedEquation = EquationStore.sharedStore.fetchEquationWithIdentifier(string: equationID) {
                if let question = storedEquation.question {
                    currentEquation.question = question
                    currentEquation.hasChanged = false
                }
            }
            
        } else if let question = UserDefaults.standard.string(forKey: EquationCodingKey.currentEquationQuestion) {
            currentEquation.question = question
            currentEquation.hasChanged = UserDefaults.standard.bool(forKey: EquationCodingKey.currentEquationChanged)
        }
        */
    }
    
    func saveCurrentEquationToUserDefaults() {
        // Save the current question into UserDefaults
        /* // todo
        UserDefaults.standard.set(currentEquation.question, forKey: EquationCodingKey.currentEquationQuestion)
        UserDefaults.standard.set(currentEquation.hasChanged, forKey: EquationCodingKey.currentEquationChanged)
        
        UserDefaults.standard.removeObject(forKey: EquationCodingKey.currentEquation)
        UserDefaults.standard.synchronize()
 */
    }
    
    func currentCursorPositionIsAtEnd() -> Bool {
        
        if currentSelectedRange() == nil {
            if let index = currentCursorPosition() {
                if index == WorkingEquationManager.sharedManager.currentEquation().characters.count {
                    // There is a currentCursorPosition but it's at the end, therefore we should add a closing bracket.
                    return true
                }
            } else {
                // There is no currentCursorPosition so we are simply at the end
                return true
            }
        }
        
        return false
    }
    
    func updateCurrentQuestionByAppendingCharacters(characters: [Character]) -> Int? {
        
        var newCursorPosition:Int?
        
        // currentEquation.hasChanged = true // todo
        
        if let range = currentSelectedRange() {
            // Delete this range
            
            var newQuestion = ""
            
            var count = 0
            
            for character in WorkingEquationManager.sharedManager.currentEquation().characters {
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
            
            WorkingEquationManager.sharedManager.insertToHistory(question: newQuestion)
            
            //currentEquation.question = newQuestion
            
            newCursorPosition = range.lower + characters.count
            
        } else if var index = currentCursorPosition() {
            
            var newQuestion = WorkingEquationManager.sharedManager.currentEquation()
            
            for character in characters {
                
                newQuestion.insert(character, at: newQuestion.index(newQuestion.startIndex, offsetBy: index))
                
                index += 1
            }
            
            WorkingEquationManager.sharedManager.insertToHistory(question: newQuestion)
            
            // currentEquation.question = newQuestion
            
            newCursorPosition = index + characters.count - 1
            
        } else {
            
            
            var newQuestion = WorkingEquationManager.sharedManager.currentEquation()
            
            let stringToInsert = String(characters)
            
            newQuestion += stringToInsert
            
            
            WorkingEquationManager.sharedManager.insertToHistory(question: newQuestion)
            
            //currentEquation.question += stringToInsert
        }
        
        // If there is a selected range we need to replace that range with these characters
        
        // If there is a cursor somewhere we need to insert these characters there
        
        // If there is no cursor then just append it
        
        return newCursorPosition
    }
    
    func updateCurrentQuestionByDeletingCurrentRange() -> Int? { // Returns a new cursor position if needed
        var newCursorPosition: Int?
        
        if WorkingEquationManager.sharedManager.currentEquation().characters.count > 0 {
            
            // Here is where we delete the relevant area.
            
            if let range = currentSelectedRange() {
                // Delete this range
                
                var newQuestion = ""
                
                var count = 0
                
                for character in WorkingEquationManager.sharedManager.currentEquation().characters {
                    if count < range.lower || count >= range.upper {
                        newQuestion.append(character)
                    }
                    
                    count += 1
                }
                
                WorkingEquationManager.sharedManager.insertToHistory(question: newQuestion)
                
                // currentEquation.question = newQuestion
                
                newCursorPosition = range.lower
                
            } else if let index = currentCursorPosition() {
                
                if index > 0 {
                    // Remove the character before this index
                    
                    var newQuestion = ""
                    
                    var count = 0
                    
                    for character in WorkingEquationManager.sharedManager.currentEquation().characters {
                        if count != index-1 {
                            newQuestion.append(character)
                        }
                        
                        count += 1
                    }
                    
                    WorkingEquationManager.sharedManager.insertToHistory(question: newQuestion)
                    
                    //currentEquation.question = newQuestion
                    
                    newCursorPosition = index - 1
                }
                
            } else {
                // Just delete from the end
                
                let currentEquation = WorkingEquationManager.sharedManager.currentEquation()
                
                let newQuestion = currentEquation.substring(to: currentEquation.characters.index(before: currentEquation.endIndex))
                
                WorkingEquationManager.sharedManager.insertToHistory(question: newQuestion)
            }
            
            // If this equation is now empty then we need to delete the equation from the store.
            /*
            if "" == currentEquation.question {
                
                EquationStore.sharedStore.deleteEquation(equation: equation)
                
                currentEquation = nil
                
                if let theWorkPanelDelegate = workPanelDelegate {
                    theWorkPanelDelegate.updateEquation(currentEquation)
                }
            } else {
                EquationStore.sharedStore.equationUpdated(equation: equation)
            }
             */
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
            if let legalKeys = Glossary.legalCharactersToAppendString(WorkingEquationManager.sharedManager.currentEquation()), let theKeyPanel = keyPanelView {
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
            
            //equationView?.currentQuestion = currentEquation.question
        }
    }
    
    func textFieldChanged(string: String, view: QuestionCollectionViewController) {
        
        
        WorkingEquationManager.sharedManager.insertToHistory(question: string)
        
        //currentEquation.question = string
        updateViews(currentCursor: nil)
        
        updateLegalKeys()
    }
    
    func startNew(string: String, view: QuestionCollectionViewController) {
        // Start a new equation using this as a base.
        self.startNewFromAnswerAnimation()
    }
    
    func isQuestionEditing() -> Bool {
        if let equationView = equationView {
            return equationView.isQuestionEditting()
        }
        return false
    }
    
    func userPressedCopyAll() {
        var string = ""
        
        let bracketBalancedString = Evaluator.balanceBracketsForQuestionDisplay(WorkingEquationManager.sharedManager.currentEquation())
        
        string += Glossary.formattedStringForQuestion(bracketBalancedString)
        
        let board = UIPasteboard.general
        board.string = string
    }
}
