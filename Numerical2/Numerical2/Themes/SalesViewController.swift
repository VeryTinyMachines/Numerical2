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
            
            var string = "Thanks for being a Numerical Pro subscriber! You now have access to all the fancy scientific keys, can create your own themes, ads are removed, and you're supporting the ongoing development of Numerical!"
            
            if let expiryDate = PremiumCoordinator.shared.expiryDate() {
                
                let dateFormatter = DateFormatter()
                dateFormatter.timeStyle = .short
                dateFormatter.dateStyle = .medium
                dateFormatter.timeZone = TimeZone.current
                
                let dateString = dateFormatter.string(from: expiryDate)
                
                if expiryDate.timeIntervalSinceNow < 0 {
                    string += "\n\nYour subscription expired on\n\(dateString)"
                } else {
                    string += "\n\nYour subscription renews/expires on\n\(dateString)"
                }
            }
            
            horizontalLabel.text = string
            portraitLabel.text = string
            
            beginPurchaseButton.isHidden = true
            beginRestoreButton.isHidden = false
            
            beginRestoreButton.setTitle("Manage Subscription", for: UIControlState.normal)
        } else {
            
            
            let string = "Become a pro subscriber for \(price) p/month to remove ads, use all the fancy scientific keys, create your own themes, and support the ongoing development of Numerical."
            
            horizontalLabel.text = string
            portraitLabel.text = string
            
            beginPurchaseButton.isHidden = false
            beginRestoreButton.isHidden = false
            
            beginRestoreButton.setTitle("Restore", for: UIControlState.normal)
            
            if let _ = PremiumCoordinator.shared.expiryDate() {
                beginPurchaseButton.setTitle("Continue Subscription", for: UIControlState.normal)
            } else {
                beginPurchaseButton.setTitle("Start Free Trial", for: UIControlState.normal)
            }
            
        }
        
        // Setup the buttons
    }
    
    @IBAction func userPressedPurchaseButton(_ sender: UIButton) {
        if PremiumCoordinator.shared.purchaseSubscription() {
            beginLoadingScreen()
        } else {
            // We can't start this purchase just yet
        }
    }
    
    @IBAction func userPressedRestoreButton(_ sender: UIButton) {
        
        if PremiumCoordinator.shared.isUserPremium() {
            // User is alreayd premium, offer to manage subscription
            self.presentiTunesManage()
        } else {
            if PremiumCoordinator.shared.restoreProducts() {
                beginLoadingScreen()
            } else {
                // We can't start this restore
            }
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
        
        if NumericalHelper.isDevicePad() {
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
