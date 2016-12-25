//
//  AppDelegate.swift
//  Numerical2
//
//  Created by Andrew J Clark on 31/07/2015.
//  Copyright © 2015 Very Tiny Machines. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAnalytics
import CloudKit
import UserNotifications

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
//        WatchCommunicator.sharedCommunicator.setup()
        
        print(PremiumCoordinator.shared.themes)
        
        EquationStore.sharedStore.initialiseSetup()
        EquationStore.sharedStore.convertDeprecatedEquationsIfNeeded()
        
        PremiumCoordinator.shared.setupManager()
//        PremiumCoordinator.shared.updateProductsIfNeeded()
//        PremiumCoordinator.shared.validateReceipt()
//        PremiumCoordinator.shared.updatePremiumStatusFromValidatedJSON()
        
        FIRApp.configure()
        GADMobileAds.configure(withApplicationID: "ca-app-pub-3940256099942544~1458002511")
        
        DispatchQueue.main.async {
            SoundManager.primeSounds()
        }
        
//        Timer.scheduledTimer(withTimeInterval: 10.0, repea`ts: true) { (timer) in
//            PremiumCoordinator.shared.premiumIAPUser = true
//            PremiumCoordinator.shared.postUserPremiumStatusChanged()
//            ThemeCoordinator.shared.changeTheme()
//        }
        
        Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { (timer) in
            print(UIMenuController.shared.menuItems)
        }
        
//        UIUserNotificationSettings *notificationSettings = [UIUserNotificationSettings settingsForTypes:UIUserNotificationTypeAlert categories:nil];
//        [application registerUserNotificationSettings:notificationSettings];
//        [application registerForRemoteNotifications];
        
//        let settings = UIUserNotificationSettings(types: [.alert,  , categories: )
        
        
//        print(NumericalHelper.convertOut(color: NumericalHelper.convertIn(number1: 0.0, number2: 0.5, isSecondColor: false, isLightStyle: false), isSecondColor: false, isLightStyle: false))
        print(NumericalHelper.convertOut(color: NumericalHelper.convertIn(number1: 0.0, number2: 0.6, isSecondColor: false, isLightStyle: false), isSecondColor: false, isLightStyle: false))
//        print(NumericalHelper.convertOut(color: NumericalHelper.convertIn(number1: 0.0, number2: 0.7, isSecondColor: false, isLightStyle: false), isSecondColor: false, isLightStyle: false))
//        print(NumericalHelper.convertOut(color: NumericalHelper.convertIn(number1: 0.0, number2: 0.8, isSecondColor: false, isLightStyle: false), isSecondColor: false, isLightStyle: false))
//        print(NumericalHelper.convertOut(color: NumericalHelper.convertIn(number1: 0.0, number2: 1.0, isSecondColor: false, isLightStyle: false), isSecondColor: false, isLightStyle: false))
        
        print("")
        UNUserNotificationCenter.current().requestAuthorization(options:
            [[.alert, .sound, .badge]],
                                                                completionHandler: { (granted, error) in
                                                                    // Handle Error
        })
        
        application.registerForRemoteNotifications()
        
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

