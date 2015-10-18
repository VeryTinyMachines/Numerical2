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
        RMStore.defaultStore().transactionPersistor = SinkableUserDefaults.standardUserDefaults
    }
    
    func purchaseProductWithID(id:String) {
        RMStore.defaultStore().addPayment(id, success: { (transaction) -> Void in
            RMStore.defaultStore().transactionPersistor?.persistTransaction(transaction)
            NSNotificationCenter.defaultCenter().postNotification(NSNotification(name: ProductPurchaseSuccessNotificationName, object: id))
            }) { (transaction, error) -> Void in NSNotificationCenter.defaultCenter().postNotification(NSNotification(name: ProductPurchaseFailureNotificationName, object: error)) }
    }
    
    func isPurchased(id:String) -> Bool {
        if let transactionPersistor = RMStore.defaultStore().transactionPersistor as! SinkableUserDefaults? {
            return transactionPersistor.isProducPurchasedWithID(id)
        }
        return false
    }
    
    func restorePurchases() {
        RMStore.defaultStore().restoreTransactionsOnSuccess({ (transactions) -> Void in
            for transaction:SKPaymentTransaction in transactions as! [SKPaymentTransaction] {
                RMStore.defaultStore().transactionPersistor?.persistTransaction(transaction)
              NSNotificationCenter.defaultCenter().postNotification(NSNotification(name: ProductPurchaseRestorationSuccessNotificationName, object: transaction.transactionIdentifier))
            }
            }) { (error) -> Void in
                NSNotificationCenter.defaultCenter().postNotification(NSNotification(name: ProductPurchaseRestorationFailureNotificationName, object: error))
        }
    }

}
