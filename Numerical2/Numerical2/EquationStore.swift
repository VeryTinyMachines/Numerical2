//
//  EquationStore.swift
//  Numerical2
//
//  Created by Andrew J Clark on 23/09/2016.
//  Copyright © 2016 Very Tiny Machines. All rights reserved.
//

import Foundation

class EquationStore {
    
    var equations = [Equation]()
    var equationLookup = [String:Equation]()
    
    var saveTimer:Timer?
    
    static let sharedStore = EquationStore()
    
    fileprivate init() {
        
        let newEquation = Equation()
        newEquation.answer = "4"
        newEquation.question = "2+2"
        newEquation.identifier = UUID().uuidString
        
        equations.append(newEquation)
        
        let newEquation2 = Equation()
        newEquation2.answer = "10"
        newEquation2.question = "2*5"
        newEquation2.identifier = UUID().uuidString
        
        load()
    }
    
    func save() {
        //SuperTextLogger.sharedLogger.log("")
        
        saveTimer?.invalidate()
        
        saveTimer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(EquationStore.fireSaveTimer), userInfo: nil, repeats: false)
        
    }
    
    @objc func fireSaveTimer() {
        let serialQueue = DispatchQueue(label: "com.verytinymachines.Numerical.CloudKitManagerSaveQueue")
        
        serialQueue.async {
            if NSKeyedArchiver.archiveRootObject(self.equations, toFile: self.cacheLocation(location: "Equations")) == false {
                print("Could not archive")
            }
        }
    }
    
    
    func load() {
        if let loadedEquations = NSKeyedUnarchiver.unarchiveObject(withFile: self.cacheLocation(location: "Equations")) as? [Equation] {
            self.equations = loadedEquations
        }
    }
    
    func cacheLocation(location: String) -> String {
        return applicationSupport() + location
    }
    
    func applicationSupport() -> String {
        
        let paths = NSSearchPathForDirectoriesInDomains(.applicationSupportDirectory, .userDomainMask, true)
        let applicationSupportPath = paths[0]
        
        if FileManager.default.fileExists(atPath: applicationSupportPath) == false {
            do {
                try FileManager.default.createDirectory(atPath: applicationSupportPath, withIntermediateDirectories: true, attributes: nil)
            } catch {
                print("Error - Could not creation Application Support Directory")
            }
        }
        
        return applicationSupportPath
    }
    
    
    func deleteEquation(equation: Equation) -> [Int] {
        
        var indexesToDelete = [Int]()
        
        var count = 0
        equations = equations.filter({ (theEquation) -> Bool in
            
            var keep = false
            
            if theEquation.identifier != equation.identifier {
                keep = true
            } else {
                indexesToDelete.append(count)
            }
            
            count += 1
            
            return keep
        })
        
        return indexesToDelete
    }
    
    
    func indexOfEquation(equation: Equation) -> Int? {
        
        if equations.contains(equation) {
            return equations.index(of: equation)
        }
        
        var count = 0
        for theEquation in equations {
            if theEquation.identifier == equation.identifier {
                return count
            }
            
            count += 1
        }
        
        return nil
    }
    
    
    func newEquation() -> Equation {
        let equation = Equation()
        equations.append(equation)
        return equation
    }
}
