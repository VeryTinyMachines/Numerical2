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

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
//        WatchCommunicator.sharedCommunicator.setup()
        
        print(PremiumCoordinator.shared.themes)
        
        EquationStore.sharedStore.saveContext()
        
        PremiumCoordinator.shared.setupManager()
//        PremiumCoordinator.shared.updateProductsIfNeeded()
//        PremiumCoordinator.shared.validateReceipt()
//        PremiumCoordinator.shared.updatePremiumStatusFromValidatedJSON()
        
        FIRApp.configure()
        GADMobileAds.configure(withApplicationID: "ca-app-pub-3940256099942544~1458002511")
        
        DispatchQueue.main.async {
            SoundManager.primeSounds()
        }
        
//        Timer.scheduledTimer(withTimeInterval: 3.0, repeats: true) { (timer) in
//            PremiumCoordinator.shared.premiumIAPUser = !PremiumCoordinator.shared.premiumIAPUser
//            NotificationCenter.default.post(name: Notification.Name(rawValue: PremiumCoordinatorNotification.premiumStatusChanged), object: nil)
//        }
        
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
     
        EquationStore.sharedStore.cloudFetchLatestEquations()
        EquationStore.sharedStore.queueCloudKitNeedsUpdate()
        EquationStore.sharedStore.refreshiCloudStatusCheck()
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    


}

