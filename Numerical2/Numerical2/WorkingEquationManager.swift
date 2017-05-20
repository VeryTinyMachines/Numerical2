//
//  WorkingEquationManager.swift
//  Numerical2
//
//  Created by Andrew Clark on 17/05/2017.
//  Copyright © 2017 Very Tiny Machines. All rights reserved.
//

import UIKit


class WorkingEquationManager {
    
    let historyKey = "WorkingEquationManager.history"
    let currentIndexKey = "WorkingEquationManager.currentIndex"
    var saveTimer:Timer?
    
    static let sharedManager = WorkingEquationManager()
    fileprivate init() {
    
        self.currentIndex = UserDefaults.standard.integer(forKey: currentIndexKey)
        
        if let array = UserDefaults.standard.object(forKey: historyKey) as? [String] {
            self.history = array
        }
    }
    
    var history = [String]()
    var currentIndex = 0 // 0 means the most recent equation is the current one.
    
    func currentEquation() -> String {
        
        // If there is nothing in the history yet then add something.
        if history.count == 0 {
            history.append("")
        }
        
        return history[currentIndex]
    }
    
    func insertToHistory(question: String) {
        
        if currentIndex > 0 {
            // Remove everything up to this point
            for _ in 0...currentIndex {
                history.removeFirst()
            }
            
            currentIndex = 0
        }
        
        history.insert(question, at: 0)
        
        while history.count > 30 {
            history.removeLast()
        }
        
        queueSave()
    }
    
    func undo() -> Bool {
        
        if currentIndex < history.count - 1{
            currentIndex += 1
            queueSave()
            return true
        }
        
        return false
    }
    
    func redo() -> Bool {
        if currentIndex > 0 {
            currentIndex -= 1
            queueSave()
            return true
        }
        
        return false
    }
    
    func printHistory() {
        var count = 0
        for string in history {
            
            if count == currentIndex {
                print("\(count): \(string) <<<<")
            } else {
                print("\(count): \(string)")
            }
            
            count += 1
        }
    }
    
    func queueSave() {
        saveTimer?.invalidate()
        
        saveTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: false, block: { (timer) in
            self.save()
        })
    }
    
    func save() {
        UserDefaults.standard.set(currentIndex, forKey: currentIndexKey)
        UserDefaults.standard.set(history, forKey: historyKey)
        UserDefaults.standard.synchronize()
    }
}


