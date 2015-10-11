//
//  StoreKitWrapper.swift
//  Numerical2
//
//  Created by Kevin Enax on 10/11/15.
//  Copyright © 2015 Very Tiny Machines. All rights reserved.
//

import UIKit

class StoreKitWrapper {
    
    init() {
        RMStore.defaultStore().transactionPersistor = RMStoreKeychainPersistence()
    }
    
    func purchaseProductWithID(id:String) {
        RMStore.defaultStore().addPayment(id, success: { (transaction) -> Void in
            RMStore.defaultStore().transactionPersistor?.persistTransaction(transaction)
            NSNotificationCenter.defaultCenter().postNotification(NSNotification(name: "ProductPurchaseSuccess", object: id))
            }) { (transaction, error) -> Void in NSNotificationCenter.defaultCenter().postNotification(NSNotification(name: "ProductPurchaseFailure", object: error)) }
    }
    
    func isPurchased(id:String) -> Bool {
        if let transactionPersistor = RMStore.defaultStore().transactionPersistor as! RMStoreKeychainPersistence? {
            return transactionPersistor.isPurchasedProductOfIdentifier(id)
        }
        return false
    }
    
    func restorePurchases() {
        RMStore.defaultStore().restoreTransactionsOnSuccess({ (transactions) -> Void in
            for transaction:SKPaymentTransaction in transactions as! [SKPaymentTransaction] {
                RMStore.defaultStore().transactionPersistor?.persistTransaction(transaction)
              NSNotificationCenter.defaultCenter().postNotification(NSNotification(name: "ProductPurchaseRestorationSuccess", object: transaction.transactionIdentifier))
            }
            }) { (error) -> Void in
                NSNotificationCenter.defaultCenter().postNotification(NSNotification(name: "ProductPurchaseRestorationFailure", object: error))
        }
    }

}
