//
//  StoreKitWrapper.swift
//  Numerical2
//
//  Created by Kevin Enax on 10/11/15.
//  Copyright © 2015 Very Tiny Machines. All rights reserved.
//

import UIKit

let ProductPurchaseSuccessNotificationName            = "ProductPurchaseSuccess"
let ProductPurchaseFailureNotificationName            = "ProductPurchaseFailure"
let ProductPurchaseRestorationSuccessNotificationName = "ProductPurchaseRestorationSuccess"
let ProductPurchaseRestorationFailureNotificationName = "ProductPurchaseRestorationFailure"

class StoreKitWrapper {
    
    init() {
        RMStore.default().transactionPersistor = SinkableUserDefaults.standardUserDefaults
    }
    
    func purchaseProductWithID(_ id:String) {
        RMStore.default().addPayment(id, success: { (transaction) -> Void in
            RMStore.default().transactionPersistor?.persistTransaction(transaction)
            NotificationCenter.default.post(Notification(name: Notification.Name(rawValue: ProductPurchaseSuccessNotificationName), object: id))
            }) { (transaction, error) -> Void in NotificationCenter.default.post(Notification(name: Notification.Name(rawValue: ProductPurchaseFailureNotificationName), object: error)) }
    }
    
    func isPurchased(_ id:String) -> Bool {
        if let transactionPersistor = RMStore.default().transactionPersistor as! SinkableUserDefaults? {
            return transactionPersistor.isProducPurchasedWithID(id)
        }
        return false
    }
    
    func restorePurchases() {
        RMStore.default().restoreTransactions(onSuccess: { (transactions) -> Void in
            for transaction:SKPaymentTransaction in transactions as! [SKPaymentTransaction] {
                RMStore.default().transactionPersistor?.persistTransaction(transaction)
              NotificationCenter.default.post(Notification(name: Notification.Name(rawValue: ProductPurchaseRestorationSuccessNotificationName), object: transaction.transactionIdentifier))
            }
            }) { (error) -> Void in
                NotificationCenter.default.post(Notification(name: Notification.Name(rawValue: ProductPurchaseRestorationFailureNotificationName), object: error))
        }
    }

}
