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
                    
                    let answersString = possibleAnswers.joinWithSeparator(" or ")
                    
                    let questionComponents = answersString.componentsSeparatedByString(" ")
                    
                    self.updateQuestionArrayWithComponents(questionComponents)
                    
                } else {
                    self.updateQuestionArrayWithString(theAnswer)
                }
                
                
                
                
            } else if let errorType = self.questionBundle?.errorType {
                // There is an error
                
                var errorString:String?
                
                switch errorType {
                case ErrorType.DivideByZero:
                    errorString = "Division by zero"
                case ErrorType.ImaginaryNumbersRequiredToSolve:
                    errorString = "Imginary numbers required to solve"
                case ErrorType.Overflow:
                    errorString = "Overflow error"
                case ErrorType.Underflow:
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

    
    func updateQuestionArrayWithString(questionString: String) {
        
        
        let questionComponents = Evaluator.termArrayFromString(questionString, allowNonLegalCharacters: true, treatConstantsAsNumbers: false)
        
        // If a component has more than one fraction in it then split it up
        
        var newQuestionComponents:Array<String> = []
        
        for string in questionComponents {
            
            let firstCharacter = string.characters.first
            
            if Glossary.isStringFractionNumber(string) && firstCharacter != SymbolCharacter.fraction {
                
                var fractionComponents = string.componentsSeparatedByString(String(SymbolCharacter.fraction))
                
                if fractionComponents.count > 2 {
                    
                    newQuestionComponents.append("\(fractionComponents[0])\(SymbolCharacter.fraction)\(fractionComponents[1])")
                    
                    fractionComponents.removeAtIndex(0)
                    fractionComponents.removeAtIndex(0)
                    
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
    
    
    func updateQuestionArrayWithComponents(newQuestionComponents: Array<String>) {
        
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
        
        if lastItem > 0 {
            collecitonView.scrollToItemAtIndexPath(NSIndexPath(forItem: lastItem, inSection: 0), atScrollPosition: UICollectionViewScrollPosition.Right, animated: false)
        }
        
    }
    
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        reloadCollectionView()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        let nib = UINib(nibName: "EquationViewCell", bundle: nil)
        collecitonView.registerNib(nib, forCellWithReuseIdentifier: "StringCell")
        
        collecitonView.backgroundColor = UIColor.clearColor()
        
        let nib2 = UINib(nibName: "FractionViewCell", bundle: nil)
        collecitonView.registerNib(nib2, forCellWithReuseIdentifier: "FractionCell")
        
        
        collecitonView.contentInset = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
        
    }
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return questionArray.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        let string = questionArray[indexPath.row]
        
        let firstCharacter = string.characters.first
        // If this fraction starts with a fraction then treat these as seperate things.
        
        if Glossary.isStringFractionNumber(string) && firstCharacter != SymbolCharacter.fraction {
            let cell = collectionView.dequeueReusableCellWithReuseIdentifier("FractionCell", forIndexPath: indexPath)
            
            if let theCell = cell as? FractionViewCell {
                
                let fractionComponents = string.componentsSeparatedByString(String(SymbolCharacter.fraction))
                
                if fractionComponents.count == 2 {
                    theCell.numeratorLabel.text = Glossary.formattedStringForQuestion(fractionComponents[0])
                    theCell.denominatorLabel.text = Glossary.formattedStringForQuestion(fractionComponents[1])
                }
                
                theCell.backgroundColor = UIColor.clearColor()
//                theCell.backgroundColor = UIColor.redColor()
                theCell.numeratorLabel.textColor = UIColor.whiteColor()
                theCell.denominatorLabel.textColor = UIColor.whiteColor()
                theCell.setAnswerCell(isAnswerView)
            }
            
            return cell
        } else {
            let cell = collectionView.dequeueReusableCellWithReuseIdentifier("StringCell", forIndexPath: indexPath)
            
            if let theCell = cell as? EquationViewCell {
                theCell.mainLabel.text = Glossary.formattedStringForQuestion(questionArray[indexPath.row])
                theCell.mainLabel.textColor = UIColor.whiteColor()
                
                theCell.backgroundColor = UIColor.clearColor()
//                theCell.backgroundColor = UIColor.redColor()
                theCell.setAnswerCell(isAnswerView)
            }
            
            return cell
        }
        
        
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        // Estimate size with label
        
        let string = questionArray[indexPath.row]
        
        let firstCharacter = string.characters.first
        
        if Glossary.isStringFractionNumber(string) && firstCharacter != SymbolCharacter.fraction {
            let fractionComponents = string.componentsSeparatedByString(String(SymbolCharacter.fraction))
            
            var width:CGFloat = 0.0
            
            for string in fractionComponents {
                let size = estimatedSizeOfString(Glossary.formattedStringForQuestion(string), context: FontDisplayContext.Answer)
                
                if size.width > width {
                    width = size.width
                }
            }
            
            return CGSize(width: width + 5, height: 44)
            
        } else {
            
            if string == "or" {
                let size = estimatedSizeOfString(" or ", context: FontDisplayContext.Answer)
                
                return CGSize(width: size.width, height: 44)
            } else {
                
                if isAnswerView {
                    let size = estimatedSizeOfString(Glossary.formattedStringForQuestion(string), context: FontDisplayContext.Answer)
                    
                    return CGSize(width: size.width + 10, height: 44)
                } else {
                    let size = estimatedSizeOfString(Glossary.formattedStringForQuestion(string), context: FontDisplayContext.Question)
                    
                    return CGSize(width: size.width, height: 44)
                }
                
            }
        }
    }
    
    func estimatedSizeOfString(string: String, context: FontDisplayContext) -> CGSize {
        
        let font = StyleFormatter.preferredFontForContext(context)
        
        
        let attributedText = NSAttributedString(string: string, attributes: [NSFontAttributeName:font])
        
        return attributedText.size()
        
//        let rect = attributedText.boundingRectWithSize(CGSize(width: 2000, height: 2000), options: NSStringDrawingOptions.UsesLineFragmentOrigin, context: nil)
//        let size = rect.size
        
        
        
//        UIFont *fontText = [UIFont fontWithName:[AppHandlers zHandler].fontName size:16];
//        // you can use your font.
//        
//        expectedLabelSize = [myString sizeWithAttributes:@{NSFontAttributeName:fontText}];
        
        
//        return CGSize(width: size.width, height: size.height)
    }
    
    
    
    
    
}
