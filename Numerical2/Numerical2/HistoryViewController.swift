//
//  HistoryViewController.swift
//  Numerical2
//
//  Created by Andrew J Clark on 9/09/2015.
//  Copyright © 2015 Very Tiny Machines. All rights reserved.
//

import UIKit
import CoreData
import CloudKit

protocol HistoryViewControllerDelegate {
    func selectedEquation(_ equation: Equation)
    func delectedEquation(_ equation: Equation)
}

class HistoryViewController: NumericalViewController, NSFetchedResultsControllerDelegate, UITableViewDelegate, UITableViewDataSource {
    
    let kSectionGap = -100
    let kSectionEquations = 0
    let kSectionMigrate = 1
    let kSectionsCount = 2
    
    var delegate:HistoryViewControllerDelegate?
    var fetchedResultsController = NSFetchedResultsController<Equation>()
    var currentEquation:Equation?
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var deleteButton: UIButton!
    
    @IBOutlet weak var deleteAllButton: UIButton!
    
    @IBOutlet weak var editView: UIView!
    
    @IBOutlet weak var tableViewTopConstraint: NSLayoutConstraint!
    
    func currentEquationChangedNotif(_ notification: Notification) {
        self.updateSelectedEquation()
    }
    
    func updateSelectedEquation() {
        if let rootView = UIApplication.shared.keyWindow?.rootViewController as? ViewController {
            self.updateSelectedEquation(rootView.currentEquation)
        }
    }
    
    func updateSelectedEquation(_ equation: Equation?) {
        
        // Unhighlight the old equation.
        
        if let theCurrentEquation = currentEquation, var indexPath = fetchedResultsController.indexPath(forObject: theCurrentEquation) {
            // Find index path of the current equation
            
            indexPath.section = kSectionEquations
            
            currentEquation = nil
            
            if let cell = tableView.cellForRow(at: indexPath) {
                configureCell(cell as! HistoryCell, atIndexPath: indexPath)
            }
        }
 
        currentEquation = equation
        
        // Highlight and scroll to the new equation.
        
        if let theCurrentEquation = currentEquation, var indexPath = fetchedResultsController.indexPath(forObject: theCurrentEquation) {
            // Find the index path for this new equation
            
            indexPath.section = kSectionEquations
            
            if let cell = tableView.cellForRow(at: indexPath) {
                configureCell(cell as! HistoryCell, atIndexPath: indexPath)
            }
        }
    }
    
