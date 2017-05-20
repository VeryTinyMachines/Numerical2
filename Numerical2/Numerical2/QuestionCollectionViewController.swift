//
//  QuestionCollectionViewController.swift
//  Numerical2
//
//  Created by Andrew J Clark on 1/08/2015.
//  Copyright © 2015 Very Tiny Machines. All rights reserved.
//

import UIKit


protocol QuestionCollectionViewDelegate {
    func textFieldChanged(string: String, view: QuestionCollectionViewController)
    func startNew(string: String, view: QuestionCollectionViewController)
    func userPressedCopyAll()
}

class QuestionCollectionViewController:NumericalViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, UITextFieldDelegate, UITextViewDelegate {
    
    var delegate:QuestionCollectionViewDelegate?
    
    var isAnswerView = false
    var scrollingFromRight = false
    
    @IBOutlet weak var testLabel: UILabel!
    
    var questionBundle: AnswerBundle? {
        didSet {
            TimeTester.shared.printTime(string: "30 - Question bundle set")
            
            if self.isAnswerView {
                print(questionBundle?.answer)
                print(questionBundle?.error)
                print(questionBundle?.errorType)
                
                print("")
            }
            
            var answer = ""
            
            if let theAnswer = self.questionBundle?.answer {
                answer = theAnswer
            }
            
            print("answer: \(answer)!")
            
            
            
            // Divide up the questionString into components
            if let bundle = self.questionBundle {
                if let theAnswer = self.questionBundle?.answer {
                    // We have an answer
                    
                    // Determine if we need to display the label, the textview (WIP), or the collection view.
                    
                    if (theAnswer.characters.contains(SymbolCharacter.fraction) || self.isAnswerView) && self.isEditing == false {
                        // Need the collectionView's
                        
                        if self.isAnswerView {
                            
                            TimeTester.shared.printTime(string: "31 - This is an answerView")
                            
                            var possibleAnswers = Glossary.possibleAnswersFromString(theAnswer)
                            
                            TimeTester.shared.printTime(string: "32 - possible answers")
                            
                            // The first answer will always be a decimal. The last answer will always be the smallest possible fraction
                            if possibleAnswers.count > 1 {
                                
                                if NumericalHelper.isSettingEnabled(string: NumericalHelperSetting.preferdecimal) {
                                    // We prefer the decimal answer, so just show that one.
                                    possibleAnswers = [possibleAnswers.last!] // Get the decimal answer
                                } else {
                                    // We prefer fractional answer if available, so show that one
                                    possibleAnswers = [possibleAnswers.first!] // Get the possibly fractional answer
                                }
                            }
                            
                            let answersString = possibleAnswers.joined(separator: " or ")
                            
                            let questionComponents = answersString.components(separatedBy: " ")
                            
                            TimeTester.shared.printTime(string: "33 - Need to update question array")
                            
                            self.updateQuestionArrayWithComponents(questionComponents)
                            
                            TimeTester.shared.printTime(string: "34 - Question array method finished")
                            
                        } else {
                            
                            TimeTester.shared.printTime(string: "35 - need to update question array with answer")
                            
                            self.updateQuestionArrayWithString(theAnswer)
                            
                            TimeTester.shared.printTime(string: "36 - need to update question array with question")
                            
                            // Default height for the questionView
                            updateEquationViewHeight(height: 80)
                        }
                        
                        self.testLabel.isHidden = true
                        self.textField.isHidden = true
                        
                        self.collecitonView.delegate = self
                        self.collecitonView.dataSource = self
                        self.collecitonView.isHidden = false
                        
                    } else {
                        // Display without the collection views
                        
                        if self.isAnswerView {
                            testLabel.isHidden = false
                            textField.isHidden = true
                            
                            testLabel.text = Glossary.formattedStringForAnswer(theAnswer)
                            testLabel.font = StyleFormatter.preferredFontForContext(FontDisplayContext.answer)
                        } else {
                            testLabel.isHidden = true
                            textField.isHidden = false
                            
                            var newText = ""
                            
                            if self.isEditing {
                                newText = theAnswer
                                textField.isEditable = true
                                textField.isSelectable = true
                            } else {
                                newText = Glossary.formattedStringForQuestion(theAnswer, addSpaces: true)
                                textField.isEditable = false
                                textField.isSelectable = false
                            }
                            
                            textField.text = newText
                            textField.font = StyleFormatter.preferredFontForContext(FontDisplayContext.question)
                            
                            // Estimate the ideal height of the questionView and tell the parent.
                            
                            let attrString = NSAttributedString(string: newText, attributes: [NSFontAttributeName:StyleFormatter.preferredFontForContext(FontDisplayContext.question)])
                            
                            let boundingRect = attrString.boundingRect(with: CGSize(width: self.view.frame.width - 6 - 6, height: 2000), options: NSStringDrawingOptions.usesLineFragmentOrigin, context: nil)
                            
                            print(boundingRect.height)
                            
                            if boundingRect.height > 50 || isEditing {
                                updateEquationViewHeight(height: 80)
                            } else {
                                updateEquationViewHeight(height: 50)
                            }
                            
                            let range = NSRange.init(location: newText.characters.count - 1, length: 0)
                            
                            UIView.performWithoutAnimation {
                                textField.scrollRangeToVisible(range)
                            }
                            
                            if let cursorPosition = questionBundle?.cursorPosition {
                                if let startPosition = textField.position(from: textField.beginningOfDocument, offset: cursorPosition) {
                                    textField.selectedTextRange = textField.textRange(from: startPosition, to: startPosition)
                                }
                            }
                        }
                        
                        if self.isEditing {
                            textField.isEditable = true
                            textField.isSelectable = true
                        } else {
                            textField.isEditable = false
                            textField.isSelectable = false
                        }
                        
                        
                        testLabel.minimumScaleFactor = 0.1
                        
                        self.collecitonView.delegate = nil
                        self.collecitonView.dataSource = nil
                        self.collecitonView.isHidden = true
                    }
                } else if let errorType = bundle.errorType {
                    let formattedAnswer = Glossary.formattedStringForAnswer(errorType.rawValue)
                    print(formattedAnswer)
                    print("")
                    
                    let questionComponents = formattedAnswer.components(separatedBy: " ")
                    
                    TimeTester.shared.printTime(string: "33 - Need to update question array")
                    
                    self.updateQuestionArrayWithComponents([formattedAnswer])
                    
                    TimeTester.shared.printTime(string: "34 - Question array method finished")
                    
                    self.testLabel.isHidden = true
                    self.textField.isHidden = true
                    
                    self.collecitonView.delegate = self
                    self.collecitonView.dataSource = self
                    self.collecitonView.isHidden = false
                    
                    
                }
            }
            
        }
    }

