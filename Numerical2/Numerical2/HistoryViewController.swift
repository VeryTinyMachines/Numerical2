//
//  HistoryViewController.swift
//  Numerical2
//
//  Created by Andrew J Clark on 9/09/2015.
//  Copyright © 2015 Very Tiny Machines. All rights reserved.
//

import UIKit
import CoreData


protocol HistoryViewControllerDelegate {
    func selectedEquation(_ equation: Equation)
    func delectedEquation(_ equation: Equation)
}

class HistoryViewController: UIViewController, NSFetchedResultsControllerDelegate, UITableViewDelegate, UITableViewDataSource {
    
    var delegate:HistoryViewControllerDelegate?
    var fetchedResultsController = NSFetchedResultsController<Equation>()
    var currentEquation:Equation?
    
    
    @IBOutlet weak var tableView: UITableView!
    
    func updateSelectedEquation(_ equation: Equation?) {
        
        // Unhighlight the old equation.
        
        if let theCurrentEquation = currentEquation, let indexPath = fetchedResultsController.indexPath(forObject: theCurrentEquation) {
            // Find index path of the current equation
            
            currentEquation = nil
            
            if let cell = tableView.cellForRow(at: indexPath) {
                configureCell(cell, atIndexPath: indexPath)
            }
            
        }
        
        currentEquation = equation
        
        // Highlight and scroll to the new equation.
        
        if let theCurrentEquation = currentEquation, let indexPath = fetchedResultsController.indexPath(forObject: theCurrentEquation) {
            // Find the index path for this new equation
            
            if let cell = tableView.cellForRow(at: indexPath) {
                configureCell(cell, atIndexPath: indexPath)
            }
        }
    }
    
    func focusOnCurrentEquation() {
        
        if let theCurrentEquation = currentEquation, let indexPath = fetchedResultsController.indexPath(forObject: theCurrentEquation) {
            // Find the index path for this new equation
            
            self.tableView.scrollToRow(at: indexPath, at: UITableViewScrollPosition.top, animated: true)
        }
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
        
        NotificationCenter.default.addObserver(self, selector: #selector(HistoryViewController.iCloudSyncChanged), name: Notification.Name(rawValue: NumericalHelperSetting.iCloudHistorySync), object: nil)
        
        themeChanged()
    }
    
    func iCloudSyncChanged() {
        self.tableView.reloadData()
    }

    func themeChanged() {
        self.tableView.separatorColor = ThemeCoordinator.shared.foregroundColorForCurrentTheme().withAlphaComponent(0.25)
        self.tableView.reloadData()
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    func updateContentInsets(_ insets: UIEdgeInsets) {
        
        var indexPath:IndexPath?
        
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
        
        UIView.animate(withDuration: 0.2, animations: {
            self.tableView.contentInset = insets
            
            if let indexPath = indexPath {
                self.tableView.scrollToRow(at: indexPath, at: UITableViewScrollPosition.bottom, animated: true)
            }
            
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
        return 1
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as UITableViewCell
        
        self.configureCell(cell, atIndexPath: indexPath)
        
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        
        if editingStyle == UITableViewCellEditingStyle.delete {
            if let equation = fetchedResultsController.object(at: indexPath) as? Equation {
                if let theDelegate = delegate  {
                    theDelegate.delectedEquation(equation)
                }
                EquationStore.sharedStore.deleteEquation(equation: equation)
            }
        }
    }
    
    
    func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        if let equation = fetchedResultsController.object(at: indexPath) as? Equation, let theDelegate = delegate {
            theDelegate.selectedEquation(equation)
        }
    }
    
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        
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
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let info = self.fetchedResultsController.sections![section] as NSFetchedResultsSectionInfo
        return info.numberOfObjects
        
    }
    
    /* helper method to configure a `UITableViewCell`
    ask `NSFetchedResultsController` for the model */
    func configureCell(_ cell: UITableViewCell, atIndexPath indexPath: IndexPath) {
            
        let equation = fetchedResultsController.object(at: indexPath)
        
        var answer = "No answer"
        var question = "No question"
        
        if let theAnswer = equation.answer {
            answer = Glossary.formattedStringForQuestion(theAnswer)
        }
        
        if let theQuestion = equation.question {
            question = Glossary.formattedStringForQuestion(theQuestion)
        }
        
        cell.backgroundColor = UIColor.clear
        
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
        cell.detailTextLabel?.text = ""
        
        if let posted = equation.posted?.boolValue {
            if posted == false && NumericalHelper.isSettingEnabled(string: NumericalHelperSetting.iCloudHistorySync) {
                cell.detailTextLabel?.text = "..."
            }
        }
        
        cell.detailTextLabel?.font = UIFont.systemFont(ofSize: 15.0)
        cell.detailTextLabel?.textColor = UIColor(white: 1.0, alpha: 0.8)
    }
    
    // fetched results controller delegate
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        self.tableView.beginUpdates()
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        
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
    }

}

