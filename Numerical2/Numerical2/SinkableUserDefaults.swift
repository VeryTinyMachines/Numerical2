//
//  SinkableUserDefaults.swift
//  NumericalDBDevProject
//
//  Created by Victor Hudson on 8/5/15.
//  Copyright © 2015 Victor Hudson. All rights reserved.
//

import Foundation
///Subscribe to *SinkableUserDefaultsDidImportUserPreferenceChangesNotification* anywhere you want to be notified that pref changes were imported from iCloud. The notification includes a *userInfo* dictionary with an array of the preference keys that were changed in the *SinkableUserDefaultsChangedValuesKey* key
public let SinkableUserDefaultsDidImportUserPreferenceChangesNotification = "SinkableUserDefaultsDidImportUserPreferenceChangesNotification"

///SinkableUserDefaultsChangedValuesKey is the key in the the *SinkableUserDefaultsDidImportUserPreferenceChangesNotification.userInfo* dictionary which contains an array of the keys for the imported preference changes.
public let SinkableUserDefaultsChangedValuesKey = "SinkableUserDefaultsChangedValuesKey"
/**
SinkableUserDefaults is a simple to use class for quickly setting User Defaults with iCloud syncing. App Groups are also supported for use with extension defaults sharing. 

There are currently getters and setters for *value, object, and bool*. 

Use the *removeObject(_:)* method to remove a key and it's value from the store.

Use the *syncronize()* method to insure you have the most recent values.

When changes are imported from iCloud a *SinkableUserDefaultsDidImportUserPreferenceChangesNotification* is posted with a userInfo dictionary containing an array of keys that were updated during the import.
*/
open class SinkableUserDefaults : NSObject, RMStoreTransactionPersistor  {
/// The Shared Singleton Instance. Use *SinkableUserDefaults.standardUserDefaults()* for any preferences you want synced via iCloud. Use *SinkableUserDefaults.standardUserDefaults.localDefaults()* to set local only preferences you don't wish synced via iCloud.
	open static let standardUserDefaults = SinkableUserDefaults()	// MARK: - Properties
/**
The *appGroupID* property is used for sharing local defaults with extensions.

**If you are using with an app group to share defaults with extensions set the App Group ID before your first call to *syncronize()*.**
*/
	open var appGroupID:String? {
		didSet {
			// We will reset our user defaults variable to use the new app group ID
			if let defaults = UserDefaults(suiteName: appGroupID) {
				localDefaults = defaults
			} else {
				localDefaults = UserDefaults.standard
			}
			self.syncronize()
		}
	}

/**
**Use the *localDefaults* property only for defaults you don't want shared via iCloud KVS**
*/
	open lazy var localDefaults:UserDefaults = {
		// By default we use NSUserDefaults.standardUserDefaults
		// In the setter for app group ID we replace it with the app group suite of user defaults
		return UserDefaults.standard
		}()
	
	
	// MARK: - Methods
/**
Call this method near the first launch of your app to make sure you have the most recent changes from iCloud as quicly as possible. You may also call this to trigger a sync push, although that should'nt be needed as all the setters on this class trigger a push when values are set.
	
@warning **Be sure you've set the *appGroupID* property before calling *syncronize()* if you are sharing defaults with extensions via app group**.
*/
	open func syncronize () {
		self.localDefaults.synchronize()
		self.cloudDefaults.synchronize()
	}
	
//	public func setValue(value:AnyObject?, forKey:String) {
//		self.localDefaults.setValue(value, forKey:forKey)
//		self.cloudDefaults.setValue(value, forKey:forKey)
//		syncronize()
//	}
//	public func valueForKey(key:String) -> AnyObject? {
//		print(__FUNCTION__)
//		if let value = localDefaults.valueForKey(key) {
//			return value
//		}
//		if let value = cloudDefaults.valueForKey(key) {
//			return value
//		}
//		return nil
//	}
	
	open func setObject(_ object:AnyObject?, forKey:String) {
//		print("\(__FUNCTION__) - \(object!)")
		self.localDefaults.set(object, forKey:forKey)
		self.cloudDefaults.set(object, forKey:forKey)
		syncronize()
	}
	open func objectForKey(_ key:String) -> AnyObject? {
		var returnValue:AnyObject? = nil
		if let value = localDefaults.object(forKey: key) {
			returnValue = value as AnyObject?
		} else if let value = cloudDefaults.object(forKey: key) {
			returnValue = value as AnyObject?
		}
//		print("\(__FUNCTION__) - \(returnValue)")
		return returnValue
	}
	
