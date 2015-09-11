//
//  EquationViewController.swift
//  Numerical2
//
//  Created by Andrew J Clark on 1/08/2015.
//  Copyright © 2015 Very Tiny Machines. All rights reserved.
//

import UIKit

protocol EquationTextFieldDelegate {
    func questionChanged(newQuestion: String, overwrite: Bool)
}

class EquationViewController: UIViewController, CalculatorBrainDelete, UITextFieldDelegate {
    
    @IBOutlet weak var answerLabel: UILabel!
    @IBOutlet weak var questionLabel: UILabel!
    
    var currentQuestion:String?
    var currentAnswer:AnswerBundle?
    
    var questionView:QuestionCollectionViewController?
    var answerView:QuestionCollectionViewController?
    
    var delegate:EquationTextFieldDelegate?
    
    @IBOutlet weak var textField: UITextField!
    
    func setQuestion(string: String) {
        
        currentQuestion = string
        
        updateView()
    }
    
    func setAnswer(answer: AnswerBundle) {
        
        currentAnswer = answer
        
        updateView()
    }
    
    
    func updateView() {
        

        /*
        if var theQuestion = currentQuestion {
            
            if theQuestion.rangeOfCharacterFromSet(NSCharacterSet(charactersInString: "abcdefghijklmnopqrstuvwxyz"), options: NSStringCompareOptions.CaseInsensitiveSearch, range: nil) != nil {
                
                if let translatedString = NaturalLanguageParser.sharedInstance.translateString(theQuestion) {
                    theQuestion = translatedString
                }
            }
            
            let bracketBalancedString = Evaluator.balanceBracketsForQuestionDisplay(theQuestion)
            
            if let theQuestionView = questionView {
                theQuestionView.questionBundle = AnswerBundle(number: bracketBalancedString)
            }
            
            CalculatorBrain.sharedBrain.delegate = self
            
            if let view = self.answerView {
                
                CalculatorBrain.sharedBrain.solveStringInQueue(theQuestion, completion: { (answer) -> Void in
                    self.currentAnswer = answer
                    
                    view.isAnswerView = true
                    view.questionBundle = self.currentAnswer
                    
                })
            }
            
            
        }
*/
        
        
        if let theQuestionView = questionView, var theQuestion = currentQuestion {
            
            if theQuestion.rangeOfCharacterFromSet(NSCharacterSet(charactersInString: "abcdefghijklmnopqrstuvwxyz"), options: NSStringCompareOptions.CaseInsensitiveSearch, range: nil) != nil {
                
                if let translatedString = NaturalLanguageParser.sharedInstance.translateString(theQuestion) {
                    theQuestion = translatedString
                }
            }
            
            let bracketBalancedString = Evaluator.balanceBracketsForQuestionDisplay(theQuestion)
            
            theQuestionView.questionBundle = AnswerBundle(number: bracketBalancedString)
        }
        
        if let theAnswerView = answerView, answer = currentAnswer {
            theAnswerView.questionBundle = answer
        }
        
        
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        textField.addTarget(self, action: "textFieldDidChange:", forControlEvents: UIControlEvents.EditingChanged)
        
    }
    
    
    
    func textFieldDidChange(textField: UITextField) {
        print("textFieldDidChange:")
        if let theDelegate = delegate, theText = textField.text {
            theDelegate.questionChanged(theText, overwrite: false)
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        
        if segue.identifier == "QuestionView" {
            
            
            if let theQuestionView = segue.destinationViewController as? QuestionCollectionViewController {
                theQuestionView.isAnswerView = false
                questionView = theQuestionView
                
            }
        } else if segue.identifier == "AnswerView" {
            if let theAnswerView = segue.destinationViewController as? QuestionCollectionViewController {
                theAnswerView.isAnswerView = true
                answerView = theAnswerView
                
            }
        }
        
        
        
        // QuestionView
    }
    
    
    @IBAction func pressChangeInput(sender: AnyObject) {
        
        if textField.hidden == true {
            if let theQuestionView = questionView {
                theQuestionView.view.hidden = true
            }
            
            textField.hidden = false
            
            if let theCurrentQuestion = currentQuestion {
                textField.text = Glossary.formattedStringForQuestion(theCurrentQuestion)
            }
            
            textField.becomeFirstResponder()

        } else {
            if let theQuestionView = questionView {
                theQuestionView.view.hidden = false
            }
            
            textField.hidden = true

            textField.resignFirstResponder()
            
            if let theDelegate = delegate, theText = textField.text {
                theDelegate.questionChanged(theText, overwrite: true)
            }
            
            updateView()
        }
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        
        if let theQuestionView = questionView {
            theQuestionView.view.hidden = false
        }
        
        textField.hidden = true
        
        if let theDelegate = delegate, theText = textField.text {
            theDelegate.questionChanged(theText, overwrite: true)
        }
        
        textField.resignFirstResponder()
        
        return true
    }
    
}
