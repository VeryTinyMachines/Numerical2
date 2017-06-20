//
//  TodayViewController.swift
//  Today Widget
//
//  Created by Andrew Clark on 13/06/2017.
//  Copyright © 2017 Very Tiny Machines. All rights reserved.
//

import UIKit
import NotificationCenter

class TodayViewController: UIViewController, NCWidgetProviding {
    
    @IBOutlet var button: [UIButton]!
    
    @IBOutlet weak var stackView: UIStackView!
    
    @IBOutlet weak var menuView: UIView!
    
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var copyButton: UIButton!
    @IBOutlet weak var pasteButton: UIButton!
    
    
    var expandedHeight:CGFloat = 245
    var compactHeight:CGFloat = 95
    
    var interfaceSetup = false
    
    var question:String = ""
    var answer:String = ""
    
    var menuVisible = false
    
    @IBOutlet weak var equationButton: UIButton!
    
    @IBOutlet weak var answerLabel: UILabel!
    @IBOutlet weak var questionLabel: UILabel!
    @IBOutlet weak var emptyLabel: UILabel!
    
    @IBOutlet weak var equationAreaHeight: NSLayoutConstraint!
    
    override func viewDidLoad() {
        
        print("TodayViewController.viewDidLoad frame: \(self.view.frame)")
        
        super.viewDidLoad()
        
        updateEquationHeight(size: self.view.frame.size)
        
        // self.preferredContentSize = CGSize(width:self.view.frame.width, height:expandedHeight)
        
        if #available(iOSApplicationExtension 10.0, *) {
            self.extensionContext?.widgetLargestAvailableDisplayMode = .expanded
        }
        
        
        self.updatePreferredContentSize()
        
        if interfaceSetup == false {
            layoutInterface()
            interfaceSetup = true
        }
        
