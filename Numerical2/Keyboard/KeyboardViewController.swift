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
    
    @IBOutlet weak var separator: UIView!
    
    var interfaceSetup = false
    
    var gradiantLayer:CAGradientLayer?
    
    var legalCharacters:Set<Character>?
    
    var buttonLookup:[Character] = [SymbolCharacter.clear, "%", "7", "8", "9", ")", SymbolCharacter.delete,
                        SymbolCharacter.publish, ".", "4", "5", "6", SymbolCharacter.divide, SymbolCharacter.subtract,
                        SymbolCharacter.keyboard, "0", "1", "2", "3", SymbolCharacter.multiply, SymbolCharacter.add]
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if interfaceSetup == false {
            layoutInterface()
            interfaceSetup = true
            
            load()
        }
        
        self.update()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
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
            
            theButton.titleLabel?.font = StyleFormatter.preferredFontForButtonOfSize(theButton.frame.size, keyStyle: KeyStyle.Available)
            
            if buttonRaw == SymbolCharacter.keyboard {
                theButton.addTarget(self, action: #selector(handleInputModeList(from:with:)), for: .allTouchEvents)
            } else {
                theButton.addTarget(self, action: #selector(KeyboardViewController.buttonPressed(sender:)), for: UIControlEvents.touchUpInside)
            }
        }
    }
    
    func save() {
        if let defs = UserDefaults(suiteName: "group.andrewjclark.numericalapp") {
            defs.set(question, forKey: KeyboardQuestion)
            defs.set(answer, forKey: KeyboardAnswer)
            defs.synchronize()
        }
    }
    
    func load() {
        
        question = ""
        answer = ""
        
        if let defs = UserDefaults(suiteName: "group.andrewjclark.numericalapp") {
            if let loadedQuestion = defs.object(forKey: KeyboardQuestion) as? String {
                question = loadedQuestion
                if let loadedAnswer = defs.object(forKey: KeyboardAnswer) as? String {
                    answer = loadedAnswer
                }
            }
        }
    }
    
    func update() {
        
        var firstColor = UIColor.white
        var foregroundColor = UIColor.white
        var style = ThemeStyle.normal
        
        if let defs = UserDefaults(suiteName: "group.andrewjclark.numericalapp") {
            print("")
            if let loadedFirstColor = defs.colorForKey(key: "CurrentTheme.firstColor") {
                firstColor = loadedFirstColor
                
                if let loadedSecondColor = defs.colorForKey(key: "CurrentTheme.secondColor") {
                    print("")
                    if let loadedStyle = defs.object(forKey: "CurrentTheme.style") as? String {
                        
                        print(loadedFirstColor)
                        print(loadedSecondColor)
                        
                        
                        switch loadedStyle {
                        case "normal":
                            style = ThemeStyle.normal
                        case "bright":
                            style = ThemeStyle.bright
                        case "dark":
                            style = ThemeStyle.dark
                        default:
                            style = ThemeStyle.normal
                        }
                        
                        let layer = ThemeFormatter.gradiantLayerFor(firstColor: loadedFirstColor, secondColor: loadedSecondColor, style: style)
                        layer.frame = self.view.frame
                        
                        gradiantLayer?.removeFromSuperlayer()
                        self.view.layer.insertSublayer(layer, at: 0)
                        
                        gradiantLayer = layer
                        
                        foregroundColor = ThemeFormatter.foregroundColorFor(firstColor: loadedFirstColor, secondColor: loadedSecondColor, style: style)
                    }
                }
            }
        }
        
        if gradiantLayer == nil {
            
            let theme = ThemeFormatter.defaultTheme()
            
            let layer = ThemeFormatter.gradiantLayerForTheme(theme: theme)
            layer.frame = self.view.frame
            
            gradiantLayer?.removeFromSuperlayer()
            self.view.layer.insertSublayer(layer, at: 0)
            
            gradiantLayer = layer
            
            firstColor = theme.firstColor
            foregroundColor = ThemeFormatter.foregroundColorForTheme(theme: theme)
            style = theme.style
        }
        
        if question == "" {
            mainLabel.text = nil
        } else {
            
            let formattedAnswer = Glossary.formattedStringForQuestion(answer)
            
            let formattedQuestion = Glossary.formattedStringForQuestion(Evaluator.balanceBracketsForQuestionDisplay(question))
            
            mainLabel.text = "\(formattedAnswer) = \(formattedQuestion)"
            mainLabel.font = StyleFormatter.preferredFontForContext(FontDisplayContext.question)
            mainLabel.textColor = foregroundColor
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
        
        self.separator.isHidden = true
        /*
        if style == .normal {
            self.separator.isHidden = true
        } else {
            self.separator.backgroundColor = foregroundColor.withAlphaComponent(0.33)
        }
 */
        
        for theButton in button {
            let buttonRaw = buttonLookup[theButton.tag]
            
            if buttonRaw == SymbolCharacter.keyboard {
                // enabled
                theButton.isEnabled = true
                theButton.setTitleColor(foregroundColor, for: UIControlState.normal)
                theButton.backgroundColor = foregroundColor.withAlphaComponent(0.1)
            } else {
                if legals.contains(buttonRaw) {
                    // enabled
                    theButton.isEnabled = true
                    theButton.setTitleColor(foregroundColor, for: UIControlState.normal)
                    theButton.backgroundColor = foregroundColor.withAlphaComponent(0.1)
                } else {
                    // disabled
                    
                    /*
                     setTitleColor(color.withAlphaComponent(0.33), for: UIControlState())
                     self.backgroundColor = UIColor.clear
 */
                    theButton.isEnabled = false
                    theButton.setTitleColor(foregroundColor.withAlphaComponent(0.33), for: UIControlState.normal)
                    theButton.backgroundColor = nil
                }
            }
        }
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
            
            self.save()
            
            self.update()
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