	open func setBool(_ bool:Bool, forKey:String) {
//		print(__FUNCTION__)
		self.localDefaults.set(bool, forKey:forKey)
		self.cloudDefaults.set(bool, forKey:forKey)
		self.syncronize()
	}
	open func boolForKey(_ key:String) -> Bool {
//		print(__FUNCTION__)
		if localDefaults.bool(forKey: key) == true {
			return true
		}
		if cloudDefaults.bool(forKey: key) == true {
			return true
		}
		return false
	}
	
	open func removeObjectForKey(_ key:String) {
		self.localDefaults.removeObject(forKey: key)
		self.cloudDefaults.removeObject(forKey: key)
		self.syncronize()
	}
	
	// MARK: - Private Stuff
	fileprivate lazy var cloudDefaults:NSUbiquitousKeyValueStore = {
//		print("Loading iCloud KVS")
		let iCloudDefaults = NSUbiquitousKeyValueStore.default()
//		print("Adding iCloud KVS Listener")
		self.notificationCenter.addObserver(forName: NSUbiquitousKeyValueStore.didChangeExternallyNotification,
			object: iCloudDefaults,
			queue: OperationQueue.main,
			using: { notification in
				// We get more information from the notification, by using:
				// NSUbiquitousKeyValueStoreChangeReasonKey or NSUbiquitousKeyValueStoreChangedKeysKey constants
				// against the notification's useInfo.
				//
//				print("SinkableUserDefaults iCloudPrefKeyChangedHandler Called")
				var userInfo:Dictionary<String,AnyObject> = ((notification as NSNotification).userInfo as? Dictionary<String,AnyObject>)!
				
				// get the reason for the notification (initial download, external change or quota violation change)
				var reason:Int = userInfo[NSUbiquitousKeyValueStoreChangeReasonKey] as! Int
				
				// reason can be:
				//
				// NSUbiquitousKeyValueStoreServerChange:
				//      Value(s) were changed externally from other users/devices.
				//      Get the changes and update the corresponding keys locally.
				//
				// NSUbiquitousKeyValueStoreInitialSyncChange:
				//      Initial downloads happen the first time a device is connected to an iCloud account,
				//      and when a user switches their primary iCloud account.
				//      Get the changes and update the corresponding keys locally.
				//
				// note: if you receive "NSUbiquitousKeyValueStoreInitialSyncChange" as the reason,
				// you can decide to "merge" your local values with the server values
				//
				
				if reason == NSUbiquitousKeyValueStoreInitialSyncChange	{
					print("Initial iCloud KV Sync");
					// do the merge
					// ... but for this sample we have only one value, so a merge is not necessary
				}
				
				// Grab a list of the iCloud KVS Keys that were changed.
				if let changedKeys = userInfo[NSUbiquitousKeyValueStoreChangedKeysKey] as? Array<String> {
					// We need to update the local defaults to match
					// the new incoming values from iCloud KVS.
					_ = changedKeys.map{
						let cloudValue = self.cloudDefaults.object(forKey: $0)
						self.localDefaults.set(cloudValue, forKey:$0)
//						print("SinkableUserDefaults Set local value: \(cloudValue!) for Key:\($0)")
					}
					
					// Post Notification that we've updated some defaults
					// We'll add the keys for what we've changed so the receiver
					// Can determine if the change is relevant to it's context.
					self.notificationCenter.post(name: Notification.Name(rawValue: SinkableUserDefaultsDidImportUserPreferenceChangesNotification),
						object:nil,
						userInfo:[SinkableUserDefaultsChangedValuesKey: changedKeys])
				}
		})
		return iCloudDefaults
		}()
    
    open func persistTransaction(_ transaction: SKPaymentTransaction!) {
        self.setBool(true, forKey: "Purchased | " + transaction.payment.productIdentifier)
    }
    
    open func isProducPurchasedWithID(_ productId:String) -> Bool {
        return self.boolForKey("Purchased | " + productId)
    }
	
	fileprivate lazy var notificationCenter:NotificationCenter  = {
//		print("Loading NSNotificationCenter")
		return NotificationCenter.default
		}()

	fileprivate override init() {} // we dont want external calls to init()
}
