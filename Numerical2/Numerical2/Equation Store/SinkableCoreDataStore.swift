//
//  SinkableCoreDataStore.swift
//  NumericalDBDevProject
//
//  Created by Victor Hudson on 7/14/15.
//  Copyright © 2015 Victor Hudson. All rights reserved.
//

import Foundation
import CoreData
/**
Subscribe to this notification to be alerted to changes imported to the database from iCloud. When it posts Fetch Results controllers should detect changes automatically, and managed objects for detail view controllers should be refetched.
*/
let SCDSDidImportCloudChangesNotification = "SCDSDidImportCloudChangesNotification"
/**
Subscribe to this notification to be alerted to a change in persistent stores. This will happen shortly after app launch and also during migration if you change the iCloud Sync Status. 

@warning **Once this notification posts there should be no reading, writing, or saving to the database until after *SCDSPersistantStoreDidChangeNotification* posts. Block or disable your UI if need be.**
*/
let SCDSPersistentStoreWillChangeNotification = "SCDSPersistentStoreWillChangeNotification"
/**
Subscribe to this notification to be alerted when a change in persistent stores completes. This will happen shortly after app launch and also after migration if you've changed the iCloud Sync Status.

**Once this notification posts it will be safe to resume reading, writing, or saving to the database. It is now safe to unblock or enable your UI if need be.**
*/
let SCDSPersistentStoreDidChangeNotification = "SCDSPersistentStoreDidChangeNotification"

/// Subscribe to SCDSWillTransitionToCloudStoreNotification to be notified when the store is migrating to iCloud.
let SCDSWillMigrateToCloudStoreNotification = "SCDSWillMigrateToCloudStoreNotification"

/// Subscribe to SCDSWillMigrateToLocalStoreNotification to be notified when the store is migrating to iCloud.
let SCDSWillMigrateToLocalStoreNotification = "SCDSWillMigrateToLocalStoreNotification"

/// Subscribe to SCDSStoreMigrationCompleteNotification to be notified when the store migrations have completed.
let SCDSStoreMigrationCompleteNotification = "SCDSStoreMigrationCompleteNotification"

/**
SinkableCoreDataStore is a simple to use class for quickly setting up core data store with optional iCloud syncing.
*/
public class SinkableCoreDataStore: NSObject {
/**
Init with the parameters, all but *iCloudContentName* are required. *iCloudContentName* must not be nil to use iCloud Sync
*/
	init(modelName: String,
		   sqlName: String,
 iCloudContentName: String?,
	 iCloudEnabled: Bool) {

		self.modelName = modelName
		self.sqlName = sqlName
		if let cloudName = iCloudContentName {
			self.iCloudContentKeyName = cloudName
			self.iCloudSyncEnabled = iCloudEnabled
		} else {
			self.iCloudSyncEnabled = false
		}
		super.init()

//		print("SinkableCDStoreInit with model: \(self.modelName), sql: \(self.storeSQL)")
		
		self.setupNotifications()
	}
	
	// MARK: - Core Data stack
/** 
Use this property to toggle sync status and for displaying sync status in your UI
*/
	public var iCloudSyncEnabled:Bool {
		didSet {
			// We migrate if the stack has been setup, otherwise we only need to set the bool
			// TODO: Enable the store migrations
			if self.storeIsOpen {
				if iCloudSyncEnabled {
					print("\(__FUNCTION__) -> true")
					iCloudNotificationListeners()
//					self.migrateStoreWithOptions(self.iCloudToLocalPersistentStoreMigrationOptions)
				} else {
					print("\(__FUNCTION__) -> false")
//					self.migrateStoreWithOptions(self.iCloudToLocalPersistentStoreMigrationOptions)
					stopiCloudNotificationListeners()
				}
			} else {
				print("\(__FUNCTION__) - No Store to migrate yet")
			}
		}
	}
/**
A Managed Object Context with Main Thread Concurrency. Use this context for all data to display in a UI.
*/
	lazy public var mainContext:NSManagedObjectContext = {
		// Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.) This property is optional since there are legitimate error conditions that could cause the creation of the context to fail.
		let coordinator = self.persistentStoreCoordinator
		var managedObjectContext = NSManagedObjectContext(concurrencyType: .MainQueueConcurrencyType)
		managedObjectContext.persistentStoreCoordinator = coordinator
		return managedObjectContext
	}()
	
/**
A Managed Object Context with Background Thread Concurrency. Changes made in this context will be saved to *mainContext* when **Save( )** is called on this context.
*/
	lazy public var backGroundContext:NSManagedObjectContext = {
		// Returns a background queue managed object context for the application. This property is optional since there are legitimate error conditions that could cause the creation of the context to fail.
		var managedObjectContext = NSManagedObjectContext(concurrencyType: .PrivateQueueConcurrencyType)
		managedObjectContext.parentContext = self.mainContext
		return managedObjectContext
	}()
/**
Saves changes in the *mainContext* to disk.
*/
	func saveContext () -> Bool {
		print(__FUNCTION__)
		if mainContext.hasChanges {
			do {
				try mainContext.save()
			} catch {
				// Replace this implementation with code to handle the error appropriately.
				// abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
				let nserror = error as NSError
				NSLog("Unresolved error \(nserror), \(nserror.userInfo)")
//				abort()
				return false
			}
		}
		return true
	}
	