    func focusOnCurrentEquation() {
        /*
        if let theCurrentEquation = currentEquation, let indexPath = fetchedResultsController.indexPath(forObject: theCurrentEquation) {
            // Find the index path for this new equation
            
            self.tableView.scrollToRow(at: indexPath, at: UITableViewScrollPosition.top, animated: true)
        }
 */
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        fetchedResultsController = EquationStore.sharedStore.equationsFetchedResultsController()
        fetchedResultsController.delegate = self
        performFetch()
        
        tableView!.delegate = self
        tableView!.dataSource = self
        
        tableView!.separatorColor = UIColor(white: 1.0, alpha: 0.4)
        
        self.view.backgroundColor = UIColor.clear
        tableView!.backgroundColor = UIColor.clear
        tableView!.backgroundView?.backgroundColor  = UIColor.clear
        
        NotificationCenter.default.addObserver(self, selector: #selector(HistoryViewController.themeChanged), name: Notification.Name(rawValue: PremiumCoordinatorNotification.themeChanged), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(HistoryViewController.reloadData), name: Notification.Name(rawValue: NumericalHelperSetting.iCloudHistorySync), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(HistoryViewController.reloadData), name: Notification.Name(rawValue: NumericalHelperSetting.migration), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(HistoryViewController.currentEquationChangedNotif(_:)), name: Notification.Name(rawValue: EquationStoreNotification.currentEquationChanged), object: nil)
        
        themeChanged()
        updateButtons()
    }
    
    func reloadData() {
        DispatchQueue.main.async {
            self.tableView.reloadData()
            self.updateButtons()
        }
    }
    
    
    func themeChanged() {
        self.tableView.separatorColor = ThemeCoordinator.shared.foregroundColorForCurrentTheme().withAlphaComponent(0.25)
        
        self.deleteButton.setTitleColor(ThemeCoordinator.shared.foregroundColorForCurrentTheme(), for: UIControlState.normal)
        
        self.deleteAllButton.setTitleColor(ThemeCoordinator.shared.foregroundColorForCurrentTheme(), for: UIControlState.normal)
        
        updateButtons()
        
        self.tableView.reloadData()
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        updateButtons()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    func updateContentInsets(_ insets: UIEdgeInsets) {
        
        //var indexPath:IndexPath?
        
        /*
         // do not scroll to current equation, kind of annoying
        if let objects = self.fetchedResultsController.fetchedObjects {
            if let currentEquation = currentEquation {
                
                if let position = objects.index(of: currentEquation) {
                    
                    indexPath = IndexPath(item: position, section: 0)
                }
                
            } else {
                if objects.count > 0 {
                    indexPath = IndexPath(item: objects.count - 1, section: 0)
                }
            }
        }
        */
        
        UIView.animate(withDuration: 0.2, animations: {
            self.tableView.contentInset = insets
            self.tableView.scrollIndicatorInsets = insets
            /*
             // do not scroll to current equation, kind of annoying
            if let indexPath = indexPath {
                self.tableView.scrollToRow(at: indexPath, at: UITableViewScrollPosition.bottom, animated: true)
            }
             */
            
        }) { (complete) in
            
        }
 
    }
    
    func toggleEditing() {
        self.setEditing(!self.isEditing, animated: true)
    }
    
    func performFetch() {
        do {
            try fetchedResultsController.performFetch()
        } catch {
            print("error")
        }
    }
    
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return kSectionsCount
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! HistoryCell
        
        if indexPath.section == kSectionEquations {
            self.configureCell(cell, atIndexPath: indexPath)
        } else if indexPath.section == kSectionGap {
            
            cell.backgroundColor = UIColor.clear
            cell.selectionStyle = UITableViewCellSelectionStyle.none
            cell.mainLabel.text = nil
            cell.selectable = false
            
        } else if indexPath.section == kSectionMigrate {
            let answer = "Convert Numerical v1 History"
            
            cell.backgroundColor = UIColor.clear
            cell.selectionStyle = UITableViewCellSelectionStyle.none
            cell.selectable = false
            
            var color = ThemeCoordinator.shared.foregroundColorForCurrentTheme().withAlphaComponent(1.0)
            
            let questionFont = UIFont.systemFont(ofSize: 15.0)
            let answerFont = UIFont.systemFont(ofSize: 20.0)
            
            let attributedString = NSMutableAttributedString(string: answer, attributes: [NSFontAttributeName:questionFont, NSForegroundColorAttributeName:color])
            
            cell.mainLabel.numberOfLines = 0
            //cell.textLabel?.attributedText = attributedString
            cell.mainLabel.text = attributedString.string
            cell.mainLabel.font = questionFont
        }
        
        return cell
    }
    
    func equation(row: Int) -> Equation? {
        
        if let equation = fetchedResultsController.object(at: IndexPath(row: row, section: 0)) as? Equation {
            
            return equation
        }
        
        return nil
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return indexPath.section == kSectionEquations
    }
    
    func tableView(_ tableView: UITableView, willBeginEditingRowAt indexPath: IndexPath) {
        // Hide the buttons
        deleteButton.isHidden = true
        deleteAllButton.isHidden = true
    }
    
    func tableView(_ tableView: UITableView, didEndEditingRowAt indexPath: IndexPath?) {
        DispatchQueue.main.async {
            self.updateButtons()
        }
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        
        if editingStyle == UITableViewCellEditingStyle.delete {
            if let equation = equation(row: indexPath.row) {
                if let theDelegate = delegate  {
                    theDelegate.delectedEquation(equation)
                }
                EquationStore.sharedStore.deleteEquation(equation: equation)
            }
        }
    }
    
    
    func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        return false
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        // Check if we are in a the page view and it is scrolling - abort if we are.
        if let parent = parent as? SwipePageViewController {
            if let parent = parent.parent as? KeypadPageViewController {
                if parent.isPageScrolling() {
                    return
                }
            }
        }
        
        if indexPath.section == kSectionEquations {
            if let equation = equation(row: indexPath.row), let theDelegate = delegate {
                theDelegate.selectedEquation(equation)
            }
            
            self.tableView.reloadRows(at: [indexPath], with: UITableViewRowAnimation.fade)
        } else if indexPath.section == kSectionMigrate {
            // Migrate
            self.convertHistory(block: { (complete) in
                // Reloading is done via migration notification
            })
        }
    }
    
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        
        /*
        if let sourceEquation = fetchedResultsController.object(at: sourceIndexPath) as? Equation, let destinationEquation = fetchedResultsController.object(at: destinationIndexPath) as? Equation, let destinationSortOrder = destinationEquation.sortOrder?.doubleValue {
            
            if (sourceIndexPath as NSIndexPath).row < (destinationIndexPath as NSIndexPath).row {
                // We are moving DOWN therefore we will be "below" the destination cell, needs to have a sort order between the destination cell and the cell following it
//                print("moved down", appendNewline: true)
                
                let belowDesinationIndex = IndexPath(row: (destinationIndexPath as NSIndexPath).row + 1, section: (destinationIndexPath as NSIndexPath).section)
                
                if (destinationIndexPath as NSIndexPath).row >= tableView.numberOfRows(inSection: (destinationIndexPath as NSIndexPath).section) - 1 {
                    // We are at the bottom of the row
//                    print("bottom of row", appendNewline: true)
                    
                    if let destinationEquation = fetchedResultsController.object(at: destinationIndexPath) as? Equation {
                        
                        if let destinationDesinationSortOrder = destinationEquation.sortOrder?.doubleValue {
                            
//                            print("destinationDesinationSortOrder: \(destinationDesinationSortOrder)", appendNewline: true)
                            
                            let sortOrder = destinationDesinationSortOrder + 1
                            
                            sourceEquation.sortOrder = NSNumber(value: sortOrder as Double)
//                            print("set to equation above + 1", appendNewline: true)
                            
//                            print("sourceEquation: \(sourceEquation)", appendNewline: true)
                        }
                    }
                    
                    
                } else {
                    if let belowDestinationEquation = fetchedResultsController.object(at: belowDesinationIndex) as? Equation {
                        
                        if let belowDesinationSortOrder = belowDestinationEquation.sortOrder?.doubleValue {
                            
//                            print("belowDesinationSortOrder: \(belowDesinationSortOrder)", appendNewline: true)
                            
                            
                            let sortOrder = (destinationSortOrder + belowDesinationSortOrder) / 2
                            
                            sourceEquation.sortOrder = NSNumber(value: sortOrder as Double)
                            
//                            print("sourceEquation: \(sourceEquation)", appendNewline: true)
                        }
                    }
                }
                
            } else if (sourceIndexPath as NSIndexPath).row > (destinationIndexPath as NSIndexPath).row {
//                print("moved up", appendNewline: true)
                // We are moving UP, therefore we will be "above" the destination equation.
                
                let aboveDesinationIndex = IndexPath(row: (destinationIndexPath as NSIndexPath).row - 1, section: (destinationIndexPath as NSIndexPath).section)
                
                let newSortOrder = destinationSortOrder + 1
                
                sourceEquation.sortOrder = NSNumber(value: newSortOrder as Double)
                
                if (destinationIndexPath as NSIndexPath).row == 0 {
                    // We are at the top of the table
                    
                    if let destinationEquation = fetchedResultsController.object(at: destinationIndexPath) as? Equation {
                        
                        if let desinationSortOrder = destinationEquation.sortOrder?.doubleValue {
//                            print("destinationEquation: \(destinationEquation)", appendNewline: true)
                            
                            let sortOrder = desinationSortOrder - 1
                            
                            sourceEquation.sortOrder = NSNumber(value: sortOrder as Double)
//                            print("sourceEquation: \(sourceEquation)", appendNewline: true)
                        }
                        
                    }
                    
                } else {
                    // We have moved a row upwards.
                    
                    if let aboveDestinationEquation = fetchedResultsController.object(at: aboveDesinationIndex) as? Equation {
                        
                        if let aboveDesinationSortOrder = aboveDestinationEquation.sortOrder?.doubleValue {
                            
//                            print("destinationEquation: \(destinationEquation)", appendNewline: true)
                            
                            let sortOrder = (destinationSortOrder + aboveDesinationSortOrder) / 2
                            
                            sourceEquation.sortOrder = NSNumber(value: sortOrder as Double)
                            
//                            print("sourceEquation: \(sourceEquation)", appendNewline: true)
                        }
                    }
                }
            }
        }
        
        EquationStore.sharedStore.queueSave()
        
        performFetch()
        tableView.reloadData()
         */
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == kSectionEquations {
            return numberOfFetchedEquations()
        } else if section == kSectionEquations {
            if EquationStore.sharedStore.canConvertDeprecatedEquations() {
                return 1
            }
        } else if section == kSectionGap {
            return 1
        }
        
