//
//  SalesViewController.swift
//  Numerical2
//
//  Created by Andrew Clark on 6/10/2016.
//  Copyright © 2016 Very Tiny Machines. All rights reserved.
//

import UIKit

class SalesViewController: NumericalViewController {
    
    @IBOutlet weak var beginPurchaseButton: UIButton!
    
    @IBOutlet weak var beginRestoreButton: UIButton!
    
    @IBOutlet weak var privacyButton: UIButton!
    
//    @IBOutlet weak var mainLabel: UILabel!
    @IBOutlet weak var horizontalLabel: UILabel!
    
    @IBOutlet weak var portraitLabel: UILabel!
    
    @IBOutlet weak var horizontalSalesView: UIView!
    
    @IBOutlet weak var portraitSalesView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(SalesViewController.restoreSuccess), name: Notification.Name(rawValue: PremiumCoordinatorNotification.restoreCompleted), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(SalesViewController.restoreFailed), name: Notification.Name(rawValue: PremiumCoordinatorNotification.restoreFailed), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(SalesViewController.purchaseSuccess), name: Notification.Name(rawValue: PremiumCoordinatorNotification.purchaseCompleted), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(SalesViewController.purchaseFailed), name: Notification.Name(rawValue: PremiumCoordinatorNotification.purchaseFailed), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(SalesViewController.updateView), name: Notification.Name(rawValue: PremiumCoordinatorNotification.premiumStatusChanged), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(SalesViewController.updateView), name: Notification.Name(rawValue: PremiumCoordinatorNotification.productsChanged), object: nil)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateView()
        PremiumCoordinator.shared.updateProductsIfNeeded()
        
        updateSalesView()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        PremiumCoordinator.shared.updateProductsIfNeeded()
    }
    
    @IBAction func pressCloseButton(_ sender: UIButton) {
        dismiss(animated: true) { 
            
        }
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return UIStatusBarStyle.lightContent
    }
    
    func updateView() {
        var price = "..."
        
        if let monthlyPlan = PremiumCoordinator.shared.productMonthlySubscription {
            price = PremiumCoordinator.shared.priceForProduct(product: monthlyPlan)
        }
        
        if PremiumCoordinator.shared.isUserPremium() {
            
            var string = "Thanks for being a Numerical Supporter! This is a total passion project so your support helps us keep working on it and adding new features. Seriously, you're a gem <3\n"
            
            if let expiryDate = PremiumCoordinator.shared.expiryDate() {
                
                let dateFormatter = DateFormatter()
                dateFormatter.timeStyle = .short
                dateFormatter.dateStyle = .medium
                dateFormatter.timeZone = TimeZone.current
                
                let dateString = dateFormatter.string(from: expiryDate)
                
                if expiryDate.timeIntervalSinceNow < 0 {
                    string += "\n\nYour subscription expired on\n\(dateString)"
                } else {
                    string += "\n\nYour subscription renews (or expires) on\n\(dateString)"
                }
            }
            
            horizontalLabel.text = string
            portraitLabel.text = string
            
            beginPurchaseButton.isHidden = true
            beginRestoreButton.isHidden = false
            privacyButton.isHidden = false
            
            beginRestoreButton.setTitle("Manage Subscription", for: UIControlState.normal)
        } else {
            
            let string = "Become a Numerical Supporter for \(price) per month and keep the calculator without equal alive! This is a total passion project so your support is what lets us keep working on it and adding new features. <3\n\nSubscription automatically renews unless auto-renew is turned off at least 24-hours before the end of the current period."
            
            horizontalLabel.text = string
            portraitLabel.text = string
            
            beginPurchaseButton.isHidden = false
            beginRestoreButton.isHidden = false
            privacyButton.isHidden = false
            
            beginRestoreButton.setTitle("Manage", for: UIControlState.normal)
            
            if let _ = PremiumCoordinator.shared.expiryDate() {
                beginPurchaseButton.setTitle("Continue Subscription", for: UIControlState.normal)
            } else {
                beginPurchaseButton.setTitle("Start Subscription", for: UIControlState.normal)
            }
        }
    }
    
    @IBAction func userPressedPurchaseButton(_ sender: UIButton) {
        if PremiumCoordinator.shared.purchaseSubscription() {
            beginLoadingScreen()
        } else {
            // We can't start this purchase just yet
        }
    }
    
    @IBAction func userPressedRestoreButton(_ sender: UIButton) {
        
        // Show menu with Restore and Manage subscription
        
        
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: UIAlertControllerStyle.actionSheet)
        
        
        alert.addAction(UIAlertAction(title: "Manage Subscription", style: UIAlertActionStyle.default, handler: { (action) in
            // User is alreayd premium, offer to manage subscription
            self.presentiTunesManage()
        }))
        
        alert.addAction(UIAlertAction(title: "Restore", style: UIAlertActionStyle.default, handler: { (action) in
            if PremiumCoordinator.shared.restoreProducts() {
                self.beginLoadingScreen()
            }
        }))
        
        alert.addAction(UIAlertAction(title: "Contact Support", style: UIAlertActionStyle.default, handler: { (action) in
            self.email(emailAddress: "verytinymachines@gmail.com", subject: "Subscription Issues", message: "I'm having an issue with my Numerical² subscription and that issue is...")
        }))
        
        alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: { (action) in
            
        }))
        
        alert.popoverPresentationController?.sourceView = self.view
        
        self.present(alert, animated: true) { 
            
        }
    }
    
    @IBAction func userPressedPrivacy(_ sender: UIButton) {
        
        let url = URL(string: "https://kat-elsby.squarespace.com/numericalprivacy")!
        
        if UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url)
        }
        
    }
    
    
    
    func restoreFailed() {
        endLoadingScreen()
        updateView()
    }
    
    func restoreSuccess() {
        endLoadingScreen()
        updateView()
    }
    
    func purchaseFailed() {
        endLoadingScreen()
        updateView()
    }
    
    func purchaseSuccess() {
        endLoadingScreen()
        updateView()
    }
    
    func updateSalesView() {
        if viewNeedsHorizontalSales() {
            horizontalSalesView.isHidden = false
            portraitSalesView.isHidden = true
        } else {
            horizontalSalesView.isHidden = true
            portraitSalesView.isHidden = false
        }
    }
    
    func viewNeedsHorizontalSales() -> Bool {
        
        if NumericalViewHelper.isDevicePad() {
            // It's an iPad!
            return false
        } else {
            // It's an iPhone
            
            if self.view.bounds.width > self.view.bounds.height && self.view.bounds.width > 450 {
                // This view is wider than it is tall, so we should
                return true
            } else {
                return false
            }
        }
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        
        let duration = coordinator.transitionDuration
        
        UIView.animate(withDuration: duration / 2, animations: { () -> Void in
            self.horizontalSalesView.alpha = 0.0
            self.portraitSalesView.alpha = 0.0
            
        }, completion: { (complete) -> Void in
            
            self.updateSalesView()
            
            UIView.animate(withDuration: duration / 2, animations: { () -> Void in
                self.horizontalSalesView.alpha = 1.0
                self.portraitSalesView.alpha = 1.0
            }, completion: { (complete) -> Void in
                
            })
        })
    }
    
}
