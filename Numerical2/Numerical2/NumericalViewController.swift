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
}

class NumericalViewController: UIViewController, MFMailComposeViewControllerDelegate {
    
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
            
            picker.setSubject(subject)
            
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
        self.notifyUser(title: "Sales Screen", message: "\(type)")
    }
    
}
