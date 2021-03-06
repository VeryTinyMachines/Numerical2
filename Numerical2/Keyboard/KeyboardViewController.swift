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
    
    @IBOutlet weak var separatorView: UIView!
    @IBOutlet weak var separatorViewHeight: NSLayoutConstraint!
    
    @IBOutlet weak var stackView: UIStackView!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var copyButton: UIButton!
    @IBOutlet weak var pasteButton: UIButton!
    
    var question:String = ""
    var answer:String = ""
    
    var interfaceSetup = false
    
    var gradiantLayer:CAGradientLayer?
    
    var legalCharacters:Set<Character>?
    
    var menuVisible = false
    
    var buttonLookup:[Character] = [SymbolCharacter.clear, "%", "7", "8", "9", SymbolCharacter.smartBracket, SymbolCharacter.delete,
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
        
        self.updateAlphaLevels(size: self.view.frame.size)
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
            
            let buttonRaw = buttonLookup[theButton.tag]
            
            if let formattedButton = Glossary.formattedLookup[buttonRaw] {
                theButton.setTitle(formattedButton, for: UIControlState.normal)
            } else {
                theButton.setTitle(String(buttonRaw), for: UIControlState.normal)
            }
            
            theButton.titleLabel?.font = StyleFormatter.preferredFontForButtonOfSize(theButton.frame.size, key: buttonRaw)
            
            if buttonRaw == SymbolCharacter.keyboard {
                theButton.addTarget(self, action: #selector(handleInputModeList(from:with:)), for: .allTouchEvents)
            } else {
                theButton.addTarget(self, action: #selector(KeyboardViewController.buttonPressed(sender:)), for: UIControlEvents.touchUpInside)
            }
        }
        
        cancelButton.titleLabel?.font = StyleFormatter.preferredFontForContext(FontDisplayContext.questionWidget)
        
        copyButton.titleLabel?.font = StyleFormatter.preferredFontForContext(FontDisplayContext.questionWidget)
        
        pasteButton.titleLabel?.font = StyleFormatter.preferredFontForContext(FontDisplayContext.questionWidget)
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
            
            if let loadedFirstColor = defs.colorForKey(key: "CurrentTheme.firstColor") {
                firstColor = loadedFirstColor
                
                if let loadedSecondColor = defs.colorForKey(key: "CurrentTheme.secondColor") {
                    
                    if let loadedStyle = defs.object(forKey: "CurrentTheme.style") as? String {
                        
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
            
            let formattedAnswer = Glossary.formattedStringForAnswer(answer)
            
            let formattedQuestion = Glossary.formattedStringForQuestion(Evaluator.balanceBracketsForQuestionDisplay(question))
            
            mainLabel.text = "\(formattedQuestion) = \(formattedAnswer)"
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
        
        separatorView.backgroundColor = foregroundColor.withAlphaComponent(0.25)
        separatorViewHeight.constant = 0.5
        
        for theButton in button {
            let buttonRaw = buttonLookup[theButton.tag]
            
            if buttonRaw == SymbolCharacter.keyboard {
                // enabled
                theButton.isEnabled = true
                theButton.setTitleColor(foregroundColor, for: UIControlState.normal)
                //theButton.backgroundColor = foregroundColor.withAlphaComponent(0.1)
                theButton.backgroundColor = UIColor.clear
            } else if buttonRaw == SymbolCharacter.smartBracket {
                print("")
                UIView.performWithoutAnimation {
                    if legals.contains(SymbolCharacter.smartBracketPrefersClose) {
                        theButton.setTitle(")", for: UIControlState.normal)
                    } else if legals.contains("(") {
                        theButton.setTitle("(", for: UIControlState.normal)
                    } else if legals.contains(")") {
                        theButton.setTitle(")", for: UIControlState.normal)
                    } else {
                        theButton.setTitle("(", for: UIControlState.normal)
                    }
                }
            }
            
            if legals.contains(buttonRaw) {
                // enabled
                theButton.isEnabled = true
                theButton.setTitleColor(foregroundColor, for: UIControlState.normal)
                // theButton.backgroundColor = foregroundColor.withAlphaComponent(0.1)
                theButton.backgroundColor = UIColor.clear
            } else {
                // disabled
                
                theButton.isEnabled = false
                theButton.setTitleColor(foregroundColor.withAlphaComponent(0.33), for: UIControlState.normal)
                // theButton.backgroundColor = nil
                theButton.backgroundColor = UIColor.clear
            }
            
            theButton.layer.borderWidth = 0.5
            theButton.layer.borderColor = foregroundColor.withAlphaComponent(0.25).cgColor
        }
        
        cancelButton.setTitleColor(foregroundColor, for: UIControlState.normal)
        copyButton.setTitleColor(foregroundColor, for: UIControlState.normal)
        pasteButton.setTitleColor(foregroundColor, for: UIControlState.normal)
        
        self.updateAlphaLevels(size: self.view.frame.size)
    }
    
    func keyPressed(sender: AnyObject?) {
        let button = sender as! UIButton
        let title = button.title(for: .normal)
        (textDocumentProxy as UIKeyInput).insertText(title!)
    }
    
    
    func buttonPressed(sender: UIButton) {
        
        if menuVisible {
            closeMenu()
            return
        }
        
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
            
        } else if buttonRaw == SymbolCharacter.smartBracket {
            
            if let legalKeys = Glossary.legalCharactersToAppendString(question) {
                if legalKeys.contains(SymbolCharacter.smartBracketPrefersClose) {
                    question.append(")")
                } else if legalKeys.contains(")") {
                    question.append(")")
                } else if legalKeys.contains("(") {
                    question.append("(")
                }
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
    
    func calculate() {
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
    
    func updateAlphaLevels(size: CGSize) {
        if menuVisible {
            mainLabel.alpha = 0.0
            stackView.alpha = 1.0
            
            if question != "" {
                pasteButton.isEnabled = true
                pasteButton.alpha = 1.0
            } else {
                pasteButton.isEnabled = false
                pasteButton.alpha = 0.5
            }
            
            if question != "" {
                copyButton.isEnabled = true
                copyButton.alpha = 1.0
            } else {
                copyButton.isEnabled = false
                copyButton.alpha = 0.5
            }
            
        } else {
            mainLabel.alpha = 1.0
            stackView.alpha = 0.0
        }
    }
    
    @IBAction func userPressedEquationButton(_ sender: UIButton) {
        if menuVisible {
            closeMenu()
        } else {
            openMenu()
        }
    }
    
    func openMenu() {
        menuVisible = true
        
        UIView.animate(withDuration: 0.25, animations: {
            self.updateAlphaLevels(size: self.view.frame.size)
        }) { (complete) in
            
        }
    }
    
    func closeMenu() {
        menuVisible = false
        
        UIView.animate(withDuration: 0.25, animations: {
            self.updateAlphaLevels(size: self.view.frame.size)
        }) { (complete) in
            
        }
    }
    
    
    @IBAction func userPressedCancelButton(_ sender: UIButton) {
        closeMenu()
    }
    
    
    @IBAction func userPressedCopyButton(_ sender: UIButton) {
        // Copy everything
        
        let board = UIPasteboard.general
        board.string = Glossary.formattedStringForAnswer(question) + "=" + Glossary.formattedStringForAnswer(answer)
        
        closeMenu()
    }
    
    @IBAction func userPressedPasteButton(_ sender: UIButton) {
        // Get text and try and paste it in here.
        
        if answer != "" {
            let formattedAnswer = Glossary.formattedStringForQuestion(question) + "=" + Glossary.formattedStringForAnswer(answer)
            (textDocumentProxy as UIKeyInput).insertText(formattedAnswer)
            closeMenu()
        }
    }

}
