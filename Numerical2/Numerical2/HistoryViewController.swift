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
    
//    var fetchedResultsController = NSFetchedResultsController()
    
    var currentEquation:Equation?
    
    @IBOutlet weak var tableView: UITableView!
    
    func updateSelectedEquation(_ equation: Equation?) {
        
        // Unhighlight the old equation.
        
        /*
        if let theCurrentEquation = currentEquation, let indexPath = fetchedResultsController.indexPath(forObject: theCurrentEquation) {
            // Find index path of the current equation
            
            currentEquation = nil
            
            if let cell = tableView.cellForRow(at: indexPath) {
                configureCell(cell, atIndexPath: indexPath)
            }
        }
        */
        
        currentEquation = equation
        reloadData()
        
        // Highlight and scroll to the new equation.
        
        if let currentEquation = currentEquation {
            if let position =  EquationStore.sharedStore.indexOfEquation(equation: currentEquation) {
                DispatchQueue.main.async {
                    let indexPath = IndexPath(row: position, section: 0)
                    self.tableView.scrollToRow(at: indexPath, at: UITableViewScrollPosition.bottom, animated: true)
                }
            }
        }
        
        /*
        if let theCurrentEquation = currentEquation, let indexPath = fetchedResultsController.indexPath(forObject: theCurrentEquation) {
            // Find the index path for this new equation
            
            if let cell = tableView.cellForRow(at: indexPath) {
                configureCell(cell, atIndexPath: indexPath)
            }
        }
 */
    }
    
    func reloadData() {
        DispatchQueue.main.async {
            self.tableView.reloadData()
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
        
//        fetchedResultsController = EquationStore.sharedStore.equationsFetchedResultsController()
//        fetchedResultsController.delegate = self
        
        performFetch()
        
        tableView!.delegate = self
        tableView!.dataSource = self
        
        tableView!.separatorColor = UIColor(white: 1.0, alpha: 0.4)
        
        self.view.backgroundColor = UIColor.clear
        tableView!.backgroundColor = UIColor.clear
        tableView!.backgroundView?.backgroundColor  = UIColor.clear
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    func updateContentInsets(_ insets: UIEdgeInsets) {
        
        print("before: \(tableView.contentInset)")
        
        tableView.contentInset = insets
        
        print("after: \(tableView.contentInset)")
    }
    
    func toggleEditing() {
        self.setEditing(!self.isEditing, animated: true)
    }
    
    func performFetch() {
        /*
        do {
            try fetchedResultsController.performFetch()
        } catch {
            print("error")
        }
         */
    }
    
    func equation(indexPath:IndexPath) -> Equation {
        return EquationStore.sharedStore.equations[indexPath.row]
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        
        self.configureCell(cell, atIndexPath: indexPath)
        
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        
        if editingStyle == UITableViewCellEditingStyle.delete {
            let equation = self.equation(indexPath: indexPath)
            
            delegate?.delectedEquation(equation)
            
            let indexesToDelete = EquationStore.sharedStore.deleteEquation(equation: equation)
            
            if indexesToDelete.count > 0 {
                
                var indexPaths = [IndexPath]()
                
                for index in indexesToDelete {
                    indexPaths.append(IndexPath(row: index, section: 0))
                }
                
                self.tableView.deleteRows(at: indexPaths, with: UITableViewRowAnimation.automatic)
            }
        }
    }
    
    
    func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let equation = self.equation(indexPath: indexPath)
        delegate?.selectedEquation(equation)
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
         
         EquationStore.sharedStore.save()
 */
        
        performFetch()
        tableView.reloadData()
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        /*
        let info = self.fetchedResultsController.sections![section] as NSFetchedResultsSectionInfo
        return info.numberOfObjects
        */
        return EquationStore.sharedStore.equations.count
    }
    
    /* helper method to configure a `UITableViewCell`
    ask `NSFetchedResultsController` for the model */
    func configureCell(_ cell: UITableViewCell, atIndexPath indexPath: IndexPath) {
        let equation = self.equation(indexPath: indexPath)
        
        var isCurrent = false
        
        if equation.identifier == currentEquation?.identifier {
            isCurrent = true
        }
        
        if let cell = cell as? HistoryCell {
            cell.layout(equation: equation, currentEquation: isCurrent)
        }
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
                if let _ = self.tableView.cellForRow(at: theIndexPath) {
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