	// MARK: - Persistent Store
	private func persistentStoreOptions() -> Dictionary<String, AnyObject>  {
		// these are the normal everyday store options
		if self.iCloudSyncEnabled {
//			print("\(__FUNCTION__) -> iCloud Options")
			// TODO: Use iCloud Store Options
			return self.iCloudPersistentStoreOptions
//			return self.localPersistentStoreOptions
		}
//		print("\(__FUNCTION__) -> Local Options")
		return self.localPersistentStoreOptions
	}
	
	private lazy var localPersistentStoreOptions: Dictionary<String, AnyObject> = [NSMigratePersistentStoresAutomaticallyOption: NSNumber(bool: true),
			NSInferMappingModelAutomaticallyOption: NSNumber(bool: true)]
	
	
	private lazy var iCloudPersistentStoreOptions:Dictionary<String, AnyObject> = {
		return [NSPersistentStoreUbiquitousContentNameKey : self.iCloudContentKeyName!,
			NSMigratePersistentStoresAutomaticallyOption : NSNumber(bool: true),
			NSInferMappingModelAutomaticallyOption : NSNumber(bool: true)]
		}()
	
	private lazy var iCloudToLocalPersistentStoreMigrationOptions: Dictionary<String, AnyObject> = [NSPersistentStoreRemoveUbiquitousMetadataOption : NSNumber(bool: true),
			NSMigratePersistentStoresAutomaticallyOption : NSNumber(bool: true),
			NSInferMappingModelAutomaticallyOption : NSNumber(bool: true)]
	
	private func migrateStoreWithOptions(options: Dictionary<String, AnyObject>){
		// TODO: Post some notifications
		print(__FUNCTION__)
		self.saveContext()
		let currentStore = self.persistentStoreCoordinator.persistentStoreForURL(self.currentStoreURL!)
		let url = self.storeURL()
		
		// migrate the store
		do {
			try self.persistentStoreCoordinator.migratePersistentStore(currentStore!, toURL: url, options: options, withType: NSSQLiteStoreType)
		} catch {
			// Report any error we got.
			var dict = [String: AnyObject]()
			dict[NSLocalizedDescriptionKey] = "Failed to initialize the application's saved data"
			dict[NSUnderlyingErrorKey] = error as NSError
			let wrappedError = NSError(domain: "YOUR_ERROR_DOMAIN", code: 9999, userInfo: dict)
			// Replace this with code to handle the error appropriately.
			// abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
			NSLog("Unresolved error \(wrappedError), \(wrappedError.userInfo)")
			abort()
		}
		
		// Remove the store just to be safe
//		do {
//			try persistentStoreCoordinator.removePersistentStore(currentStore!)
//		} catch {
//			// Report any error we got.
//			var dict = [String: AnyObject]()
//			dict[NSLocalizedDescriptionKey] = "Failed to initialize the application's saved data"
//			dict[NSUnderlyingErrorKey] = error as NSError
//			let wrappedError = NSError(domain: "YOUR_ERROR_DOMAIN", code: 9999, userInfo: dict)
//			// Replace this with code to handle the error appropriately.
//			// abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
//			NSLog("Unresolved error \(wrappedError), \(wrappedError.userInfo)")
//			abort()
//		}
//		
//		// finally lets add the store back just like it would be at normal app launch
//		self.addStoreWithOptions(self.persistentStoreOptions(), coordinator: persistentStoreCoordinator)
		
		self.currentStoreURL = url
		// now reset the object contexts
		self.mainContext.reset()
		self.backGroundContext.reset()
		// TODO: Post some notifications
	}
	
	private func addStoreWithOptions(options: Dictionary<String, AnyObject>, coordinator:NSPersistentStoreCoordinator){
		let url = self.storeURL()
//		print("\(__FUNCTION__) - \(url)")
		let failureReason = "There was an error creating or loading the application's saved data."
		do {
			try coordinator.addPersistentStoreWithType(NSSQLiteStoreType, configuration: nil, URL: url, options: options)
		} catch {
			// Report any error we got.
			var dict = [String: AnyObject]()
			dict[NSLocalizedDescriptionKey] = "Failed to initialize the application's saved data"
			dict[NSLocalizedFailureReasonErrorKey] = failureReason
			
			dict[NSUnderlyingErrorKey] = error as NSError
			let wrappedError = NSError(domain: "YOUR_ERROR_DOMAIN", code: 9999, userInfo: dict)
			// Replace this with code to handle the error appropriately.
			// abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
			NSLog("Unresolved error \(wrappedError), \(wrappedError.userInfo)")
			abort()
		}
		self.currentStoreURL = url
	}
	
	private lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator = {
//		print(__FUNCTION__)
		// The persistent store coordinator for the application. This implementation creates and returns a coordinator, having added the store for the application to it. This property is optional since there are legitimate error conditions that could cause the creation of the store to fail.
		// Create the coordinator and store
		let coordinator = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
		self.addStoreWithOptions(self.persistentStoreOptions(), coordinator:coordinator)
		self.storeIsOpen = true
		return coordinator
		}()
	
