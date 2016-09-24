//
//  HistoryCell.swift
//  Numerical2
//
//  Created by Andrew J Clark on 9/09/2015.
//  Copyright © 2015 Very Tiny Machines. All rights reserved.
//

import UIKit

class HistoryCell: UITableViewCell {
    
    var equation:Equation?
    var currentEquation = false
    
    func layout(equation: Equation, currentEquation: Bool) {
        
        self.equation = equation
        self.currentEquation = currentEquation
        
        DispatchQueue.main.async {
            NotificationCenter.default.removeObserver(self)
            
            NotificationCenter.default.addObserver(self, selector: #selector(HistoryCell.updateView), name: Notification.Name(rawValue: EquationNotification.updated), object: DataKeyStore.sharedStore.keyForEquation(equation: equation))
        }
        
        if let answer = equation.answer, let question = equation.question {
            
            let formattedQuestion = Glossary.formattedStringForQuestion(question)
            let formattedAnswer = Glossary.formattedStringForQuestion(answer)
            
            textLabel?.text = "\(formattedQuestion) = \(formattedAnswer) (nil)"
            
            if let posted = equation.posted?.boolValue {
                textLabel?.text = "\(formattedQuestion) = \(formattedAnswer) (\(posted))"
            }
            
        } else {
            textLabel?.text = "Error"
        }
        
        //                cell.backgroundColor = UIColor(red: 0.0/255.0, green: 11.0/255.0, blue: 24.0/255.0, alpha: 1.0)
        backgroundColor = UIColor.clear
        textLabel?.textColor = UIColor(white: 0.6, alpha: 1.0)
        
        if currentEquation {
            textLabel?.font = UIFont.boldSystemFont(ofSize: 15.0)
            textLabel?.textColor = UIColor(white: 1.0, alpha: 1.0)
        } else {
            textLabel?.font = UIFont.systemFont(ofSize: 15.0)
            textLabel?.textColor = UIColor(white: 1.0, alpha: 0.8)
        }
    }
    
    func updateView() {
        if let equation = equation {
            layout(equation: equation, currentEquation: currentEquation)
        }
    }
    
}
