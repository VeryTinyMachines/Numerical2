//
//  NumericalTheme.swift
//  Numerical2
//
//  Created by Andrew J Clark on 24/09/2016.
//  Copyright © 2016 Very Tiny Machines. All rights reserved.
//

import UIKit
import CloudKit
import StoreKit

public struct PremiumCoordinatorNotification {
    public static let themeChanged = "PremiumCoordinatorNotification.themeChanged"
    public static let productsChanged = "PremiumCoordinatorNotification.productsChanged"
    public static let restoreCompleted = "PremiumCoordinatorNotification.restoreCompleted"
    public static let restoreFailed = "PremiumCoordinatorNotification.restoreFailed"
    
    public static let purchaseCompleted = "PremiumCoordinatorNotification.purchaseCompleted"
    public static let purchaseFailed = "PremiumCoordinatorNotification.purchaseFailed"
    
    public static let premiumStatusChanged = "PremiumCoordinatorNotification.premiumStatusChanged"
}

class PremiumCoordinator: NSObject, SKProductsRequestDelegate, SKPaymentTransactionObserver {
    
    static let shared = PremiumCoordinator()
    
    lazy var legacyThemeUser: Bool = {
        return UserDefaults.standard.bool(forKey: "ThemePack001")
    } ()
    
    var premiumIAPUser:Bool = false
    
    var productLegacyTheme:SKProduct?
    var productMonthlySubscription:SKProduct?
    
    var isRestoring = false
    var isPurchasing = false
    
    var preventAd = false
    
    private override init() {}
    
    func setupManager() {
        SKPaymentQueue.default().add(self)
        updateProductsIfNeeded()
        updatePremiumStatusFromValidatedJSON()
        validateReceipt(sandbox: false)
    }
    
    func themePackPurchased() -> Bool {
        if let themePackString = UserDefaults.standard.object(forKey: "ThemePack001") as? String {
            if themePackString == "YES" {
                return true
            }
        }
        
        return false
    }
    
    func imageForTheme(string: String) -> UIImage? {
        
        if let image = UIImage(named: string + "@2x.jpg") {
            return image
        } else {
            return nil
        }
    }
    
    func thumbnailImageForTheme(string: String) -> UIImage? {
        if let image = UIImage(named: string + "-thumbnail@2x.jpg") {
            return image
        } else {
            return nil
        }
    }
    
    func setTheme(string: String?) {
        if let string = string {
            UserDefaults.standard.set(string, forKey: "CurrentTheme")
        } else {
            UserDefaults.standard.removeObject(forKey: "CurrentTheme")
        }
        
        UserDefaults.standard.synchronize()
        
        DispatchQueue.main.async {
            NotificationCenter.default.post(name: Notification.Name(rawValue: PremiumCoordinatorNotification.themeChanged), object: nil)
        }
    }
    
    func updateProductsIfNeeded() {
        if productMonthlySubscription == nil || productLegacyTheme == nil {
            // let productRequest = SKProductsRequest(productIdentifiers: ["com.numericalapp.themepack001", "com.numericalapp.supporter_monthly"])
            let productRequest = SKProductsRequest(productIdentifiers: ["com.numericalapp.supporter_monthly"])
            productRequest.delegate = self
            productRequest.start()
        }
    }
    
    func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        if response.products.count > 0 {
            for product in response.products {
                if product.productIdentifier == "com.numericalapp.themepack001" {
                    productLegacyTheme = product
                } else if product.productIdentifier == "com.numericalapp.supporter_monthly" {
                    productMonthlySubscription = product
                }
            }
        }
        
