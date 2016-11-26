//
//  AboutViewController.swift
//  Numerical2
//
//  Created by Andrew J Clark on 24/09/2016.
//  Copyright © 2016 Very Tiny Machines. All rights reserved.
//

import UIKit

public enum AboutViewItem {
    case about
    case premiumInfo
    case themeSelector
    case autoBracket
    case sounds
    case contact
    case follow
    case share
    case rate
    case website
    case seperator
    case cloudSync
}

class AboutViewController: NumericalViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    
    var items = [AboutViewItem]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.dataSource = self
        tableView.delegate = self
        tableView.separatorStyle = UITableViewCellSeparatorStyle.none
        
        updateBackgroundColorForPresentationType()
        
        items = [
//        AboutViewItem.about,
        
//        AboutViewItem.seperator,
        
        AboutViewItem.premiumInfo,
        
        AboutViewItem.seperator,
        
        AboutViewItem.themeSelector,
        
        AboutViewItem.seperator,
        
        AboutViewItem.sounds,
        
        AboutViewItem.seperator,
        
        AboutViewItem.autoBracket,
        
        AboutViewItem.seperator,
        
        AboutViewItem.cloudSync,
        
        AboutViewItem.seperator,
        
        AboutViewItem.contact,
        AboutViewItem.follow,
        AboutViewItem.share,
        AboutViewItem.rate,
        AboutViewItem.website
        ]
        
        if let navCon = self.navigationController {
            print(navCon)
        }
        
        // Setup navigation item (used for iPad and other modal views)
        navigationItem.title = "About Numerical - " + NumericalHelper.currentDeviceInfo(includeBuildNumber: false)
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Close", style: UIBarButtonItemStyle.plain, target: self, action: #selector(AboutViewController.userPressedCloseButton))
        
        navigationController?.view.tintColor = UIColor.black
        
        NotificationCenter.default.addObserver(self, selector: #selector(AboutViewController.reloadData), name: Notification.Name(rawValue: PremiumCoordinatorNotification.premiumStatusChanged), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(AboutViewController.reloadData), name: Notification.Name(rawValue: EquationStoreNotification.accountStatusChanged), object: nil)
    }
    
    func userPressedCloseButton() {
        self.dismiss(animated: true) { 
            
        }
    }
    
    func updateBackgroundColorForPresentationType() {
        if let _ = self.navigationController {
            // We are in a navigation controller context and need to define our own background
            tableView.backgroundColor = UIColor.darkGray
            view.backgroundColor = UIColor.darkGray
        } else {
            // We are not in a nav controller and should therefore simply have a clear background
            tableView.backgroundColor = UIColor.clear
            view.backgroundColor = UIColor.clear
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch items[indexPath.row] {
        case .contact, .follow, .rate, .website, .share:
            return 44
        case .seperator:
            return 1
        default:
            break
        }
        
        return 60
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell")!
        
        cell.backgroundColor = UIColor.clear
        cell.textLabel?.font =  NumericalHelper.aboutMenuFont()
        cell.textLabel?.numberOfLines = 2
        cell.textLabel?.adjustsFontSizeToFitWidth = true
        cell.textLabel?.minimumScaleFactor = 0.5
        cell.backgroundColor = UIColor.clear
        
        switch items[indexPath.row] {
        case .about:
            cell.textLabel?.text = "Numerical is the calculator without equal. We hope you like it!"
        case .autoBracket:
            if NumericalHelper.isSettingEnabled(string: NumericalHelperSetting.autoBrackets) {
                cell.textLabel?.text = "Auto brackets are Enabled"
            } else {
                cell.textLabel?.text = "Auto brackets are Disabled\n(Remember your order of operation)"
            }
            
        case .cloudSync:
            
            var string = ""
            
            if NumericalHelper.isSettingEnabled(string: NumericalHelperSetting.iCloudHistorySync) && EquationStore.sharedStore.accountStatus == .available {
                string = "iCloud Sync is Enabled"
            } else {
                string = "iCloud Sync is Disabled"
            }
            
            switch EquationStore.sharedStore.accountStatus {
            case .available:
                string += ""
            case .couldNotDetermine:
                string += "\n(Could not determine iCloud Status)"
            case .noAccount:
                string += "\n(No iCloud account)"
            case .restricted:
                string += "\n(iCloud access restricted)"
            }
            
            cell.textLabel?.text = string
            
        case .contact:
            cell.textLabel?.text = "Contact Us"
        case .follow:
            cell.textLabel?.text = "Follow"
        case .premiumInfo:
            
            var string = ""
            
            if PremiumCoordinator.shared.isUserPremium() {
                string += "Numerical Pro - You are a member!"
            } else {
                string += "Numerical Pro - Upgrade Today!"
            }
            
            if PremiumCoordinator.shared.legacyThemeUser {
                string += "\nYou have purchased the legacy theme pack."
            }
            
            cell.textLabel?.text = string
            
        case .rate:
            cell.textLabel?.text = "Rate"
        case .website:
            cell.textLabel?.text = "Website"
        case .share:
            cell.textLabel?.text = "Share"
        case .themeSelector:
            cell.textLabel?.text = "Change Theme"
        case .seperator:
            cell.textLabel?.text = ""
            cell.backgroundColor = UIColor.white.withAlphaComponent(0.25)
        case .sounds:
            if NumericalHelper.isSettingEnabled(string: NumericalHelperSetting.sounds) {
                cell.textLabel?.text = "Sounds are Enabled"
            } else {
                cell.textLabel?.text = "Sounds are Daisabled"
            }
        }
        
        cell.textLabel?.numberOfLines = 3
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        switch items[indexPath.row] {
        case .about:
            break
        case .autoBracket:
            NumericalHelper.flipSetting(string: NumericalHelperSetting.autoBrackets)
            reloadData()
        case .contact:
            self.email(emailAddress: "verytinymachines@gmail.com", subject: "Numerical")
        case .follow:
            self.attemptToOpenURL(urlString: "http://www.twitter.com/VTMachines")
        case .premiumInfo:
            self.presentSalesScreen(type: SalesScreenType.generic)
        case .rate:
            self.attemptToOpenURL(urlString: "https://itunes.apple.com/app/id804548449&mt=8")
        case .share:
            self.share(string: "http://itunes.apple.com/app/id804548449&mt=8")
        case .themeSelector:
            presentThemeSelector()
        case .website:
            self.attemptToOpenURL(urlString: "http://verytinymachines.com/numerical")
        case .cloudSync:
            NumericalHelper.flipSetting(string: NumericalHelperSetting.iCloudHistorySync)
            reloadData()
            
            if EquationStore.sharedStore.accountStatus == .available {
                if NumericalHelper.isSettingEnabled(string: NumericalHelperSetting.iCloudHistorySync) {
                    // This is enabled.
                    EquationStore.sharedStore.initialiseiCloud()
                    EquationStore.sharedStore.subscribeToCKIfNeeded()
                }
            }
        case .sounds:
            NumericalHelper.flipSetting(string: NumericalHelperSetting.sounds)
            reloadData()
        case .seperator:
            break
        }
    }
    
    func reloadData() {
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
    
    func presentThemeSelector() {
        
        let alert = UIAlertController(title: "Choose Your Theme", message: nil, preferredStyle: UIAlertControllerStyle.actionSheet)
        
        for theme in PremiumCoordinator.shared.themes {
            
            
            var title = "           " + theme.title
            
            if PremiumCoordinator.shared.canAccessThemes() == false && theme.themeID != "pink001" {
                title += " (Pro)"
            }
            
            let action = UIAlertAction(title: title, style: UIAlertActionStyle.default, handler: { (action) in
                if PremiumCoordinator.shared.canAccessThemes() || theme.themeID == "pink001" {
                    PremiumCoordinator.shared.setTheme(string: theme.themeID)
                } else {
                    self.presentSalesScreen(type: SalesScreenType.theme)
                }
            })
            
            let image = PremiumCoordinator.shared.thumbnailImageForTheme(string: theme.themeID)?.withRenderingMode(UIImageRenderingMode.alwaysOriginal)
            
            action.setValue(image, forKey: "image")
            
            alert.addAction(action)
        }
        
        alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: { (action) in
            
        }))
        
        present(alert, animated: true) { 
            
        }
        
    }
    
    
}
