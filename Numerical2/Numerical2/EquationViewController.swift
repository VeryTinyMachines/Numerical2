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
    
    @IBOutlet weak var tutorialLabel: UILabel!
    
    var currentQuestion:String?
    var currentAnswer:AnswerBundle?
    
    var inTutorial = false
    
    var questionView:QuestionCollectionViewController?
    var answerView:QuestionCollectionViewController?
    
    var delegate:EquationTextFieldDelegate?
    var questionTextDelegate:QuestionCollectionViewDelegate?
    
    var cursorPosition:Int?
    
    func pressedKey(_ key: Character, sourceView: UIView?) {
        
    }
    
    func unpressedKey(_ key: Character, sourceView: UIView?) {
        
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
        
        if let theQuestionView = questionView, let theQuestion = currentQuestion {
            let questionBundle = AnswerBundle(number: theQuestion)
            questionBundle.cursorPosition = self.cursorPosition
            
            theQuestionView.questionBundle = questionBundle
        }
        
        if let theAnswerView = answerView, let answer = currentAnswer {
            theAnswerView.questionBundle = answer
        }
    }
    
    
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "QuestionView" {
            if let theQuestionView = segue.destination as? QuestionCollectionViewController {
                theQuestionView.isAnswerView = false
                theQuestionView.delegate = self.questionTextDelegate
                questionView = theQuestionView
            }
        } else if segue.identifier == "AnswerView" {
            if let theAnswerView = segue.destination as? QuestionCollectionViewController {
                theAnswerView.isAnswerView = true
                theAnswerView.delegate = self.questionTextDelegate
                answerView = theAnswerView
            }
        }
    }
    
    
    func isQuestionEditting() -> Bool {
        if let questionView = questionView {
            return questionView.isQuestionEditting()
        }
        
        return false
    }
}
