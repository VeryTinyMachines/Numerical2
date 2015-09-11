//
//  EquationStore.swift
//  NumericalDBDevProject
//
//  Created by Victor Hudson on 7/14/15.
//  Copyright © 2015 Victor Hudson. All rights reserved.
//

import Foundation
import CoreData

//MARK: - Constants -
let currentPadIDKey = "currentPadIDKey"
let currentEquationKey = "currentEquationKey"
let currentAnswerKey = "currentAnswerKey"
let iCloudSyncUserPrefKey = "iCloudSyncUserPrefKey"
let iCloudDatabaseLastSyncDateKey = "iCloudDatabaseLastSyncDateKey"

public class EquationStore {
	//MARK: - Class Access & Setup -
	init() {
		// Prepare our Pref Sync Manager
		// TODO: Set App Group ID before you call syncronize if you're using one
//		SinkableUserDefaults.standardUserDefaults.appGroupID = ""
		SinkableUserDefaults.standardUserDefaults.syncronize()
		
		// Set up the CDStack and MOC Properties
		// TODO: Respect User Pref with regards to iCloud Sync
//		var iCloudSync = SinkableUserDefaults.standardUserDefaults.localDefaults.boolForKey(iCloudSyncUserPrefKey)
//		cdStack = SinkableCoreDataStore(modelName:"NumericalDataModel", sqlName:"NumericalData", iCloudContentName:"NumericalSyncSample", iCloudEnabled: iCloudSync)
		cdStack = SinkableCoreDataStore(modelName:"NumericalDataModel", sqlName:"NumericalData", iCloudContentName:"NumericalSyncSample", iCloudEnabled: true)
		mainContext = cdStack.mainContext
		backGroundContext = cdStack.backGroundContext
		
		// Handle icloud database changes
		let nc = NSNotificationCenter.defaultCenter()
		nc.addObserverForName(SCDSDidImportCloudChangesNotification,
			object: nil,
			queue: NSOperationQueue.mainQueue(),
			usingBlock: { notification in
//				print("SCDSDidImportCloudChangesNotification")
				self.iCloudDataBaseLastSyncDate = NSDate()
		})
		
		// TODO: Delete this temporary HACK
		NSFileManager.defaultManager().URLForUbiquityContainerIdentifier(nil)
	}

	//MARK: - Properties -
	private var cdStack: SinkableCoreDataStore
	public var mainContext: NSManagedObjectContext
	private var backGroundContext: NSManagedObjectContext
	
	var iCloudDataBaseLastSyncDate:NSDate {
		get {
			return SinkableUserDefaults.standardUserDefaults.localDefaults.objectForKey(iCloudDatabaseLastSyncDateKey) as! NSDate
		}
		set {
			SinkableUserDefaults.standardUserDefaults.localDefaults.setObject(newValue, forKey: iCloudDatabaseLastSyncDateKey)
		}
	}
	
	public var syncEnabled:Bool {
		get {
			return self.cdStack.iCloudSyncEnabled
		}
		set {
			self.cdStack.iCloudSyncEnabled = newValue
			// set this one local only as the sync preference shouldn't sync
			SinkableUserDefaults.standardUserDefaults.setBool(newValue, forKey: "iCloudSyncEnabled")
		}
	}
	
	public func save() {
		self.cdStack.saveContext()
	}
	
	//MARK: - Equation Handling -
	
	public func equationWithIdentifier(identifier: String) -> Equation? {
		let fetchRequest = NSFetchRequest()
		fetchRequest.entity = NSEntityDescription.entityForName("Equation", inManagedObjectContext:mainContext)
		fetchRequest.predicate = NSPredicate(format: "identifier == %@", identifier)
		var equations: Array<Equation>?
		do {
			try equations =  mainContext.executeFetchRequest(fetchRequest) as? Array<Equation>
		} catch {
			// Replace this implementation with code to handle the error appropriately.
			// abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
			print("Unresolved error \(error)")//\(error.userInfo)
			abort()
		}
		return equations!.first
	}
	