        load()
    }
    
    var gradiantLayer:CAGradientLayer?
    
    var legalCharacters:Set<Character>?
    
    var buttonLookup:[Character] = [SymbolCharacter.clear, "%", "7", "8", "9", SymbolCharacter.smartBracket, SymbolCharacter.delete,
                                    SymbolCharacter.exponent, ".", "4", "5", "6", SymbolCharacter.divide, SymbolCharacter.subtract,
                                    SymbolCharacter.app, "0", "1", "2", "3", SymbolCharacter.multiply, SymbolCharacter.add]
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.update()
        
        self.updateAlphaLevels(size: self.view.frame.size)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        self.update()
        
        self.updateAlphaLevels(size: self.view.frame.size)
    }
    
    func layoutInterface() {
        
        for theButton in button {
            
            let buttonRaw = buttonLookup[theButton.tag]
            
            if let formattedButton = Glossary.formattedLookup[buttonRaw] {
                theButton.setTitle(formattedButton, for: UIControlState.normal)
            } else {
                theButton.setTitle(String(buttonRaw), for: UIControlState.normal)
            }
            
            theButton.titleLabel?.font = StyleFormatter.preferredFontForButtonOfSize(theButton.frame.size, key: buttonRaw)
            
            theButton.addTarget(self, action: #selector(TodayViewController.buttonPressed(sender:)), for: UIControlEvents.touchUpInside)
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
        
        question = "4"
        answer = "2+2"
        
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
        
        var foregroundColor = UIColor.white
        var style = ThemeStyle.normal
        
        if let defs = UserDefaults(suiteName: "group.andrewjclark.numericalapp") {
            
            if let loadedFirstColor = defs.colorForKey(key: "CurrentTheme.firstColor") {
                
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
                        
                        layer.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: expandedHeight)
                        
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
            layer.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: expandedHeight)
            
            gradiantLayer?.removeFromSuperlayer()
            self.view.layer.insertSublayer(layer, at: 0)
            
            gradiantLayer = layer
            
            foregroundColor = ThemeFormatter.foregroundColorForTheme(theme: theme)
            style = theme.style
        }
        
        questionLabel.textColor = foregroundColor
        answerLabel.textColor = foregroundColor
        emptyLabel.textColor = foregroundColor
        
        if question == "" {
            questionLabel.text = nil
            answerLabel.text = nil
        } else {
            
            let formattedAnswer = Glossary.formattedStringForAnswer(answer)
            
            let formattedQuestion = Glossary.formattedStringForQuestion(Evaluator.balanceBracketsForQuestionDisplay(question))
            
            questionLabel.text = formattedQuestion
            answerLabel.text = formattedAnswer
            
            answerLabel.textAlignment = NSTextAlignment.right
            questionLabel.textAlignment = NSTextAlignment.right
            
            questionLabel.font = StyleFormatter.preferredFontForContext(FontDisplayContext.questionWidget)
            answerLabel.font = StyleFormatter.preferredFontForContext(FontDisplayContext.answerWidget)
        }
        
        var legals = Set<Character>()
        
        if let tempLegals = Glossary.legalCharactersToAppendString(question) {
            self.legalCharacters = tempLegals
            
            legals = tempLegals
        }
        
        legals.insert(SymbolCharacter.keyboard)
        
        if answer != "" {
            legals.insert(SymbolCharacter.app)
        }
        
        if question != "" {
            // Always allow delete
            legals.insert(SymbolCharacter.delete)
        }
        
        for theButton in button {
            let buttonRaw = buttonLookup[theButton.tag]
            
            if buttonRaw == SymbolCharacter.smartBracket {
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
                theButton.backgroundColor = UIColor.clear
            } else {
                // disabled
                
                theButton.isEnabled = false
                theButton.setTitleColor(foregroundColor.withAlphaComponent(0.33), for: UIControlState.normal)
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
            
        } else if buttonRaw == SymbolCharacter.app {
            
            let characterSetTobeAllowed = (CharacterSet(charactersIn: "!*'();:@&=+$,/?%#[] ").inverted)
            if var encodedURLString = question.addingPercentEncoding(withAllowedCharacters: characterSetTobeAllowed) {
                print("encodedURLString: \(encodedURLString)")
                
                encodedURLString = encodedURLString.replacingOccurrences(of: "^", with: "v")
                
                if let url = URL(string: "numerical://question=\(encodedURLString)") {
                    self.extensionContext?.open(url, completionHandler: { (complete) in
                        
                    })
                } else {
                    questionLabel.text = "Could not send \(encodedURLString)"
                    return
                }
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
            // Regular button press
            
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
    
    @available(iOS 10.0, *)
    @available(iOSApplicationExtension 10.0, *)
    func widgetActiveDisplayModeDidChange(_ activeDisplayMode: NCWidgetDisplayMode, withMaximumSize maxSize: CGSize) {
        
        if activeDisplayMode == .expanded {
            self.preferredContentSize = CGSize(width: maxSize.width, height: expandedHeight)
        } else if activeDisplayMode == .compact {
            self.preferredContentSize = CGSize(width: maxSize.width, height: compactHeight)
        }
    }
    
    func updatePreferredContentSize() {
        if let extensionContext = extensionContext {
            
            let maxWidth = extensionContext.widgetMaximumSize(for: extensionContext.widgetActiveDisplayMode).width
            
            if extensionContext.widgetActiveDisplayMode == .expanded {
                self.preferredContentSize = CGSize(width: maxWidth, height: expandedHeight)
            } else {
                self.preferredContentSize = CGSize(width: maxWidth, height: compactHeight)
            }
        }
    }
    
    
    func widgetPerformUpdate(completionHandler: (@escaping (NCUpdateResult) -> Void)) {
        // Perform any setup necessary in order to update the view.
        
        self.load()
        self.update()
        
        // If an error is encountered, use NCUpdateResult.Failed
        // If there's no update required, use NCUpdateResult.NoData
        // If there's an update, use NCUpdateResult.NewData
        
        completionHandler(NCUpdateResult.newData)
    }
    
    func updateEquationHeight(size: CGSize) {
        if size.height < 150 {
            equationAreaHeight.constant = compactHeight
        } else {
            equationAreaHeight.constant = compactHeight
        }
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        
        updateEquationHeight(size: size)
        
        coordinator.animate(alongsideTransition: { (context) in
            self.view.layoutIfNeeded()
            self.updateAlphaLevels(size: size)
        }) { (context) in
            self.update()
        }
    }
    
    func updateAlphaLevels(size: CGSize) {
        if size.height < 150 {
            stackView.alpha = 0.0
        } else {
            stackView.alpha = 1.0
        }
        
        if menuVisible {
            questionLabel.alpha = 0.0
            answerLabel.alpha = 0.0
            menuView.alpha = 1.0
            
            if let _ = UIPasteboard.general.string {
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
            questionLabel.alpha = 1.0
            answerLabel.alpha = 1.0
            menuView.alpha = 0.0
        }
        
        var showEmptyLabel = false
        
        if question == "" && size.height < 120 {
            showEmptyLabel = true
        }
        
        if showEmptyLabel {
            emptyLabel.alpha = 1.0
        } else {
            emptyLabel.alpha = 0.0
        }
    }
    
    @IBAction func userPressedEquationButton(_ sender: UIButton) {
        if menuVisible {
            closeMenu()
        } else {
            if emptyLabel.alpha == 0 {
                openMenu()
            }
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
    
    
    @IBAction func userPressedCancelButton(_ sender: Any) {
        closeMenu()
    }
    
    @IBAction func userPressedCopyButton(_ sender: UIButton) {
        // Copy everything
        
        let board = UIPasteboard.general
        board.string = Glossary.formattedStringForQuestion(question) + "=" + Glossary.formattedStringForAnswer(answer)
        
        closeMenu()
    }
    
    @IBAction func userPressedPasteButton(_ sender: UIButton) {
        // Get text and try and paste it in here.
        let board = UIPasteboard.general
        if var string = board.string {
            string = string.replacingOccurrences(of: " ", with: "")
            
            if string.contains("=") {
                let terms = string.components(separatedBy: "=")
                
                if terms.count > 0 {
                    string = terms.first!
                }
            }
            
            question = string
            
            self.update()
            self.calculate()
            
            closeMenu()
        }
    }
}
