//
//  EquationStore.swift
//  Numerical2
//
//  Created by Andrew J Clark on 23/09/2016.
//  Copyright © 2016 Very Tiny Machines. All rights reserved.
//

import Foundation
import CoreData
import CloudKit

public struct EquationNotification {
    public static let updated = "EquationNotification.updated"
}

public struct EquationCodingKey {
    public static let answer = "answer"
    public static let creationDate = "creationDate"
    public static let deviceIdentifier = "deviceIdentifier"
    public static let identifier = "identifier"
    public static let lastModifiedDate = "lastModifiedDate"
    public static let question = "question"
    
    public static let currentEquation = "currentEquation"
}


public struct EquationStoreNotification {
    public static let equationDeleted = "EquationStoreNotification.equationDeleted"
}


class EquationStore {
    
    var saveTimer:Timer?
    var updateCloudKitTimer:Timer?
    
    var queuedEquationsToSave = [String: Equation]()
    
    lazy var lastFetchDate:NSDate? = {
        if let date = UserDefaults.standard.object(forKey: "lastFetchDate") as? NSDate {
            return date
        }
        
        return nil
    }()
    
    func setLastFetchDate(date: NSDate) {
        UserDefaults.standard.set(date, forKey: "lastFetchDate")
        UserDefaults.standard.synchronize()
    }
    
    static let sharedStore = EquationStore()
    
    fileprivate init() {

    }
    
    func initialiseiCloud() {
        cloudFetchLatestEquations()
        updateCloudKit()
    }
    
