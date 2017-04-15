//
//  AppDelegate.swift
//  Numerical2
//
//  Created by Andrew J Clark on 31/07/2015.
//  Copyright © 2015 Very Tiny Machines. All rights reserved.
//

import UIKit
import CloudKit
import UserNotifications
import Fabric
import Crashlytics

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        EquationStore.sharedStore.initialiseSetup()
        EquationStore.sharedStore.convertDeprecatedEquationsIfNeeded()
        
        Fabric.with([Crashlytics.self])
        
        PremiumCoordinator.shared.setupManager()
        
        // FIRApp.configure()
        // GADMobileAds.configure(withApplicationID: "ca-app-pub-3940256099942544~1458002511")
        
        DispatchQueue.main.async {
            SoundManager.primeSounds()
        }
        
        
        
        /*
        UNUserNotificationCenter.current().requestAuthorization(options:
            [[.alert, .sound, .badge]],
                                                                completionHandler: { (granted, error) in
                                                                    // Handle Error
        })
        
        application.registerForRemoteNotifications()
        */
        
        // Test saving to group.andrewjclark.numericalapp
//        
//        if let defs = UserDefaults(suiteName: "group.andrewjclark.numericalapp") {
//            print(defs.colorForKey(key: "CurrentTheme.firstColor"))
//            print(defs.colorForKey(key: "CurrentTheme.secondColor"))
//            print(defs.colorForKey(key: "CurrentTheme.foregroundColor"))
//            print(defs.object(forKey: "CurrentTheme.style"))
//            
//            defs.set(true, forKey: "test")
//            defs.synchronize()
//        }
        
        
        // Current Version saving and presentation is now in ViewController
        
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        
        EquationStore.sharedStore.refreshiCloudStatusCheck()
        application.applicationIconBadgeNumber = 0
        PremiumCoordinator.shared.syncExpiryDate()
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        print("")
        
        
        let notification: CKNotification =
            CKNotification(fromRemoteNotificationDictionary:
                userInfo as! [String : NSObject])
        
        if (notification.notificationType ==
            CKNotificationType.query) {
            
            let queryNotification =
                notification as! CKQueryNotification
            
            if let recordID = queryNotification.recordID {
                EquationStore.sharedStore.fetchAndSaveEquation(recordID: recordID, completion: { (complete) in
                    if complete {
                        completionHandler(UIBackgroundFetchResult.newData)
                    } else {
                        completionHandler(UIBackgroundFetchResult.failed)
                    }
                })
            }
        }
        
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any]) {
        print("")
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        print("")
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("")
    }
    
    
    
    
    


}