	// MARK: - Notification Handling
	private func setupNotifications () {
		let nc = NSNotificationCenter.defaultCenter()
		nc.addObserver(self, selector: "saveContext", name: "UIApplicationDidEnterBackgroundNotification", object: nil)
		if self.iCloudSyncEnabled {
			self.iCloudNotificationListeners()
		}
	}
	
	private func iCloudNotificationListeners () {
//		print(__FUNCTION__)
		let nc = NSNotificationCenter.defaultCenter()
		let ps = persistentStoreCoordinator
		let queue = NSOperationQueue.mainQueue()
		unowned let weakself = self // retain cycles in closures are bad!
		
		// handle stores will change
		nc.addObserverForName(NSPersistentStoreCoordinatorStoresWillChangeNotification, object: ps, queue: queue, usingBlock: {notification in
//			print("NSPersistentStoreCoordinatorStoresWillChangeNotification")
			weakself.mainContext.performBlock({ // in a block in case it's not on the main thread
				if weakself.saveContext() {
					weakself.mainContext.reset()
				}
			})
			weakself.postNotificationNamed(SCDSPersistentStoreWillChangeNotification)
		})
		
		// handle stores did change
		nc.addObserverForName(NSPersistentStoreCoordinatorStoresDidChangeNotification, object: ps, queue: queue, usingBlock: {notification in
//			print("NSPersistentStoreCoordinatorStoresDidChangeNotification")
			weakself.postNotificationNamed(SCDSPersistentStoreDidChangeNotification)
		})
		
		// handle stores removed
		nc.addObserverForName(NSPersistentStoreCoordinatorWillRemoveStoreNotification, object: ps, queue: queue, usingBlock: {notification in
			// not sure if we need this yet
		})
		
		// handle icloud database changes
		nc.addObserverForName(NSPersistentStoreDidImportUbiquitousContentChangesNotification, object: ps, queue: queue, usingBlock: {notification in
			print("NSPersistentStoreDidImportUbiquitousContentChangesNotification")
			weakself.mainContext.performBlock({ // in a block in case it's not on the main thread
				weakself.mainContext.mergeChangesFromContextDidSaveNotification(notification)
				weakself.mainContext.refreshAllObjects()
				weakself.postNotificationNamed(SCDSDidImportCloudChangesNotification)
			})
		})
		
	}
	
	private func stopiCloudNotificationListeners () {
//		print(__FUNCTION__)
		let nc = NSNotificationCenter.defaultCenter()
		let ps = self.persistentStoreCoordinator
		nc.removeObserver(self, name: NSPersistentStoreCoordinatorStoresWillChangeNotification, object:ps)
		nc.removeObserver(self, name: NSPersistentStoreCoordinatorStoresDidChangeNotification, object:nil)
		nc.removeObserver(self, name: NSPersistentStoreCoordinatorWillRemoveStoreNotification, object:ps)
		nc.removeObserver(self, name: NSPersistentStoreDidImportUbiquitousContentChangesNotification, object:ps)
	}
	
	private func postNotificationNamed (name: String) {
		// adding a dedicated method for this so if we need to redirect notifications to the main thread we have one centralized location for that
		print("\(__FUNCTION__) - \(name)")
		NSNotificationCenter.defaultCenter().postNotificationName(name, object: nil)
	}
	
	// MARK: - Supporting File Paths
	private func storeURL () -> NSURL {
//		if self.iCloudSyncEnabled {
//			return self.iCloudStoreURL()
//		}
		return self.localStoreURL()
	}
	
	private func iCloudStoreURL () -> NSURL {
		return self.applicationDocumentsDirectory.URLByAppendingPathComponent(self.iCloudStoreSQL)
	}
	
	private func localStoreURL () -> NSURL {
		return self.applicationDocumentsDirectory.URLByAppendingPathComponent(self.localStoreSQL)
		//TODO: App Group Support
	}
	
	private lazy var localStoreSQL: String = {
		return self.sqlName + ".sqlite"
		}()
	
	private lazy var iCloudStoreSQL: String = {
		return self.sqlName + "-iCloud.sqlite"
		}()
	
	private lazy var applicationDocumentsDirectory: NSURL = {
		// The directory the application uses to store the Core Data store file. This code uses a directory named "com.VicHudsonAppDeveloper.NumericalDBDevProject" in the application's documents Application Support directory.
		
		let urls = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)
		return urls[urls.count-1]
		}()
	
	private lazy var managedObjectModel: NSManagedObjectModel = {
		// The managed object model for the application. This property is not optional. It is a fatal error for the application not to be able to find and load its model.
		let modelURL = NSBundle.mainBundle().URLForResource(self.modelName , withExtension: "momd")!
		return NSManagedObjectModel(contentsOfURL: modelURL)!
		}()
	
	private var modelName:String
	private var sqlName:String
	private var iCloudContentKeyName:String?
	private var appGroupName:String?
	private var storeIsOpen:Bool = false
	private var currentStoreURL:NSURL?
}