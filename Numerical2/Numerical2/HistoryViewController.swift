//
//  HistoryViewController.swift
//  Numerical2
//
//  Created by Andrew J Clark on 9/09/2015.
//  Copyright © 2015 Very Tiny Machines. All rights reserved.
//

import UIKit
import CoreData

class HistoryViewController: UITableViewController {
    
    var fetchedResultsController = NSFetchedResultsController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        fetchedResultsController = EquationStore.sharedStore.equationsFetchedResultsController()
        performFetch()
        
    }
    
    func reloadData() {
        performFetch()
        tableView.reloadData()
    }
    
    func updateContentInsets(insets: UIEdgeInsets) {
        tableView.contentInset = insets
    }
    
    func performFetch() {
        do {
            try fetchedResultsController.performFetch()
            
            print(fetchedResultsController.fetchedObjects)
            
        } catch {
            print("error")
        }
    }
    
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let fetched = fetchedResultsController.fetchedObjects {
            return fetched.count
        } else {
            return 0
        }
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath) as UITableViewCell
        
        if let equation = fetchedResultsController.objectAtIndexPath(indexPath) as? Equation {
            
            if let answer = equation.answer, question = equation.question, sortOrder = equation.sortOrder {
                cell.textLabel?.text = "\(question) - \(sortOrder.doubleValue)"
            }
        }
        
        return cell
    }
    
    
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        
        if editingStyle == UITableViewCellEditingStyle.Delete {
            if let equation = fetchedResultsController.objectAtIndexPath(indexPath) as? Equation {
                EquationStore.sharedStore.deleteEquation(equation)
                performFetch()
                tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Left)
            }
        }
    }
    
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    
    override func tableView(tableView: UITableView, moveRowAtIndexPath sourceIndexPath: NSIndexPath, toIndexPath destinationIndexPath: NSIndexPath) {
        
        if let sourceEquation = fetchedResultsController.objectAtIndexPath(sourceIndexPath) as? Equation, destinationEquation = fetchedResultsController.objectAtIndexPath(destinationIndexPath) as? Equation, destinationSortOrder = destinationEquation.sortOrder?.doubleValue {
            
            if sourceIndexPath.row < destinationIndexPath.row {
                // We are moving DOWN therefore we will be "below" the destination cell, needs to have a sort order between the destination cell and the cell following it
                
                
                let aboveDesinationIndex = NSIndexPath(forRow: destinationIndexPath.row - 1, inSection: destinationIndexPath.section)
                
                
                let belowDesinationIndex = NSIndexPath(forRow: destinationIndexPath.row + 1, inSection: destinationIndexPath.section)
                
                
                let newSortOrder = destinationSortOrder + 1
                
                sourceEquation.sortOrder = NSNumber(double: newSortOrder)
                
                
                if destinationIndexPath.row >= tableView.numberOfRowsInSection(destinationIndexPath.section) - 1 {
                    // We are at the bottom of the row
                    
                    sourceEquation.sortOrder = NSNumber(double: 0.0)
                    
                    if let aboveDestinationEquation = fetchedResultsController.objectAtIndexPath(aboveDesinationIndex) as? Equation {
                        
                        if let aboveDesinationSortOrder = aboveDestinationEquation.sortOrder?.doubleValue {
                            let sortOrder = aboveDesinationSortOrder / 2
                            
                            sourceEquation.sortOrder = NSNumber(double: sortOrder)
                        }
                    }
                    
                    
                } else {
                    if let belowDestinationEquation = fetchedResultsController.objectAtIndexPath(belowDesinationIndex) as? Equation {
                        
                        
                        if let belowDesinationSortOrder = belowDestinationEquation.sortOrder?.doubleValue {
                            let sortOrder = (destinationSortOrder + belowDesinationSortOrder) / 2
                            
                            sourceEquation.sortOrder = NSNumber(double: sortOrder)
                        }
                    }
                }
                
            } else if sourceIndexPath.row > destinationIndexPath.row {
                
                // We are moving UP, therefore we will be "above" the destination equation.
                
                let aboveDesinationIndex = NSIndexPath(forRow: destinationIndexPath.row - 1, inSection: destinationIndexPath.section)
                
                
                let belowDesinationIndex = NSIndexPath(forRow: destinationIndexPath.row + 1, inSection: destinationIndexPath.section)
                
                
                let newSortOrder = destinationSortOrder + 1
                
                sourceEquation.sortOrder = NSNumber(double: newSortOrder)
                
                if destinationIndexPath.row == 0 {
                    // We are at the top of the table
                    
                    if let belowDestinationEquation = fetchedResultsController.objectAtIndexPath(belowDesinationIndex) as? Equation {
                        
                        if let belowDesinationSortOrder = belowDestinationEquation.sortOrder?.doubleValue {
                            let sortOrder = belowDesinationSortOrder + 1
                            
                            sourceEquation.sortOrder = NSNumber(double: sortOrder)
                        }
                        
                    } else {
                        sourceEquation.sortOrder = NSNumber(int: tableView.numberOfRowsInSection(destinationIndexPath.section) + 1)
                    }
                    
                } else {
                    // We have moved a row upwards.
                    
                    if let aboveDestinationEquation = fetchedResultsController.objectAtIndexPath(aboveDesinationIndex) as? Equation {
                        
                        if let aboveDesinationSortOrder = aboveDestinationEquation.sortOrder?.doubleValue {
                            let sortOrder = (destinationSortOrder + aboveDesinationSortOrder) / 2
                            
                            sourceEquation.sortOrder = NSNumber(double: sortOrder)
                        }
                    }
                }
            }
        }
        
        EquationStore.sharedStore.save()
        
        performFetch()
        
        tableView.reloadData()
    }
}

