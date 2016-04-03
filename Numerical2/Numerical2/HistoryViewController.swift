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
    func selectedEquation(equation: Equation)
    func delectedEquation(equation: Equation)
}

class HistoryViewController: UIViewController, NSFetchedResultsControllerDelegate, UITableViewDelegate, UITableViewDataSource {
    
    var delegate:HistoryViewControllerDelegate?
    var fetchedResultsController = NSFetchedResultsController()
    var currentEquation:Equation?
    
    @IBOutlet weak var tableView: UITableView!
    
    func updateSelectedEquation(equation: Equation?) {
        
        // Unhighlight the old equation.
        
        if let theCurrentEquation = currentEquation, indexPath = fetchedResultsController.indexPathForObject(theCurrentEquation) {
            // Find index path of the current equation
            
            currentEquation = nil
            
            if let cell = tableView.cellForRowAtIndexPath(indexPath) {
                configureCell(cell, atIndexPath: indexPath)
            }
            
        }
        
        currentEquation = equation
        
        // Highlight and scroll to the new equation.
        
        if let theCurrentEquation = currentEquation, indexPath = fetchedResultsController.indexPathForObject(theCurrentEquation) {
            // Find the index path for this new equation
            
            if let cell = tableView.cellForRowAtIndexPath(indexPath) {
                configureCell(cell, atIndexPath: indexPath)
            }
        }
    }
    
