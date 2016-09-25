//
//  EquationViewController.swift
//  Numerical2
//
//  Created by Andrew J Clark on 1/08/2015.
//  Copyright © 2015 Very Tiny Machines. All rights reserved.
//

import UIKit

protocol EquationTextFieldDelegate {
    func questionChanged(_ newQuestion: String, overwrite: Bool)
}

class EquationViewController: UIViewController, CalculatorBrainDelete, UITextFieldDelegate, KeypadDelegate {
    
    @IBOutlet weak var answerLabel: UILabel!
    @IBOutlet weak var questionLabel: UILabel!
    
    var currentQuestion:String?
    var currentAnswer:AnswerBundle?
    
    var questionView:QuestionCollectionViewController?
    var answerView:QuestionCollectionViewController?
    
    var delegate:EquationTextFieldDelegate?
    var questionTextDelegate:QuestionCollectionViewDelegate?
    
    var cursorPosition:Int?
    
    @IBOutlet weak var textField: UITextField!
    
    func pressedKey(_ key: Character) {
        
    }
    
    
    func setQuestion(_ string: String, cursorPosition: Int?) {
        currentQuestion = string
        self.cursorPosition = cursorPosition
        updateView()
    }
    
    
    func setAnswer(_ answer: AnswerBundle) {
        currentAnswer = answer
        updateView()
    }
    
    
    func updateView() {
        
        if let theQuestionView = questionView, var theQuestion = currentQuestion {
            
            if theQuestion.rangeOfCharacter(from: CharacterSet(charactersIn: "abcdefghijklmnopqrstuvwxyz"), options: NSString.CompareOptions.caseInsensitive, range: nil) != nil {
                
                if let translatedString = NaturalLanguageParser.sharedInstance.translateString(theQuestion) {
                    theQuestion = translatedString
                }
            }
            
//            let bracketBalancedString = Evaluator.balanceBracketsForQuestionDisplay(theQuestion)
            
            let questionBundle = AnswerBundle(number: theQuestion)
            questionBundle.cursorPosition = self.cursorPosition
            
            theQuestionView.questionBundle = questionBundle
        }
        
        if let theAnswerView = answerView, let answer = currentAnswer {
            theAnswerView.questionBundle = answer
        }
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
    }
    
    
    func textFieldDidChange(_ textField: UITextField) {
        print("textFieldDidChange:")
        if let theDelegate = delegate, let theText = textField.text {
            theDelegate.questionChanged(theText, overwrite: false)
        }
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "QuestionView" {
            if let theQuestionView = segue.destination as? QuestionCollectionViewController {
                theQuestionView.isAnswerView = false
                questionView = theQuestionView
                questionView?.delegate = self.questionTextDelegate
            }
        } else if segue.identifier == "AnswerView" {
            if let theAnswerView = segue.destination as? QuestionCollectionViewController {
                theAnswerView.isAnswerView = true
                answerView = theAnswerView
                
            }
        }
    }
    
    
    @IBAction func pressChangeInput(_ sender: AnyObject) {
        
        if textField.isHidden == true {
            if let theQuestionView = questionView {
                theQuestionView.view.isHidden = true
            }
            
            textField.isHidden = false
            
            if let theCurrentQuestion = currentQuestion {
                textField.text = Glossary.formattedStringForQuestion(theCurrentQuestion)
            }
            
            textField.becomeFirstResponder()

        } else {
            if let theQuestionView = questionView {
                theQuestionView.view.isHidden = false
            }
            
            textField.isHidden = true

            textField.resignFirstResponder()
            
            if let theDelegate = delegate, let theText = textField.text {
                theDelegate.questionChanged(theText, overwrite: true)
            }
            
            updateView()
        }
    }
    
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        if let theQuestionView = questionView {
            theQuestionView.view.isHidden = false
        }
        
        textField.isHidden = true
        
        if let theDelegate = delegate, let theText = textField.text {
            theDelegate.questionChanged(theText, overwrite: true)
        }
        
        textField.resignFirstResponder()
        
        return true
    }
}
