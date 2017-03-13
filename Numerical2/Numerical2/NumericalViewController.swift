//
//  NumericalViewController.swift
//  Numerical2
//
//  Created by Andrew J Clark on 24/09/2016.
//  Copyright © 2016 Very Tiny Machines. All rights reserved.
//

import UIKit
import MessageUI


public enum SalesScreenType {
    case theme
    case themeCreator
    case scientificKey
    case generic
}

class NumericalViewController: UIViewController, MFMailComposeViewControllerDelegate, UIPopoverPresentationControllerDelegate, UIViewControllerTransitioningDelegate {
    
    var loadingScreen:UIView?
    var menuDismissButton:UIButton?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: UIBarButtonItemStyle.plain, target: nil, action: nil)
    }
    
    func notifyUser(title: String?, message: String?) {
        DispatchQueue.main.async {
            let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
            
            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: { (action) in
                
            }))
            
            self.present(alert, animated: true, completion: {
                
            })
        }
    }
    
    func attemptToOpenURL(urlString: String) {
        if let url = URL(string: urlString) {
            
            if UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            } else {
                notifyUser(title: "Error", message: "Could not open URL")
            }
            
        } else {
            notifyUser(title: "Error", message: "Could not process URL")
        }
    }
    
    func email(emailAddress: String, subject: String) {
        if MFMailComposeViewController.canSendMail() {
            
            let picker = MFMailComposeViewController()
            picker.mailComposeDelegate = self
            
            let toReceipts = [emailAddress]
            picker.setToRecipients(toReceipts)
            
            picker.setSubject(subject + NumericalHelper.currentDeviceInfo(includeBuildNumber: true))
            
            if let info = Bundle.main.infoDictionary {
                if let version = info["CFBundleShortVersionString"] as? String, let buildNumber = info["CFBundleVersion"] as? String {
                    picker.setSubject("\(subject) - v\(version) (\(buildNumber))")
                }
            }
            
            present(picker, animated: true, completion: {
                () -> Void in
                
            })
        } else {
            self.notifyUser(title: "Email Not Configured", message: "Looks like you can't send an email natively. Please email verytinymachines@gmail.com")
        }
    }
    
    func share(string: String) {
        let activityViewController = UIActivityViewController(activityItems: ["I'm using Numerical 2, the calculator without equal! http://www.verytinymachines.com/numerical" as NSString], applicationActivities: nil)
        
        present(activityViewController, animated: true) { 
            
        }
        
    }
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        // User has finished with this email dialogue, just dismiss it.
        controller.dismiss(animated: true) { 
            
        }
    }
    
    func presentSalesScreen(type: SalesScreenType?) {
        
        if let view = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "SalesViewController") as? SalesViewController {
            
            view.transitioningDelegate = self
            
            view.modalPresentationStyle = .overFullScreen
            view.modalPresentationCapturesStatusBarAppearance = true
            
            present(view, animated: true, completion: {
                
            })
        }
    }
    
    func presentSettings(sourceView: UIView?) {
        if let view = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "AboutViewController") as? AboutViewController {
            
            let navCon = UINavigationController(rootViewController: view)
            
            navCon.modalPresentationStyle = UIModalPresentationStyle.popover
            navCon.preferredContentSize = CGSize(width: 400, height: 400)
            
            let popVC = navCon.popoverPresentationController!
            
            popVC.sourceView = self.view
            
            if let sourceView = sourceView {
                popVC.sourceRect = self.view.convert(sourceView.frame, from: sourceView)
            }
            
            popVC.delegate = self
            
            present(navCon, animated: true, completion: {
                
            })
        }
    }
    
    func presentThemeSelector() {
        if let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ThemeViewController") as? ThemeViewController {
            
            vc.view.backgroundColor = UIColor.red
            vc.modalPresentationCapturesStatusBarAppearance = true
            
//            self.present(vc, animated: true, completion: {
//            })
            
            let navCon = ThemeNavigationController(rootViewController: vc)
            navCon.modalPresentationCapturesStatusBarAppearance = true
            
            self.present(navCon, animated: true, completion: {
                
            })
        }
    }
    
    
    
    func presentiTunesManage() {
        self.attemptToOpenURL(urlString: "itms-apps://buy.itunes.apple.com/WebObjects/MZFinance.woa/wa/manageSubscriptions")
    }
    
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return .none
    }
    
    func beginLoadingScreen() {
        removeLoadingScreenIfNeeded()
        
        let screenSize = self.view.bounds
        
        let newView = UIView(frame: CGRect(x: 0, y: 0, width: screenSize.width, height: screenSize.height))
        
        newView.backgroundColor = UIColor(white: 0.0, alpha: 0.75)
        
        newView.alpha = 0
        newView.isUserInteractionEnabled = true
        
        // Add a loading indicator to this view
        
        let activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.whiteLarge)
        activityIndicator.frame = newView.frame
        
        newView.addSubview(activityIndicator)
        activityIndicator.startAnimating()
        
        self.view.addSubview(newView)
        
        loadingScreen = newView
        
        UIView.animate(withDuration: 0.2, animations: {
            newView.alpha = 1.0
            }, completion: { (complete) in
                
        })
    }
    
    func endLoadingScreen() {
        
        if let loadingScreen = loadingScreen {
            UIView.animate(withDuration: 0.2, animations: {
                loadingScreen.alpha = 0
                }, completion: { (complete) in
                    self.removeLoadingScreenIfNeeded()
            })
        }
    }
    
    func removeLoadingScreenIfNeeded() {
        
        if let loadingScreen = loadingScreen {
            loadingScreen.removeFromSuperview()
        }
        
        loadingScreen = nil
    }
    
    func presentMenu(menuItems: [UIMenuItem], targetRect: CGRect, inView: UIView) {
        self.becomeFirstResponder()
        
        let menu = UIMenuController.shared
        
        menu.setTargetRect(targetRect, in: view)
        
        menu.menuItems = menuItems
        menu.setMenuVisible(true, animated: true)
        
        // Present the dissmiss button in the top most view.
        
        if let appDelegate = UIApplication.shared.delegate {
            if let vc = appDelegate.window??.rootViewController {
                print(vc)
                
                if let menuDismissButton = menuDismissButton {
                    menuDismissButton.removeFromSuperview()
                }
                
                let button = UIButton(type: UIButtonType.system)
                button.backgroundColor = UIColor.clear
                
                button.frame = CGRect(x: 0, y: 0, width: vc.view.frame.width, height:  vc.view.frame.height)
                
                button.addTarget(self, action: #selector(NumericalViewController.hideMenu), for: UIControlEvents.touchUpInside)
                
                vc.view.addSubview(button)
                
                menuDismissButton = button
            }
        }
    }
    
    
    func hideMenu() {
        self.resignFirstResponder()
        let menu = UIMenuController.shared
        menu.menuItems = nil
        menu.setMenuVisible(false, animated: true)
        
        // Hide the dismiss button in the top most view.
        
        if let menuDismissButton = menuDismissButton {
            menuDismissButton.removeFromSuperview()
        }
    }
    
    func isMenuVisible() -> Bool {
        if let menuItems = UIMenuController.shared.menuItems {
            if menuItems.count > 0 {
                // At least one item in menu, it's visible
                return true
            }
        }
        
        return false
    }
    
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        let controller = CustomAnimationController()
        controller.isPresenting = true
        return controller
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        let controller = CustomAnimationController()
        controller.isPresenting = false
        return controller
    }
    
    func autoLayoutAddViewController(viewController: UIViewController, intoView view:UIView, parentViewController: UIViewController) {
        
        if let subView = viewController.view {
            
            subView.translatesAutoresizingMaskIntoConstraints = false
            
            view.addSubview(subView)
            
            parentViewController.addChildViewController(viewController)
            
            view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-0-[subView]-0-|", options: NSLayoutFormatOptions.directionLeadingToTrailing, metrics: nil, views: ["subView":subView]))
            
            view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-0-[subView]-0-|", options: NSLayoutFormatOptions.directionLeadingToTrailing, metrics: nil, views: ["subView":subView]))
        }
    }
    
    func displayAlert(title: String?, message: String?) {
        let alert = UIAlertView(title: title, message: message, delegate: nil, cancelButtonTitle: "Ok")
        alert.show()
    }
    
    
    
}