        return 0
    }
    
    func numberOfFetchedEquations() -> Int {
        let info = self.fetchedResultsController.sections![0] as NSFetchedResultsSectionInfo
        return info.numberOfObjects
    }
    
    
    /* helper method to configure a `UITableViewCell`
    ask `NSFetchedResultsController` for the model */
    func configureCell(_ cell: HistoryCell, atIndexPath indexPath: IndexPath) {
        
        
        var indexPath = indexPath
        indexPath.section = 0
        
        if let equation = equation(row: indexPath.row) {
            cell.backgroundColor = UIColor.clear
            cell.selectionStyle = UITableViewCellSelectionStyle.none
            cell.selectable = true
            cell.mainLabel.attributedText = attributedString(equation: equation)
        }
        
        
        
        
        /*
        var answer = "No answer"
        var question = "No question"
        
        if let theAnswer = equation.answer {
            answer = Glossary.formattedStringForAnswer(theAnswer)
        }
        
        if let theQuestion = equation.question {
            question = Glossary.formattedStringForQuestion(theQuestion)
        }
        
        
        
        var color = ThemeCoordinator.shared.foregroundColorForCurrentTheme().withAlphaComponent(0.8)
        
        var questionFont = UIFont.systemFont(ofSize: 15.0)
        var answerFont = UIFont.systemFont(ofSize: 20.0)
        
        if equation == currentEquation {
            color = ThemeCoordinator.shared.foregroundColorForCurrentTheme().withAlphaComponent(1.0)
            questionFont = UIFont.boldSystemFont(ofSize: 15.0)
            answerFont = UIFont.boldSystemFont(ofSize: 20.0)
        }
        
        let attributedString = NSMutableAttributedString(string: answer, attributes: [NSFontAttributeName:answerFont, NSForegroundColorAttributeName:color])
        
        attributedString.append(NSMutableAttributedString(string: " = \(question)", attributes: [NSFontAttributeName:questionFont, NSForegroundColorAttributeName:color]))
        
        cell.textLabel?.attributedText = attributedString
        cell.detailTextLabel?.text = nil
        */
        
        /*
        if let posted = equation.posted?.boolValue {
            if posted == false && NumericalHelper.isSettingEnabled(string: NumericalHelperSetting.iCloudHistorySync) && EquationStore.sharedStore.accountStatus != CKAccountStatus.available {
                cell.detailTextLabel?.text = "⚠"
            }
        }
        */
        
//        cell.detailTextLabel?.font = UIFont.systemFont(ofSize: 15.0)
//        cell.detailTextLabel?.textColor = UIColor(white: 1.0, alpha: 0.8)
    }
    
    // fetched results controller delegate
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        self.tableView.beginUpdates()
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        
        var indexPath = indexPath
        indexPath?.section = kSectionEquations
        
        var newIndexPath = newIndexPath
        newIndexPath?.section = kSectionEquations
        
        switch type {
        case .insert:
            if let theNewIndexPath = newIndexPath {
                self.tableView.insertRows(at: [theNewIndexPath], with: UITableViewRowAnimation.fade)
            }
        case .update:
            if let theIndexPath = indexPath {
                if let cell = self.tableView.cellForRow(at: theIndexPath) {
                    self.tableView.reloadRows(at: [theIndexPath], with: UITableViewRowAnimation.none)
                }
            }
        case .move:
            if let theIndexPath = indexPath, let theNewIndexPath = newIndexPath {
                self.tableView.deleteRows(at: [theIndexPath], with: UITableViewRowAnimation.none)
                self.tableView.insertRows(at: [theNewIndexPath], with: UITableViewRowAnimation.none)
            }
        case .delete:
            if let theIndexPath = indexPath {
                self.tableView.deleteRows(at: [theIndexPath], with: UITableViewRowAnimation.fade)
            }
        }
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
        
        var sectionIndex = kSectionEquations
        sectionIndex = kSectionEquations
        
        switch(type) {
        case .insert:
            tableView.insertSections(IndexSet(integer: sectionIndex),
                with: UITableViewRowAnimation.fade)
        case .delete:
            tableView.deleteSections(IndexSet(integer: sectionIndex),
                with: UITableViewRowAnimation.fade)
        default:
            break
        }
    }
    
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        self.tableView.endUpdates()
        self.updateButtons()
    }

    
    @IBAction func userPressedDeleteButton(_ sender: UIButton) {
        if tableView.isEditing {
            // Stop editing
            tableView.setEditing(false, animated: true)
            updateButtons()
        } else {
            // Start editing, update buttons
            tableView.setEditing(true, animated: true)
            updateButtons()
        }
    }
    
    @IBAction func userPressedDeleteAllButton(_ sender: UIButton) {
        deleteHistory()
    }
    
    func updateButtons() {
        
        if numberOfFetchedEquations() > 0 {
            if tableView.isEditing {
                // Cancel
                deleteButton.setTitle("Done", for: UIControlState.normal)
                deleteAllButton.setTitle("Delete All", for: UIControlState.normal)
                
                deleteButton.isHidden = false
                deleteAllButton.isHidden = false
                tableViewTopConstraint.constant = deleteButton.frame.height
                //tableViewTopConstraint.constant = 0
                //editView.alpha = 0.33
                editView.alpha = 0.0
            } else {
                // Edit
                deleteButton.setTitle("Edit", for: UIControlState.normal)
                
                deleteButton.isHidden = false
                deleteAllButton.isHidden = true
                tableViewTopConstraint.constant = 0
                editView.alpha = 0.0
            }
        } else {
            deleteButton.isHidden = true
            deleteAllButton.isHidden = true
            tableViewTopConstraint.constant = 0
            editView.alpha = 0.0
        }
        
//        if NumericalViewHelper.keypadIsDraggable() {
//            editView.backgroundColor = ThemeCoordinator.shared.firstColorForCurrentTheme()
//        } else {
//            editView.backgroundColor = ThemeCoordinator.shared.firstColorForCurrentTheme().lighterColor
//        }
        
        self.view.layoutIfNeeded()
    }
    
    func deleteHistory() {
        let alertView = UIAlertController(title: "Delete History", message: "Are you sure you want to delete your entire history? This deletion will be synced to your other devices if you have iCloud sync enabled.", preferredStyle: UIAlertControllerStyle.alert)
        
        alertView.addAction(UIAlertAction(title: "Yes", style: UIAlertActionStyle.destructive, handler: { (action) in
            
            EquationStore.sharedStore.deleteHistory(block: { (complete) in
                if complete {
                    
                } else {
                    self.displayAlert(title: "Error", message: "Uh oh. Something went wrong deleting your history.")
                }
                
                self.tableView.setEditing(false, animated: true)
                self.updateButtons()
            })
        }))
        
        alertView.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: { (action) in
            
        }))
        
        self.present(alertView, animated: true) { 
            
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == kSectionEquations {
            if let equation = equation(row: indexPath.row) {
                
                let attrString = attributedString(equation: equation)
                
                let width = tableView.frame.width - 12 - 12
                
                let boundingRect = attrString.boundingRect(with: CGSize(width: width, height: 2000), options: NSStringDrawingOptions.usesLineFragmentOrigin, context: nil)
                
                return boundingRect.height + 12 + 12
            }
            
        } else if indexPath.section == kSectionGap {
            return deleteButton.frame.height
        }
        
        return 44
    }
    
    func attributedString(equation: Equation) -> NSAttributedString {
        
        var answer = "No answer"
        var question = "No question"
        
        if let theAnswer = equation.answer {
            answer = Glossary.formattedStringForAnswer(theAnswer)
        }
        
        if let theQuestion = equation.question {
            question = Glossary.formattedStringForQuestion(theQuestion)
        }
        
        var color = ThemeCoordinator.shared.foregroundColorForCurrentTheme().withAlphaComponent(0.7)
        var questionFont = UIFont.systemFont(ofSize: 15.0)
        var answerFont = UIFont.systemFont(ofSize: 20.0)
        
        if equation == currentEquation {
            color = ThemeCoordinator.shared.foregroundColorForCurrentTheme().withAlphaComponent(1.0)
            //questionFont = UIFont.boldSystemFont(ofSize: 15.0)
            //answerFont = UIFont.boldSystemFont(ofSize: 20.0)
        }
        
        questionFont = answerFont
        
        let attributedString = NSMutableAttributedString(string: question, attributes: [NSFontAttributeName:answerFont, NSForegroundColorAttributeName:color])
        
        attributedString.append(NSMutableAttributedString(string: " = \(answer)", attributes: [NSFontAttributeName:questionFont, NSForegroundColorAttributeName:color]))
        
        return attributedString
    }
}