    func updateEquationViewHeight(height: CGFloat) {
        if let parent = self.parent as? EquationViewController {
            parent.questionViewHeight.constant = height
            parent.view.layoutIfNeeded()
        }
    }
    
    func updateQuestionArrayWithString(_ questionString: String) {
        
        TimeTester.shared.printTime(string: "40")
        
        textField.text = questionString
        
        // Add balanced brackets to this string, then divide into components.
        
        let questionComponents = Evaluator.termArrayFromString(questionString, allowNonLegalCharacters: true, treatConstantsAsNumbers: false)
        
        // If a component has more than one fraction in it then split it up
        
        TimeTester.shared.printTime(string: "41")
        
        var newQuestionComponents:Array<String> = []
        
        for string in questionComponents {
            
            let firstCharacter = string.characters.first
            
            if Glossary.isStringFractionNumber(string) && firstCharacter != SymbolCharacter.fraction {
                
                var fractionComponents = string.components(separatedBy: String(SymbolCharacter.fraction))
                
                if fractionComponents.count > 2 {
                    
                    newQuestionComponents.append("\(fractionComponents[0])\(SymbolCharacter.fraction)\(fractionComponents[1])")
                    
                    fractionComponents.remove(at: 0)
                    fractionComponents.remove(at: 0)
                    
                    for component in fractionComponents {
                        newQuestionComponents.append("|")
                        newQuestionComponents.append(component)
                    }
                } else {
                    newQuestionComponents.append(string)
                }
            } else {
                if string == "or" {
                    newQuestionComponents.append("or")
                } else {
                    newQuestionComponents.append(string)
                }
            }
        }
        
        TimeTester.shared.printTime(string: "42")
        
        updateQuestionArrayWithComponents(newQuestionComponents)
    }
    
    
    func updateQuestionArrayWithComponents(_ newQuestionComponents: Array<String>) {
        
        TimeTester.shared.printTime(string: "43")
        
        // Now we need to see which parts of the this new array need reloading.
        
        /*
        var indexNeedsReload:Array<Int> = []
        
        var indexNeedsInsertion:Array<Int> = []
        
        for index in 0...self.questionArray.count {
            
            if index < self.questionArray.count && index < newQuestionComponents.count {
                if self.questionArray[index] != newQuestionComponents[index] {
                    //                            print("need to reload \(index)", appendNewline: true)
                    indexNeedsReload.append(index)
                }
            }
        }
        
        if self.questionArray.count < newQuestionComponents.count {
            
            // Need to add the index's
            for index in self.questionArray.count...newQuestionComponents.count-1 {
                indexNeedsInsertion.append(index)
            }
        }
        
        // Reload anything that needs reloading
        
        var indexSetToReload:Array<NSIndexPath> = []
        
        for index in indexNeedsReload {
            let newIndexPath = NSIndexPath(forRow: index, inSection: 0)
            indexSetToReload.append(newIndexPath)
        }
        
        var indexSetToInsert:Array<NSIndexPath> = []
        
        for index in indexNeedsInsertion {
            let newIndexPath = NSIndexPath(forRow: index, inSection: 0)
            indexSetToInsert.append(newIndexPath)
        }
        
        // Insert anything that needs inserting
        let previousCount = self.questionArray.count
        
        if previousCount > 1 && self.questionArray.count <= newQuestionComponents.count {
            
            self.questionArray = newQuestionComponents
            
            UIView.performWithoutAnimation({ () -> Void in
                if indexSetToInsert.count > 0 {
                    self.collecitonView.insertItemsAtIndexPaths(indexSetToInsert)
                }
                
                if indexSetToReload.count > 0 {
                    self.collecitonView.reloadItemsAtIndexPaths(indexSetToReload)
                }
                
                let lastItem = self.questionArray.count - 1
                
                if lastItem > 0 {
                    self.collecitonView.scrollToItemAtIndexPath(NSIndexPath(forItem: lastItem, inSection: 0), atScrollPosition: UICollectionViewScrollPosition.Right, animated: false)
                }
            })
            
        } else {
            self.questionArray = newQuestionComponents
            self.reloadCollectionView()
        }
*/
        TimeTester.shared.printTime(string: "44")
        self.questionArray = newQuestionComponents.reversed()
        TimeTester.shared.printTime(string: "45")
        self.reloadCollectionView()
        TimeTester.shared.printTime(string: "46")
        
    }
    
