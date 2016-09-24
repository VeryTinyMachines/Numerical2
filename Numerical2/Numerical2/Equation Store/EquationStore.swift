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

open class EquationStore {
	private static var __once: () = {
			Static.instance = EquationStore()
		}()
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
		let nc = NotificationCenter.default
		nc.addObserver(forName: NSNotification.Name(rawValue: SCDSDidImportCloudChangesNotification),
			object: nil,
			queue: OperationQueue.main,
			using: { notification in
//				print("SCDSDidImportCloudChangesNotification")
				self.iCloudDataBaseLastSyncDate = Date()
		})
		
		// TODO: Delete this temporary HACK
		FileManager.default.url(forUbiquityContainerIdentifier: nil)
	}

	//MARK: - Properties -
	fileprivate var cdStack: SinkableCoreDataStore
	open var mainContext: NSManagedObjectContext
	fileprivate var backGroundContext: NSManagedObjectContext
	
	var iCloudDataBaseLastSyncDate:Date {
		get {
			return SinkableUserDefaults.standardUserDefaults.localDefaults.object(forKey: iCloudDatabaseLastSyncDateKey) as! Date
		}
		set {
			SinkableUserDefaults.standardUserDefaults.localDefaults.set(newValue, forKey: iCloudDatabaseLastSyncDateKey)
		}
	}
	
	open var syncEnabled:Bool {
		get {
			return self.cdStack.iCloudSyncEnabled
		}
		set {
			self.cdStack.iCloudSyncEnabled = newValue
			// set this one local only as the sync preference shouldn't sync
			SinkableUserDefaults.standardUserDefaults.setBool(newValue, forKey: "iCloudSyncEnabled")
		}
	}
	
	open func save() {
		self.cdStack.saveContext()
        print("saved")
	}
	
	//MARK: - Equation Handling -
	
	open func equationWithIdentifier(_ identifier: String) -> Equation? {
		let fetchRequest = NSFetchRequest()
		fetchRequest.entity = NSEntityDescription.entity(forEntityName: "Equation", in:mainContext)
		fetchRequest.predicate = NSPredicate(format: "identifier == %@", identifier)
		var equations: Array<Equation>?
		do {
			try equations =  mainContext.fetch(fetchRequest) as? Array<Equation>
		} catch {
			// Replace this implementation with code to handle the error appropriately.
			// abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
			print("Unresolved error \(error)")//\(error.userInfo)
			abort()
		}
		return equations!.first
	}
	
	// TODO: Move this to the Pad Itself
	open func equationArrayForPad(_ pad: Pad?) -> Array<Equation>? {
		var fetchRequest:NSFetchRequest<AnyObject>
		if let thePad = pad {
			fetchRequest = self.equationsFetchRequest(NSPredicate(format: "pad == %@", thePad))
		} else {
			fetchRequest = self.equationsFetchRequest(nil)
		}
        
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "sortOrder", ascending: true)]
		
		var equations: Array<Equation>?
		do {
			try equations =  mainContext.fetch(fetchRequest) as? Array<Equation>
		} catch {
			// Replace this implementation with code to handle the error appropriately.
			// abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
			print("Unresolved error \(error)")//\(error.userInfo)
			abort()
		}
		return equations!
	}
	
	open func firstEquationForPadCurrentPad() -> Equation {
        if let equations:Array<Equation> = self.equationArrayForPad(currentPad!)! {
            return equations.first!
        } else {
            return newEquation()!
        }
	}
	
	open func currentEquation () -> Equation? {
		if let eqID:String = SinkableUserDefaults.standardUserDefaults.objectForKey(currentEquationKey) as? String {
			return self.equationWithIdentifier(eqID)
		}
		return nil
	}
	
	fileprivate func equationsFetchRequest(_ predicate:NSPredicate?) -> NSFetchRequest<AnyObject> {
		let fetchRequest = NSFetchRequest()
		// Edit the entity name as appropriate.
		fetchRequest.entity = NSEntityDescription.entity(forEntityName: "Equation", in:mainContext)
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
	open func equationsFetchedResultsController() -> NSFetchedResultsController<AnyObject> {
		var fetchRequest:NSFetchRequest<AnyObject>
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
	
	open func newEquation() -> Equation? {
		print(#function)
		let newEquation = NSEntityDescription.insertNewObject(forEntityName: "Equation", into: mainContext) as! Equation
		newEquation.pad = self.currentPad
        
        let fetchRequest = NSFetchRequest(entityName: "Equation")
        
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "sortOrder", ascending: false)]
        fetchRequest.fetchLimit = 1
        
        do {
            if let equation = try self.mainContext.fetch(fetchRequest).first as? Equation {
                if let equationSortOrder = equation.sortOrder?.doubleValue {
                    newEquation.sortOrder = NSNumber(value: equationSortOrder + 1 as Double)
                }
            }
        } catch {
            
        }
        
        if newEquation.sortOrder == nil {
            newEquation.sortOrder = NSNumber(value: 0 as Double)
        }
        
		self.cdStack.saveContext()
		return newEquation
	}
    
	
	open func deleteEquation(_ equation:Equation) {
		// Check to see if we are deleting the current equation
		if equation == self.currentEquation() {
			// If so set the current equation key to an empty string
			SinkableUserDefaults.standardUserDefaults.setObject("" , forKey: currentEquationKey)
		}
		mainContext.delete(equation)
		cdStack.saveContext()
	}
	
	//MARK: - Pad Handling -
	
	open func padWithIdentifier(_ identifier:String) -> Pad? {
		let fetchRequest = NSFetchRequest()
		fetchRequest.entity = NSEntityDescription.entity(forEntityName: "Pad", in:mainContext)
		fetchRequest.predicate = NSPredicate(format: "identifier == %@", identifier)
		var pads: Array<Pad>?
		do {
			try pads =  mainContext.fetch(fetchRequest) as? Array<Pad>
		} catch {
			// Replace this implementation with code to handle the error appropriately.
			// abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
			print("Unresolved error \(error)")//\(error.userInfo)
			abort()
		}
		return pads!.first
	}
	
	open func deletePad(_ pad:Pad) {
		// Will be used when we add multiple pads. Equations will delete automatically with pads
		mainContext.delete(pad)
		cdStack.saveContext()
	}
	
	lazy var allPads: Array<Pad>? = {
		// TODO: We'll need a way to interact with pads This could be a simple array or FRC
		return nil
	}()
	
	open var currentPad: Pad? {
		get {
			// Lets see if we have a pad ID save and a pad to match it
			if let padID:String = SinkableUserDefaults.standardUserDefaults.objectForKey(currentPadIDKey) as? String, let pad = self.padWithIdentifier(padID) {
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
	
	
	func newPadWithName(_ name:String) -> Pad {
		let newPad = NSEntityDescription.insertNewObject(forEntityName: "Pad", into: mainContext) as! Pad
		newPad.name = name
		return newPad
	}
    
	
	class var sharedStore: EquationStore {
		struct Static {
			static var onceToken: Int = 0
			static var instance: EquationStore? = nil
		}
		_ = EquationStore.__once
		return Static.instance!
	}
}