        if productMonthlySubscription != nil && productLegacyTheme != nil {
            NotificationCenter.default.post(name: Notification.Name(rawValue: PremiumCoordinatorNotification.productsChanged), object: nil)
        }
    }
    
    
    func purchaseSubscription() -> Bool {
        if !isPurchasing {
            if let product = productMonthlySubscription {
                let payment = SKPayment(product: product)
                
                SKPaymentQueue.default().add(payment)
                isPurchasing = true
                return true
            }
        }
        
        return false
    }
    
    func restoreProducts() -> Bool {
        if !isRestoring {
            SKPaymentQueue.default().restoreCompletedTransactions()
            isRestoring = true
            return true
        }
        
        return false
    }
    
    
    func paymentQueue(_ queue: SKPaymentQueue, restoreCompletedTransactionsFailedWithError error: Error) {
        restoreCompleted(success: false)
    }
    
    func paymentQueueRestoreCompletedTransactionsFinished(_ queue: SKPaymentQueue) {
        
    }
    
    func paymentQueue(_ queue: SKPaymentQueue, removedTransactions transactions: [SKPaymentTransaction]) {
        
    }
    
    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        print("paymentQueue")
        print(transactions)
        
        var purchasesComplete = false
        var restoresComplete = false
        
        for transaction in transactions {
            switch transaction.transactionState {
            case .deferred:
                finishTransaction(transaction: transaction)
            case .failed:
                finishTransaction(transaction: transaction)
                if isRestoring {
                    restoreCompleted(success: false)
                }
                
                if isPurchasing {
                    purchaseCompleted(success: false)
                }
            case .purchased:
                finishTransaction(transaction: transaction)
                purchasesComplete = true
            case .purchasing:
                break
            case .restored:
                finishTransaction(transaction: transaction)
                restoresComplete = true
            }
        }
        
        if restoresComplete {
            restoreCompleted(success: true)
        }
        
        if purchasesComplete {
            purchaseCompleted(success: true)
        }
    }
    
    func finishTransaction(transaction: SKPaymentTransaction) {
        SKPaymentQueue.default().finishTransaction(transaction)
    }
    
    func restoreCompleted(success: Bool) {
        print("restoreCompleted")
        
        if success {
            validateReceipt(sandbox: false)
        } else {
            NotificationCenter.default.post(name: Notification.Name(rawValue: PremiumCoordinatorNotification.restoreFailed), object: nil)
            notifyUser(title: "Error", message: "Restore failed")
            isRestoring = false
        }
    }
    
    
    func purchaseCompleted(success: Bool) {
        print("purchaseCompleted")
        
        if success {
            validateReceipt(sandbox: false)
        } else {
            NotificationCenter.default.post(name: Notification.Name(rawValue: PremiumCoordinatorNotification.purchaseFailed), object: nil)
            notifyUser(title: "Error", message: "Purchase failed")
            isPurchasing = false
        }
    }
    
    func deferred() {
        
        notifyUser(title: "Purchase Deferred", message: "Could not complete purchase at this time as your account is not permitted to make purchases")
        
        if isPurchasing {
            NotificationCenter.default.post(name: Notification.Name(rawValue: PremiumCoordinatorNotification.purchaseFailed), object: nil)
        }
        
        if isRestoring {
            NotificationCenter.default.post(name: Notification.Name(rawValue: PremiumCoordinatorNotification.restoreFailed), object: nil)
        }
    }
    
    
    func validateReceipt(sandbox: Bool) {
        
        if let receiptUrl = Bundle.main.appStoreReceiptURL {
            
            do {
                let receipt: NSData = try NSData(contentsOf: receiptUrl, options: NSData.ReadingOptions.mappedIfSafe)
                
                let receiptString: NSString = receipt.base64EncodedString(options: NSData.Base64EncodingOptions(rawValue: 0)) as NSString
                
                print("receiptString: \(receiptString)")
                
                var request = URLRequest(url: URL(string: "https://buy.itunes.apple.com/verifyReceipt")!)
                
                if sandbox {
                    request = URLRequest(url: URL(string: "https://sandbox.itunes.apple.com/verifyReceipt")!)
                }
                
                let requestContents = ["receipt-data":receiptString, "password":"e5541345c1854e2f8a2f6fde484ac6cb"]
                request.httpBody = try! JSONSerialization.data(withJSONObject: requestContents, options: [])
                request.httpMethod = "POST"
                
                let task = URLSession.shared.dataTask(with: request, completionHandler: { (data, response, error) in
                    
                    if let data = data {
                        
                        // Check the status from this data
                        if let status = self.statusFromValidatedData(data: data) {
                            
                            
                            if status == 0 {
                                // valid!
                                // Save this JSON data locally
                                self.saveValidatedJSON(data: data)
                                
                                // Now check if this JSON now contains a premium subscription
                                self.updatePremiumStatusFromValidatedJSON()
                                
                                self.postCompletionNotificationsAndReset(success: true)
                            } else {
                                
                                if status == 21000 {
                                    // The App Store could not read the JSON object you provided.
                                    self.notifyUser(title: "Error 21000", message: "The App Store could not read the JSON object you provided.")
                                } else if status == 21002 {
                                    // The data in the receipt-data property was malformed or missing.
                                    self.notifyUser(title: "Error 21002", message: "The data in the receipt-data property was malformed or missing.")
                                } else if status == 21003 {
                                    // The receipt could not be authenticated.
                                    self.notifyUser(title: "Error 21003", message: "The receipt could not be authenticated.")
                                } else if status == 21004 {
                                    // The shared secret you provided does not match the shared secret on file for your account.
                                    self.notifyUser(title: "Error 21004", message: "The shared secret you provided does not match the shared secret on file for your account.")
                                } else if status == 21005 {
                                    // The receipt server is not currently available.
                                    self.notifyUser(title: "Error 21005", message: "The receipt server is not currently available.")
                                } else if status == 21007 {
                                    // This receipt is from the test environment, but it was sent to the production environment for verification. Send it to the test environment instead.
                                    self.validateReceipt(sandbox: true)
                                    return
                                } else if status == 21008 {
                                    // This receipt is from the production environment, but it was sent to the test environment for verification. Send it to the production environment instead.
                                    self.notifyUser(title: "Error 21008", message: "This receipt is from the production environment, but it was sent to the test environment for verification. Send it to the production environment instead.")
                                }
                            }
                        }
                    }
                    
                    self.postCompletionNotificationsAndReset(success: false)
                })
                
                task.resume()
                
            } catch {
                self.postCompletionNotificationsAndReset(success: false)
            }
        } else {
            self.postCompletionNotificationsAndReset(success: false)
        }
    }
    
    func postStatusErrorIfNeeded(status: Int, message: String?) {
        
    }
    
    func postCompletionNotificationsAndReset(success: Bool) {
        
        DispatchQueue.main.async {
            if self.isRestoring {
                self.isRestoring = false
                
                if success {
                    
                    if let _ = self.expiryDate() {
                        if self.isUserPremium() {
                            // Restored and premium
                            self.notifyUser(title: "Subscription Restored", message: "Thanks for supporting Numerical!")
                        } else {
                            // Restored but still not premium
                            self.notifyUser(title: "Subscription Expired", message: "Your subscription has been restored but it looks like it has expired. Please continue your Subscription for lots of good karma!")
                        }
                    } else {
                        // No expiry date
                        
                        if self.legacyThemeUser {
                            self.notifyUser(title: "Theme Pack Restored", message: "Your theme pack has been restored but you if you'd like to become a Numerical Supporter you'll need to start a subscription.")
                        } else {
                            self.notifyUser(title: nil, message: "Nothing to restore. Perhaps you are signed in with a different App Store account?")
                        }
                    }
                    
                    NotificationCenter.default.post(name: Notification.Name(rawValue: PremiumCoordinatorNotification.restoreCompleted), object: nil)
                } else {
                    NotificationCenter.default.post(name: Notification.Name(rawValue: PremiumCoordinatorNotification.restoreFailed), object: nil)
                }
            }
            
            if self.isPurchasing {
                self.isPurchasing = false
                
                if success {
                    NotificationCenter.default.post(name: Notification.Name(rawValue: PremiumCoordinatorNotification.purchaseCompleted), object: nil)
                } else {
                    NotificationCenter.default.post(name: Notification.Name(rawValue: PremiumCoordinatorNotification.purchaseFailed), object: nil)
                }
            }
        }
    }
    
    func saveValidatedJSON(data: Data) {
        
        do {
            let fileLocation = URL(fileURLWithPath: validatedJSONLocation())
            try data.write(to: fileLocation)
        } catch {
            print("Could not write")
        }
    }
    
    func updatePremiumStatusFromValidatedJSON() {
        // Load the local JSON
        // Check the dates, update the states, post it
        if let json = jsonFromValidatedData() {
            
//            print(json)
            
            let formatter = NumberFormatter()
            
            var furthestDate:Date? = UserDefaults.standard.object(forKey: "ProModeExpirationDate") as? Date
            
            // Check if themepack is available
            
            if let receiptDict = json["receipt"] as? [String: AnyObject] {
                if let inAppDict = receiptDict["in_app"] as? [[String: AnyObject]] {
                    
                    for purchaseDict in inAppDict {
                        if let productID = purchaseDict["product_id"] as? String {
                            if productID == "com.numericalapp.themepack001" {
                                UserDefaults.standard.set(true, forKey: "ThemePack001")
                                legacyThemeUser = true
                            } else {
                                if let expiryDateString = purchaseDict["expires_date_ms"] as? String {
                                    if let number = formatter.number(from: expiryDateString) {
                                        let newDate = Date(timeIntervalSince1970: TimeInterval(number.intValue / 1000))
                                        if let compareDate = furthestDate {
                                            if newDate > compareDate {
                                                // This newDate is further in the future than compare date, replace it!
                                                furthestDate = newDate
                                            }
                                        } else {
                                            furthestDate = newDate
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
            
            // Check the latest expiry date from subscriptions
            if let furthestDate = furthestDate {
                UserDefaults.standard.set(furthestDate, forKey: "ProModeExpirationDate")
                UserDefaults.standard.synchronize()
                
                // We have a new furthestDate from the receipt (but it wasn't saved in UserDefaults) so we should sync this with CK
                self.syncExpiryDate()
            }
        } else {
            // Could not load local validate data for some reason.
        }
        
        self.updatePremiumIAPUserFromUserDefaults()
    }
    
    func updatePremiumIAPUserFromUserDefaults() {
        // Now look at the expiry date in NSUserDefaults and determine if it is
        
        let previousIAPState = premiumIAPUser
        
        if let expiryDate = UserDefaults.standard.object(forKey: "ProModeExpirationDate") as? Date {
            
            if expiryDate.timeIntervalSinceNow > 0 {
                // This date is in the future
                premiumIAPUser = true
            } else {
                // This date is negative and in the past
                premiumIAPUser = false
            }
        }
        
        
        if previousIAPState != premiumIAPUser {
            self.postUserPremiumStatusChanged()
        }
    }
    
    func postUserPremiumStatusChanged() {
        DispatchQueue.main.async {
            // Post that the user status has changed
            NotificationCenter.default.post(name: Notification.Name(rawValue: PremiumCoordinatorNotification.premiumStatusChanged), object: nil)
        }
    }
    
    func jsonFromValidatedData() -> [String: AnyObject]? {
    
        let url = URL(fileURLWithPath: validatedJSONLocation())
        
        do {
            let data = try Data(contentsOf: url)
            
            return jsonFromValidatedData(data: data)
        } catch {
            //print("Error: Could not load local validated json")
        }
        
        return nil
    }
    
    func jsonFromValidatedData(data: Data) -> [String: AnyObject]? {
        
        do {
            // Try and make this into JSON
            let json = try JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.mutableLeaves)
            
            if let jsonObj = json as? [String: AnyObject] {
                return jsonObj
            }
            
        } catch {
            //print("Error: Could not load local validated json")
        }
        
        return nil
    }
    
    func statusFromValidatedData(data: Data) -> Int? {
        
        if let jsonDict = self.jsonFromValidatedData(data: data) {
            print(jsonDict)
            if let status = jsonDict["status"] as? NSNumber {
                return status.intValue
            }
        }
        
        return nil
    }
    
    func validatedJSONLocation() -> String {
        return applicationSupport() + "JSONData"
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
    
    
    func canAccessThemes() -> Bool {
        return true
        
        if isUserPremium() || isUserInTrial() || self.legacyThemeUser {
            return true
        }
        return false
    }
    
    func canEditThemes() -> Bool {
        return true
        if isUserPremium() || isUserInTrial() {
            return true
        }
        return false
    }
    
    func isUserPremium() ->Bool {
        if premiumIAPUser {
            // User is paying via an IAP, user is premium
            return true
        }
        return false
    }
    
    func isUserInTrial() -> Bool {
        return false
    }
    
    func shouldUserSeeAd() -> Bool {
        
        return false // we're not going to show ads.
        
        if isUserPremium() {
            return false
        }
        
        return true
    }
    
    func expiryDate() -> Date? {
        
        if let expiryDate = UserDefaults.standard.object(forKey: "ProModeExpirationDate") as? Date {
            return expiryDate
        }
        
        return nil
    }
    
    func canUserAccessKey(character: Character) -> Bool {
        return true // any user can access all keys
        
        if isKeyPremium(character: character) {
            if isUserPremium() || isUserInTrial() {
                return true
            } else {
                return false
            }
         } else {
            // Normal key - user can access
            return true
        }
    }
    
    private func isKeyPremium(character: Character) -> Bool {
        return false // no more premium keys
        
        if SymbolCharacter.premiumOperators.contains(character) {
            // User is not premium and this is a premium operator.
            return true
        }
        
        return false
    }
    
    
    
    
    func keyStyleFor(character: Character) -> KeyStyle? {
        if isKeyPremium(character: character) {
            // This key is usually premium, determine what kind of style is required.
            if isUserPremium() {
                // This user is premium and can access everything.
                return KeyStyle.Available
            } else if isUserInTrial() {
                // This user isn't premium but they are in a trial.
                return KeyStyle.AvailablePremium
            } else {
                // This is a non premium, non trial user, they cannot access this key.
                return KeyStyle.PremiumRequired
            }
        } else {
            // This is a normal key
            return KeyStyle.Available
        }
    }
    
    func priceForProduct(product: SKProduct) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.locale = product.priceLocale
        return formatter.string(from: product.price)!
    }
    
    
    func notifyUser(title: String?, message: String?) {
        DispatchQueue.main.async {
            let alert = UIAlertView(title: title, message: message, delegate: nil, cancelButtonTitle: "Ok")
            alert.show()
        }
    }
    
    
    func syncExpiryDate() {
        
        let localExpiryDate:Date? = UserDefaults.standard.object(forKey: "ProModeExpirationDate") as? Date
        
        let cloudExpiryDate:Date? = NSUbiquitousKeyValueStore.default().object(forKey: "ProModeExpirationDate") as? Date
        
        var newLocalExpiryDate:Date? = nil
        var newCloudExpiryDate:Date? = nil
        
        if let localExpiryDate = localExpiryDate {
            // We have a local date, check if we have a cloud date
            if let cloudExpiryDate = cloudExpiryDate {
                // Compare them and update the relevant date.
                
                if localExpiryDate > cloudExpiryDate {
                    // Local date is better, update the cloud
                    newCloudExpiryDate = localExpiryDate
                } else if cloudExpiryDate > localExpiryDate {
                    // Save this cloudexpirydate
                    newLocalExpiryDate = cloudExpiryDate
                }
                
            } else {
                // No cloud date, time to update the cloud
                newCloudExpiryDate = localExpiryDate
            }
        } else {
            // No local expiry date, check cloud
            if let cloudExpiryDate = cloudExpiryDate {
                // Save this locally
                print("")
                newLocalExpiryDate = cloudExpiryDate
            }
        }
        
        if let newCloudExpiryDate = newCloudExpiryDate {
            print("newCloudExpiryDate that needs KVS syncing:\(newCloudExpiryDate)")
            
            NSUbiquitousKeyValueStore.default().set(newCloudExpiryDate, forKey: "ProModeExpirationDate")
            NSUbiquitousKeyValueStore.default().synchronize()
        }
        
        if let newLocalExpiryDate = newLocalExpiryDate {
            print("newLocalExpiryDate that needs local saving:\(newLocalExpiryDate)")
            
            UserDefaults.standard.set(newLocalExpiryDate, forKey: "ProModeExpirationDate")
            UserDefaults.standard.synchronize()
            
            self.updatePremiumIAPUserFromUserDefaults()
        }
        
    }
    
    func saveRecord(record: CKRecord) {
        CKContainer.default().privateCloudDatabase.save(record) { (record, error) in
            print("record: \(record)")
            print("error: \(error)")
        }
    }
}

