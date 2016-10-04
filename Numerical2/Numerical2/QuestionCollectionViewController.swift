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
}

class QuestionCollectionViewController:UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, UITextFieldDelegate {
    
    var delegate:QuestionCollectionViewDelegate?
    
    var isAnswerView = false
    
    var questionBundle: AnswerBundle? {
        didSet {
            
            // Divide up the questionString into components
           
            if let theAnswer = self.questionBundle?.answer {
                // We have an answer
                
                if self.isAnswerView {
                    
                    let possibleAnswers = Glossary.possibleAnswersFromString(theAnswer)
                    
                    var formattedAnswers:Array<String> = []
                    
                    for anAnswer in possibleAnswers {
                        
                        let formattedAnswer = Glossary.formattedStringForQuestion(anAnswer)
                        
                        formattedAnswers.append(formattedAnswer)
                    }
                    
                    let answersString = possibleAnswers.joined(separator: " or ")
                    
                    let questionComponents = answersString.components(separatedBy: " ")
                    
                    self.updateQuestionArrayWithComponents(questionComponents)
                    
                } else {
                    self.updateQuestionArrayWithString(theAnswer)
                }
                
            } else if let errorType = self.questionBundle?.errorType {
                // There is an error
                
                self.questionArray = [errorType.rawValue]
                
                self.reloadCollectionView()
            }
            
            // If there was a cursor position in this and we are currently editing then set the cursor position
            if let arbitraryValue = questionBundle?.cursorPosition {
                if isEditing {
                    if let newPosition = self.textField.position(from: textField.beginningOfDocument, in: UITextLayoutDirection.right, offset: arbitraryValue) {
                        self.textField.selectedTextRange = textField.textRange(from: newPosition, to: newPosition)
                    }
                }
            }
        }
    }

    
    func updateQuestionArrayWithString(_ questionString: String) {
        
        textField.text = questionString
        
        // Add balanced brackets to this string, then divide into components.
        
        let questionComponents = Evaluator.termArrayFromString(Evaluator.balanceBracketsForQuestionDisplay(questionString), allowNonLegalCharacters: true, treatConstantsAsNumbers: false)
        
        // If a component has more than one fraction in it then split it up
        
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
        
        updateQuestionArrayWithComponents(newQuestionComponents)
    }
    
    
    func updateQuestionArrayWithComponents(_ newQuestionComponents: Array<String>) {
        
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
        
        self.questionArray = newQuestionComponents
        self.reloadCollectionView()
        
    }
    
    var questionArray:Array<String> = []
    
    @IBOutlet weak var collecitonView: UICollectionView!
    
    @IBOutlet weak var textField: UITextField!
    
    @IBOutlet weak var doneButton: UIButton!
    
    func reloadCollectionView() {
        collecitonView.reloadData()
        
        if questionArray.count > 0 {
            DispatchQueue.main.async {
                let lastItem = self.questionArray.count - 1
                
                if self.isAnswerView {
                    self.collecitonView.scrollToItem(at: IndexPath(item: 0, section: 0), at: UICollectionViewScrollPosition.left, animated: false)
                } else if lastItem > 0 {
                    self.collecitonView.scrollToItem(at: IndexPath(item: lastItem, section: 0), at: UICollectionViewScrollPosition.right, animated: false)
                }
            }
        }
    }
    
    func setEditingMode(editing: Bool, animated: Bool) {
        isEditing = editing
        
        if isEditing {
            collecitonView.isHidden = true
            textField.isHidden = false
            textField.inputView = UIView()
            textField.becomeFirstResponder()
            doneButton.isHidden = false
        } else {
            collecitonView.isHidden = false
            textField.isHidden = true
            textField.resignFirstResponder()
            doneButton.isHidden = true
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
                
                theCell.numeratorLabel.textColor = UIColor.white
                theCell.denominatorLabel.textColor = UIColor.white
            }
            
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
                    theCell.mainLabel.text = Glossary.formattedStringForQuestion(string)
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
                    let size = estimatedSizeOfString(Glossary.formattedStringForQuestion(string), context: FontDisplayContext.answer, cellHeight: collectionView.bounds.height, viewWidth: viewWidth)
                    
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
        
        return CGSize(width: width, height: collectionView.bounds.height)
    }
    
    
    func estimatedSizeOfString(_ string: String, context: FontDisplayContext, cellHeight: CGFloat, viewWidth: CGFloat) -> CGSize {
        
        let font = StyleFormatter.preferredFontForContext(context)
        let attributedText = NSAttributedString(string: string, attributes: [NSFontAttributeName:font])
        
        let size = attributedText.boundingRect(with: CGSize(width: viewWidth, height: cellHeight), options: NSStringDrawingOptions.usesLineFragmentOrigin, context: nil);
        
        return size.size
    }
    
    
    @IBAction func userPressedTapGesureRecogniser(_ sender: UITapGestureRecognizer) {
        let menu = UIMenuController.shared
        
        if menu.menuItems == nil {
            menu.setTargetRect(self.view.frame, in: self.view)
            
            var menuItems = [UIMenuItem]()
            
            if canEdit() {
                let menuItem = UIMenuItem(title: "Edit", action: #selector(QuestionCollectionViewController.pressedMenuItemEdit))
                menuItems.append(menuItem)
            }
            
            if canCopy() {
                let menuItem = UIMenuItem(title: "Copy", action: #selector(QuestionCollectionViewController.pressedMenuItemCopy))
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
            
            
            
            // TODO - When pasting
            
            self.becomeFirstResponder()
            
            menu.menuItems = menuItems
            
            menu.setMenuVisible(true, animated: true)
        } else {
            menu.menuItems = nil
            menu.setMenuVisible(false, animated: true)
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
    
    func canCopy() -> Bool {
        if let bundle = questionBundle {
            if let answer = bundle.answer {
                if answer != "" {
                    return true
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
    
    func pressedMenuItemPaste() {
        let board = UIPasteboard.general
        if let string = board.string {
            delegate?.textFieldChanged(string: string, view: self)
        }
        
        hideMenu()
    }
    
    func pressedMenuItemPasteAppend() {
        let board = UIPasteboard.general
        if let string = board.string {
            
            var newString:String = string
            
            if let bundle = questionBundle {
                if let answer = bundle.answer {
                    newString = string + answer
                }
            }
            
            delegate?.textFieldChanged(string: newString, view: self)
        }
        
        hideMenu()
    }
    
    func hideMenu() {
        let menu = UIMenuController.shared
        menu.menuItems = nil
        menu.setMenuVisible(false, animated: true)
    }
    
    @IBAction func pressDoneButton(_ sender: UIButton) {
        setEditingMode(editing: false, animated: true)
        
        informDelegateOfTextChange()
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
    
    
    
    func isQuestionEditting() -> Bool {
        return !textField.isHidden
    }
    
    
}