	// TODO: Move this to the Pad Itself
	public func equationArrayForPad(pad: Pad?) -> Array<Equation>? {
		var fetchRequest:NSFetchRequest
		if let thePad = pad {
			fetchRequest = self.equationsFetchRequest(NSPredicate(format: "pad == %@", thePad))
		} else {
			fetchRequest = self.equationsFetchRequest(nil)
		}
        
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "sortOrder", ascending: true)]
		
		var equations: Array<Equation>?
		do {
			try equations =  mainContext.executeFetchRequest(fetchRequest) as? Array<Equation>
		} catch {
			// Replace this implementation with code to handle the error appropriately.
			// abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
			print("Unresolved error \(error)")//\(error.userInfo)
			abort()
		}
		return equations!
	}
	
	public func firstEquationForPadCurrentPad() -> Equation {
        if let equations:Array<Equation> = self.equationArrayForPad(currentPad!)! {
            return equations.first!
        } else {
            return newEquation()!
        }
	}
	
	public func currentEquation () -> Equation? {
		if let eqID:String = SinkableUserDefaults.standardUserDefaults.objectForKey(currentEquationKey) as? String {
			return self.equationWithIdentifier(eqID)
		}
		return nil
	}
	
	private func equationsFetchRequest(predicate:NSPredicate?) -> NSFetchRequest {
		let fetchRequest = NSFetchRequest()
		// Edit the entity name as appropriate.
		fetchRequest.entity = NSEntityDescription.entityForName("Equation", inManagedObjectContext:mainContext)
//		if let pred = predicate {
//			fetchRequest.predicate = pred
//		}
		// Set the batch size to a suitable number.
		fetchRequest.fetchBatchSize = 20
		
		// Edit the sort key as appropriate.
		// TODO: Work out the sort order property on Equations for use Sort Descriptors right now we default to modified date in reverse chronological order.
		let sortDescriptor = NSSortDescriptor(key: "sortOrder", ascending: true)
		fetchRequest.sortDescriptors = [sortDescriptor]
		return fetchRequest
	}
	
	// iOS only This will Need Moved out if the class is shared with a mac app
	public func equationsFetchedResultsController() -> NSFetchedResultsController {
		var fetchRequest:NSFetchRequest
		if let thePad = self.currentPad {
			// We have a user defined Pad
			fetchRequest = self.equationsFetchRequest(NSPredicate(format: "pad == %@", thePad))
		} else {
			// The pad is nil so it's presented as the default pad
			fetchRequest = self.equationsFetchRequest(NSPredicate(format: "pad == nil"))
		}
		// Edit the section name key path and cache name if appropriate.
		// nil for section name key path means "no sections".
		return NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: mainContext, sectionNameKeyPath: nil, cacheName: nil)
	}
	
	public func newEquation() -> Equation? {
		print(__FUNCTION__)
		let newEquation = NSEntityDescription.insertNewObjectForEntityForName("Equation", inManagedObjectContext: mainContext) as! Equation
		newEquation.pad = self.currentPad
        
        let frc = equationsFetchedResultsController()
        
        do {
            try frc.performFetch()
        } catch {
            print("error")
            
        }
        
        
        if let count = frc.fetchedObjects?.count {
            let newSortOrder:Double = Double(count) + 1
            
            // Set the sort order to the current date and time as a single integer
            newEquation.sortOrder = NSNumber(double: newSortOrder)
        }
        
        
        
        print("newEquation.sortOrder: \(newEquation.sortOrder?.doubleValue)")
        
		self.cdStack.saveContext()
		return newEquation
	}
	
	public func deleteEquation(equation:Equation) {
		// Check to see if we are deleting the current equation
		if equation == self.currentEquation() {
			// If so set the current equation key to an empty string
			SinkableUserDefaults.standardUserDefaults.setObject("" , forKey: currentEquationKey)
		}
		mainContext.deleteObject(equation)
		cdStack.saveContext()
	}
	
	//MARK: - Pad Handling -
	
	public func padWithIdentifier(identifier:String) -> Pad? {
		let fetchRequest = NSFetchRequest()
		fetchRequest.entity = NSEntityDescription.entityForName("Pad", inManagedObjectContext:mainContext)
		fetchRequest.predicate = NSPredicate(format: "identifier == %@", identifier)
		var pads: Array<Pad>?
		do {
			try pads =  mainContext.executeFetchRequest(fetchRequest) as? Array<Pad>
		} catch {
			// Replace this implementation with code to handle the error appropriately.
			// abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
			print("Unresolved error \(error)")//\(error.userInfo)
			abort()
		}
		return pads!.first
	}
	
	public func deletePad(pad:Pad) {
		// Will be used when we add multiple pads. Equations will delete automatically with pads
		mainContext.deleteObject(pad)
		cdStack.saveContext()
	}
	
	lazy var allPads: Array<Pad>? = {
		// TODO: We'll need a way to interact with pads This could be a simple array or FRC
		return nil
	}()
	
	public var currentPad: Pad? {
		get {
			// Lets see if we have a pad ID save and a pad to match it
			if let padID:String = SinkableUserDefaults.standardUserDefaults.objectForKey(currentPadIDKey) as? String, pad = self.padWithIdentifier(padID) {
				return pad
			}
			// We don't have a current pad ID stored or that pad hasn't synced in from another device yet
			return nil
		}
		set {
			let thePad = newValue
			SinkableUserDefaults.standardUserDefaults.setObject(thePad!.identifier!, forKey: currentPadIDKey)
		}
	}
	
//	public func defaultPad () -> Pad {
//		let fetchRequest = NSFetchRequest()
//		fetchRequest.entity = NSEntityDescription.entityForName("Pad", inManagedObjectContext: self.mainContext)
//		fetchRequest.predicate = NSPredicate(format: "name == %@", "Default Pad")
//	
//		var fetchResults: Array<Pad>?
//		do {
//			try fetchResults =  mainContext.executeFetchRequest(fetchRequest) as? Array<Pad>
//		} catch {
//			// Replace this implementation with code to handle the error appropriately.
//			// abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
//			print("Unresolved error \(error)")//\(error.userInfo)
//			abort()
//		}
//		
//		if fetchResults?.count == 1 {
//			print("Return first pad from \(fetchResults?.count) pads.")
//			return (fetchResults?.first)!
//		} else {
//			print("Creating the default pad")
//			let _defaultPad = newPad()
//			_defaultPad.name = "Default Pad"
//			_defaultPad.removable = NSNumber(bool:false)
//			self.cdStack.saveContext()
//			return _defaultPad
//		}
//	}
	
	
	func newPadWithName(name:String) -> Pad {
		let newPad = NSEntityDescription.insertNewObjectForEntityForName("Pad", inManagedObjectContext: mainContext) as! Pad
		newPad.name = name
		return newPad
	}
    
	
	class var sharedStore: EquationStore {
		struct Static {
			static var onceToken: dispatch_once_t = 0
			static var instance: EquationStore? = nil
		}
		dispatch_once(&Static.onceToken) {
			Static.instance = EquationStore()
		}
		return Static.instance!
	}
}
