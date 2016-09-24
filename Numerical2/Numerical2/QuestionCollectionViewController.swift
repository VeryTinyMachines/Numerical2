//
//  QuestionCollectionViewController.swift
//  Numerical2
//
//  Created by Andrew J Clark on 1/08/2015.
//  Copyright © 2015 Very Tiny Machines. All rights reserved.
//

import UIKit

class QuestionCollectionViewController:UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
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
                
                var errorString:String?
                
                switch errorType {
                case ErrorType.divideByZero:
                    errorString = "Division by zero"
                case ErrorType.imaginaryNumbersRequiredToSolve:
                    errorString = "Imginary numbers required to solve"
                case ErrorType.overflow:
                    errorString = "Overflow error"
                case ErrorType.underflow:
                    errorString = "Underflow error"
                default:
                    errorString = "Error"
                }
                
                if let theErrorString = errorString {
                    self.questionArray = [theErrorString]
                }
                
                self.reloadCollectionView()
            }
        }
    }

    
    func updateQuestionArrayWithString(_ questionString: String) {
        
        
        let questionComponents = Evaluator.termArrayFromString(questionString, allowNonLegalCharacters: true, treatConstantsAsNumbers: false)
        
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
    
    func reloadCollectionView() {
        collecitonView.reloadData()
        
        let lastItem = questionArray.count - 1
        
        if isAnswerView {
            collecitonView.scrollToItem(at: IndexPath(item: 0, section: 0), at: UICollectionViewScrollPosition.left, animated: false)
        } else if lastItem > 0 {
            collecitonView.scrollToItem(at: IndexPath(item: lastItem, section: 0), at: UICollectionViewScrollPosition.right, animated: false)
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
                
                let string = Glossary.formattedStringForQuestion(questionArray[(indexPath as NSIndexPath).row])
                
                var cellIsOr = false
                
                if string == "or" {
                    cellIsOr = true
                    theCell.mainLabel.text = "  or  "
                } else {
                    theCell.mainLabel.text = string
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
    
    
    
    
    
    
}