    var questionArray:Array<String> = []
    
    @IBOutlet weak var collecitonView: UICollectionView!
    
    @IBOutlet weak var textField: UITextView!
    
    @IBOutlet weak var textFieldTrailing: NSLayoutConstraint!
    
    @IBOutlet weak var doneButton: UIButton!
    
    func reloadCollectionView() {
        
        TimeTester.shared.printTime(string: "50 - reload question view")
        
        if Thread.isMainThread {
            TimeTester.shared.printTime(string: "51 - about to reload data")
            self.collecitonView.reloadData()
            TimeTester.shared.printTime(string: "52 - reloaded data")
        } else {
            TimeTester.shared.printTime(string: "53 - uh oh! not the main thread")
            DispatchQueue.main.async {
                self.reloadCollectionView()
            }
        }
    }
    
    func setEditingMode(editing: Bool, animated: Bool) {
        isEditing = editing
        
        if isEditing {
            
            self.collecitonView.delegate = nil
            self.collecitonView.dataSource = nil
            
            self.collecitonView.isHidden = true
            self.testLabel.isHidden = true
            
            self.textField.isEditable = true
            self.textField.isHidden = true
            
            if let theAnswer = self.questionBundle?.answer {
                textField.text = theAnswer
            }
            
            textField.becomeFirstResponder()
            self.textFieldTrailing.constant = doneButton.frame.width + 6
            doneButton.isHidden = false
        } else {
            
            let bundle = self.questionBundle
            
            self.questionBundle = bundle // this updates the states of all the different display methods.
            
            self.textField.isEditable = false
            self.textFieldTrailing.constant = 0.0
            
            if let theAnswer = self.questionBundle?.answer {
                textField.text = Glossary.formattedStringForQuestion(theAnswer, addSpaces: true)
            }
            
            textField.resignFirstResponder()
            doneButton.isHidden = true
        }
        
        if animated {
            doneButton.alpha = 0
            UIView.animate(withDuration: 0.2, animations: {
                self.view.layoutIfNeeded()
                self.doneButton.alpha = 1
            }, completion: { (complete) in
                
            })
        } else {
            self.view.layoutIfNeeded()
        }
        
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        reloadCollectionView()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let nib = UINib(nibName: "EquationViewCell", bundle: nil)
        collecitonView.register(nib, forCellWithReuseIdentifier: "StringCell")
        
        collecitonView.backgroundColor = UIColor.clear
        
        if isAnswerView {
//            collecitonView.backgroundColor = UIColor.blueColor()
        } else {
//            collecitonView.backgroundColor = UIColor.redColor()
        }
        
        let nib2 = UINib(nibName: "FractionViewCell", bundle: nil)
        collecitonView.register(nib2, forCellWithReuseIdentifier: "FractionCell")
        
        collecitonView.contentInset = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
        
        setEditingMode(editing: false, animated: false)
        
        textField.delegate = self
        textField.tintColor = UIColor.white
        textField.font = StyleFormatter.preferredFontForContext(FontDisplayContext.question)
        textField.backgroundColor = UIColor.clear
        //textField.borderStyle = UITextBorderStyle.none
        //textField.layer.borderColor = UIColor.white.withAlphaComponent(0.3).cgColor
//        textField.layer.borderWidth = 1
//        textField.layer.cornerRadius = 5
        
        textField.textContainer.lineBreakMode = NSLineBreakMode.byCharWrapping
        textField.inputView = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
        
        NotificationCenter.default.addObserver(self, selector: #selector(QuestionCollectionViewController.themeChanged), name: Notification.Name(rawValue: PremiumCoordinatorNotification.themeChanged), object: nil)
        
        themeChanged()
    }
    
    func themeChanged() {
        self.collecitonView.reloadData()
        
        textField.tintColor = ThemeCoordinator.shared.foregroundColorForCurrentTheme()
        textField.textColor = ThemeCoordinator.shared.foregroundColorForCurrentTheme()
        
        textField.layer.borderColor = ThemeCoordinator.shared.foregroundColorForCurrentTheme().withAlphaComponent(0.3).cgColor
        
        doneButton.backgroundColor = ThemeCoordinator.shared.foregroundColorForCurrentTheme().withAlphaComponent(0.25)
        doneButton.setTitleColor(ThemeCoordinator.shared.foregroundColorForCurrentTheme(), for: UIControlState.normal)
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return questionArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let string = questionArray[(indexPath as NSIndexPath).row]
        
        let firstCharacter = string.characters.first
        // If this fraction starts with a fraction then treat these as seperate things.
        
        if Glossary.isStringFractionNumber(string) && firstCharacter != SymbolCharacter.fraction {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "FractionCell", for: indexPath)
            
            if let theCell = cell as? FractionViewCell {
                
                let fractionComponents = string.components(separatedBy: String(SymbolCharacter.fraction))
                
                if fractionComponents.count == 2 {
                    theCell.numeratorLabel.text = Glossary.formattedStringForQuestion(fractionComponents[0])
                    theCell.denominatorLabel.text = Glossary.formattedStringForQuestion(fractionComponents[1])
                    if isAnswerView {
                        // This is a fraction in the answer view
                        theCell.setAnswerCell(FractionViewCellType.answer)
                    } else {
                        // This is a fraction in the question view
                        theCell.setAnswerCell(FractionViewCellType.question)
                    }
                }
            }
            
            //cell.transform = CGAffineTransform(scaleX: -1.0, y: 1.0)
            
            return cell
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "StringCell", for: indexPath)
            
            if let theCell = cell as? EquationViewCell {
                
                let string = questionArray[(indexPath as NSIndexPath).row]
                
                var cellIsOr = false
                
                if string == "or" {
                    cellIsOr = true
                    theCell.mainLabel.text = "  or  "
                } else {
                    if isAnswerView {
                        theCell.mainLabel.text = Glossary.formattedStringForAnswer(string)
                    } else {
                        theCell.mainLabel.text = Glossary.formattedStringForQuestion(string)
                    }
                }
                
                theCell.mainLabel.textColor = UIColor.white
                
                if cellIsOr {
                    theCell.setAnswerCell(EquationViewCellType.or)
                } else {
                    if isAnswerView {
                        // This is a fraction in the answer view
                        theCell.setAnswerCell(EquationViewCellType.answer)
                    } else {
                        // This is a fraction in the question view
                        theCell.setAnswerCell(EquationViewCellType.question)
                    }
                }
            }
            
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        // Estimate size with label
        
        let viewWidth:CGFloat = 2000.0
        
        let string = questionArray[(indexPath as NSIndexPath).row]
        
        let firstCharacter = string.characters.first
        
        var width:CGFloat = 0.0
        
        if Glossary.isStringFractionNumber(string) && firstCharacter != SymbolCharacter.fraction {
            
            let fractionComponents = string.components(separatedBy: String(SymbolCharacter.fraction))
            
            if isAnswerView {
                for string in fractionComponents {
                    let size = estimatedSizeOfString(Glossary.formattedStringForQuestion(string), context: FontDisplayContext.answerFraction, cellHeight: collectionView.bounds.height, viewWidth: viewWidth)
                    
                    if size.width > width {
                        width = size.width
                    }
                }
            } else {
                for string in fractionComponents {
                    let size = estimatedSizeOfString(Glossary.formattedStringForQuestion(string), context: FontDisplayContext.questionFraction, cellHeight: collectionView.bounds.height, viewWidth: viewWidth)
                    
                    if size.width > width {
                        width = size.width
                    }
                }
            }
            
        } else {
            
            if string == "or" {
                let size = estimatedSizeOfString("  or  ", context: FontDisplayContext.answerOr, cellHeight: collectionView.bounds.height, viewWidth: viewWidth)
                
                return CGSize(width: size.width + 1, height: collectionView.bounds.height)
            } else {
                
                if isAnswerView {
                    let size = estimatedSizeOfString(Glossary.formattedStringForAnswer(string), context: FontDisplayContext.answer, cellHeight: collectionView.bounds.height, viewWidth: viewWidth)
                    
                    width = size.width + 1
                } else {
                    let size = estimatedSizeOfString(Glossary.formattedStringForQuestion(string), context: FontDisplayContext.question, cellHeight: collectionView.bounds.height, viewWidth: viewWidth)
                    
                    width = size.width + 1
                }
            }
        }
        
        if width > viewWidth {
            width = viewWidth
        }
        
        if width > collectionView.bounds.width - 20 {
            width = collectionView.bounds.width - 20
        }
        
        return CGSize(width: width, height: collectionView.bounds.height)
    }
    
    
    func estimatedSizeOfString(_ string: String, context: FontDisplayContext, cellHeight: CGFloat, viewWidth: CGFloat) -> CGSize {
        
        let font = StyleFormatter.preferredFontForContext(context)
        let attributedText = NSAttributedString(string: string, attributes: [NSFontAttributeName:font])
        
        let size = attributedText.boundingRect(with: CGSize(width: viewWidth, height: cellHeight), options: NSStringDrawingOptions.usesLineFragmentOrigin, context: nil);
        
        if isAnswerView && size.width > self.view.frame.width - collecitonView.contentInset.left - collecitonView.contentInset.right {
            return CGSize(width: self.view.frame.width - collecitonView.contentInset.left - collecitonView.contentInset.right, height: size.height)
        }
        
        return size.size
    }
    
    
    @IBAction func userPressedTapGesureRecogniser(_ sender: UITapGestureRecognizer) {
        
        if isMenuVisible() {
            self.hideMenu()
        } else {
            var menuItems = [UIMenuItem]()
            
            if canEdit() {
                let menuItem = UIMenuItem(title: "Edit", action: #selector(QuestionCollectionViewController.pressedMenuItemEdit))
                menuItems.append(menuItem)
            }
            
            if canCopyAnswer() {
                let menuItem = UIMenuItem(title: "Copy", action: #selector(QuestionCollectionViewController.pressedMenuItemCopy))
                menuItems.append(menuItem)
            }
            
            if canCopyEquation() {
                let menuItem = UIMenuItem(title: "Copy", action: #selector(QuestionCollectionViewController.pressedMenuItemCopyAll))
                menuItems.append(menuItem)
            }
            
            if canUseAnswerAsNew() {
                let menuItem = UIMenuItem(title: "Start New", action: #selector(QuestionCollectionViewController.pressedMenuItemStartNewWith))
                menuItems.append(menuItem)
            }
            
            if canPaste() {
                let menuItem = UIMenuItem(title: "Paste", action: #selector(QuestionCollectionViewController.pressedMenuItemPaste))
                menuItems.append(menuItem)
            }
            
            if canPasteAppend() {
                let menuItem = UIMenuItem(title: "Paste At End", action: #selector(QuestionCollectionViewController.pressedMenuItemPasteAppend))
                menuItems.append(menuItem)
            }
            
            presentMenu(menuItems: menuItems, targetRect: self.view.frame, inView: self.view)
        }
    }
    
    override var canBecomeFirstResponder: Bool {
        return true
    }
    
    func pressedMenuItemEdit() {
        if self.isAnswerView == false && self.isEditing == false {
            self.setEditingMode(editing: !isEditing, animated: true)
        }
        
        informDelegateOfTextChange()
        
        hideMenu()
    }
    
    func canCopyAnswer() -> Bool {
        if isAnswerView {
            // Copying means just copying the answer
            if let bundle = questionBundle {
                if let answer = bundle.answer {
                    if answer != "" {
                        return true
                    }
                }
            }
        }
        
        
        return false
    }
    
    func canCopyEquation() -> Bool {
        if isAnswerView == false {
            // Copying the equation means copying the question and the answer
            if let bundle = questionBundle {
                if let answer = bundle.answer {
                    if answer != "" {
                        return true
                    }
                }
            }
        }
        
        return false
    }
    
    func canUseAnswerAsNew() -> Bool {
        if isAnswerView {
            if let bundle = questionBundle {
                if let answer = bundle.answer {
                    if answer != "" {
                        return true
                    }
                }
            }
        }
        
        return false
    }
    
    func canEdit() -> Bool {
        if isAnswerView == false {
            return true
        }
        
        return false
    }
    
    func canPaste() -> Bool {
        if canEdit() {
            let board = UIPasteboard.general
            if let _ = board.string {
                return true
            }
        }
        
        return false
    }
    
    func canPasteAppend() -> Bool {
        // If there is already something in this question then we append it
        if canPaste() {
            if let bundle = questionBundle {
                if let answer = bundle.answer {
                    if answer.characters.count > 0 {
                        return true
                    }
                }
            }
        }
        
        return false
    }
    
    func pressedMenuItemCopy() {
        if let bundle = questionBundle {
            if let answer = bundle.answer {
                let formattedAnswer = Glossary.formattedStringForQuestion(answer)
                
                let board = UIPasteboard.general
                board.string = formattedAnswer
            }
        }
        
        hideMenu()
    }
    
    func pressedMenuItemCopyAll() {
        delegate?.userPressedCopyAll()
        hideMenu()
    }
    
    func pressedMenuItemStartNewWith() {
        if let bundle = questionBundle {
            if let answer = bundle.answer {
                delegate?.startNew(string: answer, view: self)
            }
        }
        
        hideMenu()
    }
    
    func pressedMenuItemPaste() {
        let board = UIPasteboard.general
        if var string = board.string {
            string = cleanupPastedString(string: string)
            delegate?.textFieldChanged(string: string, view: self)
        }
        
        hideMenu()
    }
    
    func pressedMenuItemPasteAppend() {
        let board = UIPasteboard.general
        if var string = board.string {
            string = cleanupPastedString(string: string)
            
            if let bundle = questionBundle {
                if let answer = bundle.answer {
                    string = answer + string
                }
            }
            
            delegate?.textFieldChanged(string: string, view: self)
        }
        
        hideMenu()
    }
    
    func cleanupPastedString(string: String) -> String {
        let newString = string.replacingOccurrences(of: " ", with: "")
        
        if newString.contains("=") {
            let stringItems = string.components(separatedBy: "=")
            if let lastString = stringItems.last {
                return lastString
            }
        }
        
        return newString
    }
    
    @IBAction func pressDoneButton(_ sender: UIButton) {
        informDelegateOfTextChange()
        
        setEditingMode(editing: false, animated: true)
    }
    
    func informDelegateOfTextChange() {
        if let text = textField.text {
            delegate?.textFieldChanged(string: text, view: self)
        } else {
            delegate?.textFieldChanged(string: "", view: self)
        }
    }
    
    @IBAction func textFieldChanged(_ sender: UITextField) {
        print("textFieldChanged")
        informDelegateOfTextChange()
    }
    
    func textViewDidChange(_ textView: UITextView) {
        print("textViewDidChange")
        informDelegateOfTextChange()
    }
    
    func isQuestionEditting() -> Bool {
        return isEditing
    }
    
    
    @IBAction func userSwipedLeft(_ sender: UISwipeGestureRecognizer) {
        print("Swiped")
    }
    
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        
        if scrollView.contentOffset.x >= -10 {
            scrollingFromRight = true
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.contentOffset.x < -10 && scrollingFromRight {
            // We have scroll from a starting spot but we should not have
            scrollView.isScrollEnabled = false
            scrollView.contentOffset = CGPoint(x: -10, y: 0)
            scrollView.isScrollEnabled = true
        }
        
        scrollingFromRight = false
    }
}
