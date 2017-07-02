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
        
        Fabric.with([Crashlytics.self])
        
        EquationStore.sharedStore.initialiseSetup()
        // EquationStore.sharedStore.convertDeprecatedEquationsIfNeeded()
        
        PremiumCoordinator.shared.setupManager()
        
        // FIRApp.configure()
        // GADMobileAds.configure(withApplicationID: "ca-app-pub-3940256099942544~1458002511")
        
        DispatchQueue.main.async {
            SoundManager.primeSounds()
        }
        
        // temp for testing - make 30 equations.
        
        DispatchQueue.main.async {
            for number in 1...30 {
                EquationStore.sharedStore.newEquation(question: "\(number)+0", answer: "\(number)")
            }
            EquationStore.sharedStore.queueSave()
            EquationStore.sharedStore.queueCloudKitNeedsUpdate()
        }
        
        
        //Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { (timer) in
//            print(WorkingEquationManager.sharedManager.printHistory())
//        }
        
        SimpleLogger.appendLog(string: "application.didFinishLaunchingWithOptions")
        
        // Current Version saving and presentation is now in ViewController
        
//        DispatchQueue.main.async {
//            UIApplication.shared.setAlternateIconName("AppIcon-2")
//        }
        
        if let url = launchOptions?[UIApplicationLaunchOptionsKey.url] as? NSURL {
            if let scheme = url.scheme {
                if scheme == "numerical" {
                    processURL(url: url as URL)
                }
            }
        }
        
        return true
    }

    
    func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any] = [:]) -> Bool {
        // User opened a URL while the app was open
        
        if let scheme = url.scheme {
            if scheme == "numerical" {
                processURL(url: url)
                
                if let rootView = UIApplication.shared.keyWindow?.rootViewController as? ViewController {
                    rootView.processURLIfNeeded()
                }
            }
        }
        
        return true
    }
    
    func processURL(url: URL) {
        URLHandler.sharedHandler.url = url
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
        
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        
    }
}

