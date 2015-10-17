//
//  ExtensionDelegate.swift
//  Numerical2-Watch Extension
//
//  Created by Kevin Enax on 10/8/15.
//  Copyright © 2015 Very Tiny Machines. All rights reserved.
//

import WatchKit

let AppGroupId = "group.andrewjclark.numericalapp"

class ExtensionDelegate: NSObject, WKExtensionDelegate {

    func applicationDidFinishLaunching() {
        SinkableUserDefaults.standardUserDefaults.appGroupID = AppGroupId
        if let equationStore = WatchEquation.equationStore() {
            do { try NSFileManager.defaultManager().createDirectoryAtPath(equationStore, withIntermediateDirectories: false, attributes: nil) } catch _ {}
        }
    }

    func applicationDidBecomeActive() {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillResignActive() {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, etc.
    }

}


func sharedContainer() -> NSURL? { return NSFileManager.defaultManager().containerURLForSecurityApplicationGroupIdentifier(AppGroupId) }