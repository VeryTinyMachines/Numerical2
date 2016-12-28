//
//  KeyboardViewController.swift
//  Keyboard
//
//  Created by Andrew Clark on 28/12/2016.
//  Copyright © 2016 Andrew J Clark. All rights reserved.
//

import UIKit

class KeyboardViewController: UIInputViewController {

    @IBOutlet var button: [UIButton]!
    
    @IBOutlet weak var mainLabel: UILabel!
    
    var question:String = ""
    var answer:String = ""
    
    var interfaceSetup = false
    
    var legalCharacters:Set<Character>?
    
    var buttonLookup:[Character] = [SymbolCharacter.clear, "%", "7", "8", "9", ")", SymbolCharacter.delete,
                        SymbolCharacter.publish, ".", "4", "5", "6", SymbolCharacter.divide, SymbolCharacter.subtract,
                        SymbolCharacter.keyboard, "0", "1", "2", "3", SymbolCharacter.multiply, SymbolCharacter.add]
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if interfaceSetup == false {
            layoutInterface()
            interfaceSetup = true
        }
        
        self.update()
    }
    
    func layoutInterface() {
        
        let nib = UINib(nibName: "KeyboardView", bundle: nil)
        let objects = nib.instantiate(withOwner: self, options: nil)
        view = objects[0] as! UIView;
        
        for theButton in button {
            print(theButton)
            
            let buttonRaw = buttonLookup[theButton.tag]
            
            if let formattedButton = Glossary.formattedLookup[buttonRaw] {
                theButton.setTitle(formattedButton, for: UIControlState.normal)
            } else {
                theButton.setTitle(String(buttonRaw), for: UIControlState.normal)
            }
            
            if buttonRaw == SymbolCharacter.keyboard {
                theButton.addTarget(self, action: #selector(handleInputModeList(from:with:)), for: .allTouchEvents)
            } else {
                theButton.addTarget(self, action: #selector(KeyboardViewController.buttonPressed(sender:)), for: UIControlEvents.touchUpInside)
            }
        }
    }
    
    func update() {
        if question == "" {
            mainLabel.text = nil
        } else {
            
            let formattedAnswer = Glossary.formattedStringForQuestion(answer)
            
            let formattedQuestion = Glossary.formattedStringForQuestion(Evaluator.balanceBracketsForQuestionDisplay(question))
            
            mainLabel.text = "\(formattedAnswer) = \(formattedQuestion)"
        }
        
        var legals = Set<Character>()
        
        if let tempLegals = Glossary.legalCharactersToAppendString(question) {
            self.legalCharacters = tempLegals
            
            legals = tempLegals
        }
        
        legals.insert(SymbolCharacter.keyboard)
        
        if answer != "" {
            legals.insert(SymbolCharacter.publish)
        }
    
        let activeColor = UIColor(hexString: "ff3caa")
        let disabledColor = UIColor(white: 0.0, alpha: 0.5)
        
        for theButton in button {
            let buttonRaw = buttonLookup[theButton.tag]
            
            if buttonRaw == SymbolCharacter.keyboard {
                // enabled
                theButton.isEnabled = true
                theButton.setTitleColor(activeColor, for: UIControlState.normal)
                theButton.backgroundColor = nil
            } else {
                if legals.contains(buttonRaw) {
                    // enabled
                    theButton.isEnabled = true
                    theButton.setTitleColor(activeColor, for: UIControlState.normal)
                    theButton.backgroundColor = activeColor.withAlphaComponent(0.05)
                } else {
                    // disabled
                    theButton.isEnabled = false
                    theButton.setTitleColor(disabledColor, for: UIControlState.normal)
                    theButton.backgroundColor = nil
                }
            }
            
        }
        
        
    }
    
    func createButtons(titles: [String]) -> [UIButton] {
        
        var buttons = [UIButton]()
        
        for title in titles {
            let button = UIButton(type: .system) as UIButton
            button.setTitle(title, for: .normal)
            button.translatesAutoresizingMaskIntoConstraints = false
            //button.setTranslatesAutoresizingMaskIntoConstraints(false)
            button.backgroundColor = UIColor(white: 1.0, alpha: 1.0)
            button.setTitleColor(UIColor.darkGray, for: .normal)
            button.addTarget(self, action: #selector(KeyboardViewController.keyPressed(sender:)), for: .touchUpInside)
            buttons.append(button)
        }
        
        return buttons
    }
    
    func keyPressed(sender: AnyObject?) {
        let button = sender as! UIButton
        let title = button.title(for: .normal)
        (textDocumentProxy as UIKeyInput).insertText(title!)
    }
    
    
    func buttonPressed(sender: UIButton) {
        
        let buttonRaw = buttonLookup[sender.tag]
        
        if buttonRaw == SymbolCharacter.clear {
            question = ""
            answer = ""
        } else if buttonRaw == SymbolCharacter.delete {
            question = question.substring(to: question.index(before: question.endIndex))
        } else if buttonRaw ==  SymbolCharacter.keyboard {
            // Do nothing, this is handled by keyPressed.
            return
        } else if buttonRaw == SymbolCharacter.publish {
            
            if answer != "" {
                
                let formattedAnswer = Glossary.formattedStringForQuestion(answer)
                
                (textDocumentProxy as UIKeyInput).insertText(formattedAnswer)
            }
            
        } else {
            
            if Glossary.shouldAddClosingBracketToAppendString(question, newOperator: buttonRaw) {
                question.append(")")
            }
            
            question.append(buttonRaw)
        }
        
        self.update()
        
        CalculatorBrain.sharedBrain.solveStringAsyncQueue(self.question) { (bundle) in
            
            if let newAnswer = bundle.answer {
                self.answer = newAnswer
            } else {
                self.answer = "Error"
            }
            
            self.update()
        }
        
    }
    
    func addConstraints(buttons: [[UIButton]], containingView: UIView){
        
        var topLeftButton:UIButton!
        
        var rowCount = 0
        var index = 0
        
        for row in buttons {
            for button in row {
                
                var topConstraint: NSLayoutConstraint!
                
                // If we're at the top left most button then we need to put the button
                
                
                
                topConstraint = NSLayoutConstraint(item: button, attribute: .top, relatedBy: .equal, toItem: containingView, attribute: .top, multiplier: 1.0, constant: 1)
                
                //let bottomConstraint = NSLayoutConstraint(item: button, attribute: .bottom, relatedBy: .equal, toItem: containingView, attribute: .bottom, multiplier: 1.0, constant: -1)
                
                var leftConstraint : NSLayoutConstraint!
                
                let widthConstraint = NSLayoutConstraint(item: topLeftButton, attribute: .width, relatedBy: .equal, toItem: button, attribute: .width, multiplier: 1.0, constant: 0)
                
                let heightConstraint = NSLayoutConstraint(item: topLeftButton, attribute: .height, relatedBy: .equal, toItem: button, attribute: .height, multiplier: 1.0, constant: 0)
                
                containingView.addConstraint(widthConstraint)
                containingView.addConstraint(heightConstraint)
                
                if index == 0 {
                    
                    leftConstraint = NSLayoutConstraint(item: button, attribute: .left, relatedBy: .equal, toItem: containingView, attribute: .left, multiplier: 1.0, constant: 1)
                    
                }else{
                    
                    leftConstraint = NSLayoutConstraint(item: button, attribute: .left, relatedBy: .equal, toItem: buttons[index-1], attribute: .right, multiplier: 1.0, constant: 1)
                }
                
                var rightConstraint : NSLayoutConstraint!
                
                if index == buttons.count - 1 {
                    
                    rightConstraint = NSLayoutConstraint(item: button, attribute: .right, relatedBy: .equal, toItem: containingView, attribute: .right, multiplier: 1.0, constant: -1)
                    
                }else{
                    
                    rightConstraint = NSLayoutConstraint(item: button, attribute: .right, relatedBy: .equal, toItem: buttons[index+1], attribute: .left, multiplier: 1.0, constant: -1)
                }
                
                containingView.addConstraints([topConstraint, rightConstraint, leftConstraint])
                //containingView.addConstraints([topConstraint, bottomConstraint, rightConstraint, leftConstraint])
                
                index += 1
                
            }
            rowCount += 1
        }
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated
    }
    
    override func textWillChange(_ textInput: UITextInput?) {
        // The app is about to change the document's contents. Perform any preparation here.
    }
    
    override func textDidChange(_ textInput: UITextInput?) {
        // The app has just changed the document's contents, the document context has been updated.
        
        //self.nextKeyboardButton.setTitleColor(textColor, for: [])
    }

}