    func queueCloudKitNeedsUpdate() {
        updateCloudKitTimer?.invalidate()
        updateCloudKitTimer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(EquationStore.fireUpdateCloudKitTimer), userInfo: nil, repeats: false)
    }
    
    func queueSave() {
            fireSaveTimer() // Delaying saving causing some issues where cells in the history view do not update properly and fetching equations causes some issues.
        self.queueCloudKitNeedsUpdate()
        
        
//        saveTimer?.invalidate()
//        saveTimer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(EquationStore.fireSaveTimer), userInfo: nil, repeats: false)
    }
    
    @objc func fireSaveTimer() {
        self.saveContext()
    }
    
    @objc func fireUpdateCloudKitTimer() {
        self.updateCloudKit()
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
    
    
    func equationUpdated(equation: Equation) {
        print("equationUpdated: \(equationUpdated)")
        
        equation.posted = NSNumber(value: false)
        equation.lastModifiedDate = NSDate()
        
        self.queueCloudKitNeedsUpdate()
    }
    
    
    func deleteEquation(equation: Equation) {
        
        equation.userDeleted = NSNumber(value: true)
        
        equationUpdated(equation: equation)
        
        saveContext()
    }
    
    func newEquation() -> Equation {
        
        let entity = NSEntityDescription.entity(forEntityName: "Equation", in: self.persistentContainer.viewContext)
        let equation = NSManagedObject(entity: entity!, insertInto: self.persistentContainer.viewContext) as! Equation
        
        equation.identifier = UUID().uuidString
        
        if let vendorID = UIDevice.current.identifierForVendor {
            equation.deviceIdentifier = vendorID.uuidString
        }
        
        // Find the equation with the highest sortOrder
        
        let fetchRequest = NSFetchRequest<Equation>(entityName: "Equation")
        
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "sortOrder", ascending: false)]
        fetchRequest.fetchLimit = 1
        
        do {
            if let fetchedEquation = try self.persistentContainer.viewContext.fetch(fetchRequest).first {
                if let equationSortOrder = fetchedEquation.sortOrder?.doubleValue {
                    equation.sortOrder = NSNumber(value: equationSortOrder + 1 as Double)
                }
            }
        } catch {
            
        }
        
        if equation.sortOrder == nil {
            equation.sortOrder = NSNumber(value: 0)
        }
        
        return equation
    }
    
    
    lazy var persistentContainer: NSPersistentContainer = {
        /*
         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it. This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail.
         */
        let container = NSPersistentContainer(name: "CoreData")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                
                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    
    // MARK: - Core Data Saving support
    
    func saveContext () {
        print("saveContext")
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
                print("Saved")
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        } else {
            print("No saves necessary")
        }
        
        printAllEquations()
    }
    
    func updateCloudKit() {
        
        if NumericalHelper.isSettingEnabled(string: NumericalHelperSetting.iCloudHistorySync) {
            // Fetch items from the data base that are posted == nil or posted == 1
            // posted == nil items have never been uploaded
            // posted == 0 items have been posted previously but now need updating.
            // posted == 1 items have been posted and, to the best of our knowledge, are up to date.
            
            // When creating new cloudkit equations we define the record ID as "equation.\(identifier)", this gives us an easy way to reconcile and update items.
            
            
            // 1. Get all unposted items
            let fetch = equationsFetchRequest(NSPredicate(format: "posted == nil || posted == NO"))
            
            do {
                let equations = try self.persistentContainer.viewContext.fetch(fetch)
                
                print(equations)
                print("")
                
                if equations.count > 0 {
                    convertEquationsToCKEquations(equations: equations)
                }
                
            } catch {
                print("Error: Could not fetch equations")
            }
        }
    }
    
    
    func convertEquationsToCKEquations(equations: [Equation]) {
        
        var ckEquations = [CKRecord]()
        
        for equation in equations {
            print(equation)
            
            if let identifier = equation.identifier {
                
                print("original.equation: \(equation)")
                
                let newEquation = CKRecord(recordType: "Equation", recordID: CKRecordID(recordName: "Equation.\(identifier)"))
                
                newEquation.setValue(equation.answer, forKey: "answer")
                newEquation.setValue(equation.creationDate, forKey: "equationCreationDate")
                newEquation.setValue(equation.deviceIdentifier, forKey: "deviceIdentifier")
                newEquation.setValue(equation.identifier, forKey: "identifier")
                newEquation.setValue(equation.lastModifiedDate, forKey: "equationLastModifiedDate")
                newEquation.setValue(equation.question, forKey: "question")
                newEquation.setValue(equation.sortOrder, forKey: "sortOrder")
                
                newEquation.setValue(equation.userDeleted, forKey: "equationDeleted")
                
                
//                newEquation.setValue(NSNumber(integerLiteral: 1), forKey: "equationDeleted")
                
                print("newEquation: \(newEquation)")
                
                ckEquations.append(newEquation)
                
                queuedEquationsToSave[identifier] = equation
                
            } else {
                print("Error: equation is missing identifier")
            }
        }
        
        if ckEquations.count > 0 {
            queueCloudKitEquations(equations: ckEquations)
        }
    }
    
    
    func queueCloudKitEquations(equations: [CKRecord]) {
        
        let operation = CKModifyRecordsOperation(recordsToSave: equations, recordIDsToDelete: nil)
        operation.isAtomic = true
        operation.savePolicy = CKRecordSavePolicy.allKeys
        
        operation.perRecordCompletionBlock = {record, error in
            print("perRecordCompletionBlock")
            if let record = record {
                print("record: \(record)")
                if let identifier = record.object(forKey: "identifier") as? String {
                    print("identifier: \(identifier)")
                    
                    // Compare the record with the current state of the equation.
                    // If all aspects are the same then we have successfully posted this equation.
                    
                    // Fetch this equation from the supplied equations.
                    
                    if let equation = self.queuedEquationsToSave[identifier] {
                        // Found the queued equation.
                        
                        if equation.isEqualToCKEquation(record: record) {
                            print("This equation is now up to date")
                            equation.posted = NSNumber(value: true)
                            self.queuedEquationsToSave[identifier] = nil
                            
                        } else {
                            print("Uh oh this equation has changed")
                        }
                        
                        
                    }
                }
            }
        }
        
        operation.modifyRecordsCompletionBlock = { modified, deleted, error in
            print("modifyRecordsCompletionBlock")
            if let modified = modified {
                print("modified: \(modified)")
                print("")
            }
        }
        
        operation.completionBlock = {
            // Operation is complete, save if needed.
            self.queueSave()
        }
        
        privateDatabase.add(operation)
    }
    
    
    func equationsFetchedResultsController() -> NSFetchedResultsController<Equation> {
        var fetchRequest:NSFetchRequest<Equation>
        
        fetchRequest = self.equationsFetchRequest(NSPredicate(format: "userDeleted == nil || userDeleted == 0"))
        
        // Edit the section name key path and cache name if appropriate.
        // nil for section name key path means "no sections".
        return NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: persistentContainer.viewContext, sectionNameKeyPath: nil, cacheName: nil)
    }

    func equationsFetchRequest(_ predicate:NSPredicate?) -> NSFetchRequest<Equation> {
        
        let fetchRequest = NSFetchRequest<Equation>(entityName: "Equation")
        fetchRequest.predicate = predicate
        
        // Edit the sort key as appropriate.
        // TODO: Work out the sort order property on Equations for use Sort Descriptors right now we default to modified date in reverse chronological order.
        let sortDescriptor = NSSortDescriptor(key: "sortOrder", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]
        return fetchRequest
    }
    
    // MARK: Cloud Kit
    
    lazy var privateDatabase = {
        return CKContainer.default().privateCloudDatabase
    } ()
    
    func cloudFetchLatestEquations() {
        
        if NumericalHelper.isSettingEnabled(string: NumericalHelperSetting.iCloudHistorySync) {
            var fetchDate = NSDate()
            
            var query = CKQuery(recordType: "Equation", predicate: NSPredicate(value: true))
            
            if let lastFetchDate = lastFetchDate {
                query = CKQuery(recordType: "Equation", predicate: NSPredicate(format: "equationLastModifiedDate > %@", lastFetchDate))
            }
            
            query.sortDescriptors = [NSSortDescriptor(key: "equationLastModifiedDate", ascending: false)]
            
            privateDatabase.perform(query, inZoneWith: nil) { (records, error) in
                print(records)
                print(error)
                
                if let records = records {
                    self.compareRecords(records: records)
                }
                
                if error == nil {
                    DispatchQueue.main.async {
                        self.setLastFetchDate(date: fetchDate)
                    }
                }
            }
        }
    }
    
    func compareRecords(records: [CKRecord]) {
        var needsToSave = false
        
        for record in records {
            
            let name = record.recordID.recordName
            
            if name.contains(".") {
                let nameItems = name.components(separatedBy: ".")
                if nameItems.count == 2 {
                    if nameItems[0] == "Equation" {
                        let identifier = nameItems[1]
                        
                        print(identifier)
                        
                        if let fetchedEquation = fetchEquationWithIdentifier(string: identifier) {
                            // Found a matching equation, check if it needs updating.
                            
                            // Who is newer
                            
                            print("fetchedEquation: \(fetchedEquation)")
                            
                            var preferRemoteCopy = false
                            
                            if let localModDate = fetchedEquation.lastModifiedDate, let remoteModDate = record.object(forKey: "equationLastModifiedDate") as? NSDate {
                                // Ok, they both have mod dates. Which is newer.
                                
                                print(remoteModDate)
                                print(localModDate)
                                
                                if (remoteModDate as Date).compare(localModDate as Date) == ComparisonResult.orderedDescending {
                                    // The remoteModDate is newer thatn the local one, therefore we prefer the local version.
                                    
                                    preferRemoteCopy = true
                                } else {
                                    print("")
                                }
                                
                                if preferRemoteCopy {
                                    fetchedEquation.updateTo(record: record)
                                    needsToSave = true
                                }
                                
                            }
                            
                            
                        } else {
                            // Holy moley this is a new equation! Save it!
                            let newEquation = newEquationFromCKRecord(record: record)
                            needsToSave = true
                            print("newEquation: \(newEquation)")
                        }
                        
                    }
                }
            }
        }
        
        self.queueSave()
        
        self.printAllEquations()
    }
    
    func newEquationFromCKRecord(record: CKRecord) -> Equation {
        
        print(record)
        
        let entity = NSEntityDescription.entity(forEntityName: "Equation", in: self.persistentContainer.viewContext)
        let equation = NSManagedObject(entity: entity!, insertInto: self.persistentContainer.viewContext) as! Equation
        
        equation.answer = record.object(forKey: "answer") as? String
        equation.creationDate = record.object(forKey: "equationCreationDate") as? NSDate
        equation.deviceIdentifier = record.object(forKey: "deviceIdentifier") as? String
        equation.identifier = record.object(forKey: "identifier") as? String
        equation.lastModifiedDate = record.object(forKey: "equationLastModifiedDate") as? NSDate
        equation.question = record.object(forKey: "question") as? String
        equation.sortOrder = record.object(forKey: "sortOrder") as? NSNumber
        equation.userDeleted = record.object(forKey: "equationDeleted") as? NSNumber
        equation.posted = NSNumber(value: true) // This local equation is now update to date with Cloudkit, to the best of our knowledge.
        
        print(equation)
        
        return equation
    }
    
    
    func fetchEquationWithIdentifier(string: String) -> Equation? {
        
        print("fetchEquationWithIdentifier: \(string)")
        
        let fetchRequest = equationsFetchRequest(NSPredicate(format: "identifier == %@", string))
        fetchRequest.fetchBatchSize = 1
        
        do {
            let results = try self.persistentContainer.viewContext.fetch(fetchRequest)
            
            print("fetched results: \(results)")
            
            if let first = results.first {
                return first
            }
            
        } catch {
            
        }
        
        return nil
    }
    
    
    func printAllEquations() {
        let fetchRequest = equationsFetchRequest(NSPredicate(value: true))
        
        do {
            let results = try self.persistentContainer.viewContext.fetch(fetchRequest)
            
            print("\n\n\n\n")
            
            for result in results {
                print(result)
            }
            
            print("")
            
        } catch {
            
        }
    }
    
    
    func currentEquation() -> Equation? {
        if let string = UserDefaults.standard.object(forKey: EquationCodingKey.currentEquation) as? String {
            if let equation = fetchEquationWithIdentifier(string: string) {
                return equation
            } else {
                setCurrentEquationID(string: nil)
            }
        }
        
        return nil
    }
    
    
    func setCurrentEquationID(string: String?) {
        if let string = string {
            UserDefaults.standard.set(string, forKey: EquationCodingKey.currentEquation)
        } else {
            UserDefaults.standard.removeObject(forKey: EquationCodingKey.currentEquation)
        }
        UserDefaults.standard.synchronize()
    }
    
    
    
}