    func focusOnCurrentEquation() {
        
        if let theCurrentEquation = currentEquation, indexPath = fetchedResultsController.indexPathForObject(theCurrentEquation) {
            // Find the index path for this new equation
            
            self.tableView.scrollToRowAtIndexPath(indexPath, atScrollPosition: UITableViewScrollPosition.Top, animated: true)
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
        
        self.view.backgroundColor = UIColor.clearColor()
        tableView!.backgroundColor = UIColor.clearColor()
        tableView!.backgroundView?.backgroundColor  = UIColor.clearColor()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    func updateContentInsets(insets: UIEdgeInsets) {
        
        print("before: \(tableView.contentInset)")
        
        tableView.contentInset = insets
        
        print("after: \(tableView.contentInset)")
    }
    
    func toggleEditing() {
        self.setEditing(!self.editing, animated: true)
    }
    
    func performFetch() {
        do {
            try fetchedResultsController.performFetch()
        } catch {
            print("error")
        }
    }
    
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath) as UITableViewCell
        
        self.configureCell(cell, atIndexPath: indexPath)
        
        return cell
    }
    
    
    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        
        if editingStyle == UITableViewCellEditingStyle.Delete {
            if let equation = fetchedResultsController.objectAtIndexPath(indexPath) as? Equation {
                if let theDelegate = delegate  {
                    theDelegate.delectedEquation(equation)
                }
                EquationStore.sharedStore.deleteEquation(equation)
            }
        }
    }
    
    
    func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        if let equation = fetchedResultsController.objectAtIndexPath(indexPath) as? Equation, theDelegate = delegate {
            theDelegate.selectedEquation(equation)
        }
    }
    
    func tableView(tableView: UITableView, moveRowAtIndexPath sourceIndexPath: NSIndexPath, toIndexPath destinationIndexPath: NSIndexPath) {
        
        if let sourceEquation = fetchedResultsController.objectAtIndexPath(sourceIndexPath) as? Equation, destinationEquation = fetchedResultsController.objectAtIndexPath(destinationIndexPath) as? Equation, destinationSortOrder = destinationEquation.sortOrder?.doubleValue {
            
            if sourceIndexPath.row < destinationIndexPath.row {
                // We are moving DOWN therefore we will be "below" the destination cell, needs to have a sort order between the destination cell and the cell following it
//                print("moved down", appendNewline: true)
                
                let belowDesinationIndex = NSIndexPath(forRow: destinationIndexPath.row + 1, inSection: destinationIndexPath.section)
                
                if destinationIndexPath.row >= tableView.numberOfRowsInSection(destinationIndexPath.section) - 1 {
                    // We are at the bottom of the row
//                    print("bottom of row", appendNewline: true)
                    
                    if let destinationEquation = fetchedResultsController.objectAtIndexPath(destinationIndexPath) as? Equation {
                        
                        if let destinationDesinationSortOrder = destinationEquation.sortOrder?.doubleValue {
                            
//                            print("destinationDesinationSortOrder: \(destinationDesinationSortOrder)", appendNewline: true)
                            
                            let sortOrder = destinationDesinationSortOrder + 1
                            
                            sourceEquation.sortOrder = NSNumber(double: sortOrder)
//                            print("set to equation above + 1", appendNewline: true)
                            
//                            print("sourceEquation: \(sourceEquation)", appendNewline: true)
                        }
                    }
                    
                    
                } else {
                    if let belowDestinationEquation = fetchedResultsController.objectAtIndexPath(belowDesinationIndex) as? Equation {
                        
                        if let belowDesinationSortOrder = belowDestinationEquation.sortOrder?.doubleValue {
                            
//                            print("belowDesinationSortOrder: \(belowDesinationSortOrder)", appendNewline: true)
                            
                            
                            let sortOrder = (destinationSortOrder + belowDesinationSortOrder) / 2
                            
                            sourceEquation.sortOrder = NSNumber(double: sortOrder)
                            
//                            print("sourceEquation: \(sourceEquation)", appendNewline: true)
                        }
                    }
                }
                
            } else if sourceIndexPath.row > destinationIndexPath.row {
//                print("moved up", appendNewline: true)
                // We are moving UP, therefore we will be "above" the destination equation.
                
                let aboveDesinationIndex = NSIndexPath(forRow: destinationIndexPath.row - 1, inSection: destinationIndexPath.section)
                
                let newSortOrder = destinationSortOrder + 1
                
                sourceEquation.sortOrder = NSNumber(double: newSortOrder)
                
                if destinationIndexPath.row == 0 {
                    // We are at the top of the table
                    
                    if let destinationEquation = fetchedResultsController.objectAtIndexPath(destinationIndexPath) as? Equation {
                        
                        if let desinationSortOrder = destinationEquation.sortOrder?.doubleValue {
//                            print("destinationEquation: \(destinationEquation)", appendNewline: true)
                            
                            let sortOrder = desinationSortOrder - 1
                            
                            sourceEquation.sortOrder = NSNumber(double: sortOrder)
//                            print("sourceEquation: \(sourceEquation)", appendNewline: true)
                        }
                        
                    }
                    
                } else {
                    // We have moved a row upwards.
                    
                    if let aboveDestinationEquation = fetchedResultsController.objectAtIndexPath(aboveDesinationIndex) as? Equation {
                        
                        if let aboveDesinationSortOrder = aboveDestinationEquation.sortOrder?.doubleValue {
                            
//                            print("destinationEquation: \(destinationEquation)", appendNewline: true)
                            
                            let sortOrder = (destinationSortOrder + aboveDesinationSortOrder) / 2
                            
                            sourceEquation.sortOrder = NSNumber(double: sortOrder)
                            
//                            print("sourceEquation: \(sourceEquation)", appendNewline: true)
                        }
                    }
                }
            }
        }
        
        EquationStore.sharedStore.save()
        
        performFetch()
        tableView.reloadData()
    }
    
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let info = self.fetchedResultsController.sections![section] as NSFetchedResultsSectionInfo
        return info.numberOfObjects
        
    }
    
    /* helper method to configure a `UITableViewCell`
    ask `NSFetchedResultsController` for the model */
    func configureCell(cell: UITableViewCell, atIndexPath indexPath: NSIndexPath) {
            
            if let equation = fetchedResultsController.objectAtIndexPath(indexPath) as? Equation {
                if let answer = equation.answer, question = equation.question, sortOrder = equation.sortOrder {
                    
                    let formattedQuestion = Glossary.formattedStringForQuestion(question)
                    let formattedAnswer = Glossary.formattedStringForQuestion(answer)
                    
                    cell.textLabel?.text = "\(formattedQuestion) = \(formattedAnswer)"
                } else {
                    cell.textLabel?.text = ""
                }
                
//                cell.backgroundColor = UIColor(red: 0.0/255.0, green: 11.0/255.0, blue: 24.0/255.0, alpha: 1.0)
                cell.backgroundColor = UIColor.clearColor()
                cell.textLabel?.textColor = UIColor(white: 0.6, alpha: 1.0)
                
                if equation == currentEquation {
                    cell.textLabel?.font = UIFont.boldSystemFontOfSize(15.0)
                    cell.textLabel?.textColor = UIColor(white: 1.0, alpha: 1.0)
                } else {
                    cell.textLabel?.font = UIFont.systemFontOfSize(15.0)
                    cell.textLabel?.textColor = UIColor(white: 1.0, alpha: 0.8)
                }
            }
            
    }
    
    // fetched results controller delegate
    
    func controllerWillChangeContent(controller: NSFetchedResultsController) {
        self.tableView.beginUpdates()
    }
    
    func controller(controller: NSFetchedResultsController, didChangeObject anObject: AnyObject, atIndexPath indexPath: NSIndexPath?, forChangeType type: NSFetchedResultsChangeType, newIndexPath: NSIndexPath?) {
        
        switch type {
        case .Insert:
            if let theNewIndexPath = newIndexPath {
                self.tableView.insertRowsAtIndexPaths([theNewIndexPath], withRowAnimation: UITableViewRowAnimation.Fade)
            }
        case .Update:
            if let theIndexPath = indexPath {
                if let cell = self.tableView.cellForRowAtIndexPath(theIndexPath) {
                    self.tableView.reloadRowsAtIndexPaths([theIndexPath], withRowAnimation: UITableViewRowAnimation.None)
                }
            }
        case .Move:
            if let theIndexPath = indexPath, theNewIndexPath = newIndexPath {
                self.tableView.deleteRowsAtIndexPaths([theIndexPath], withRowAnimation: UITableViewRowAnimation.None)
                self.tableView.insertRowsAtIndexPaths([theNewIndexPath], withRowAnimation: UITableViewRowAnimation.None)
            }
        case .Delete:
            if let theIndexPath = indexPath {
                self.tableView.deleteRowsAtIndexPaths([theIndexPath], withRowAnimation: UITableViewRowAnimation.Fade)
            }
        }
    }
    
    func controller(controller: NSFetchedResultsController, didChangeSection sectionInfo: NSFetchedResultsSectionInfo, atIndex sectionIndex: Int, forChangeType type: NSFetchedResultsChangeType) {
        switch(type) {
        case .Insert:
            tableView.insertSections(NSIndexSet(index: sectionIndex),
                withRowAnimation: UITableViewRowAnimation.Fade)
        case .Delete:
            tableView.deleteSections(NSIndexSet(index: sectionIndex),
                withRowAnimation: UITableViewRowAnimation.Fade)
        default:
            break
        }
    }
    
    func controllerDidChangeContent(controller: NSFetchedResultsController) {
        self.tableView.endUpdates()
    }

}

