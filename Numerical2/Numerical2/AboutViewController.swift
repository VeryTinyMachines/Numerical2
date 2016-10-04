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
        tableView.backgroundColor = UIColor.clear
        
        view.backgroundColor = UIColor.clear
        
        items = [
        AboutViewItem.about,
        
        AboutViewItem.seperator,
        
        AboutViewItem.premiumInfo,
        
        AboutViewItem.seperator,
        
        AboutViewItem.themeSelector,
        
        AboutViewItem.seperator,
        
//        AboutViewItem.autoBracket,
        AboutViewItem.cloudSync,
        
        AboutViewItem.seperator,
        
        AboutViewItem.contact,
        AboutViewItem.follow,
        AboutViewItem.share,
        AboutViewItem.rate,
        AboutViewItem.website
        ]
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
            cell.textLabel?.text = "Auto brackets are Enabled."
        case .cloudSync:
            if NumericalHelper.isSettingEnabled(string: NumericalHelperSetting.iCloudHistorySync) {
                cell.textLabel?.text = "iCloud Sync is Enabled"
            } else {
                cell.textLabel?.text = "iCloud Sync is Disabled"
            }
        case .contact:
            cell.textLabel?.text = "Contact Us"
        case .follow:
            cell.textLabel?.text = "Follow"
        case .premiumInfo:
            cell.textLabel?.text = "You are not a premium member."
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
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        switch items[indexPath.row] {
        case .about:
            break
        case .autoBracket:
            break
        case .contact:
            self.email(emailAddress: "verytinymachines@gmail.com", subject: "Numerical")
        case .follow:
            self.attemptToOpenURL(urlString: "http://www.twitter.com/VTMachines")
        case .premiumInfo:
            break
        case .rate:
            self.attemptToOpenURL(urlString: "https://itunes.apple.com/app/id804548449&mt=8")
        case .share:
            self.share(string: "http://itunes.apple.com/app/id804548449&mt=8")
        case .themeSelector:
            if PremiumCoordinator.shared.canAccessThemes() {
                presentThemeSelector()
            } else {
                presentSalesScreen(type: SalesScreenType.scientificKey)
            }
            
        case .website:
            self.attemptToOpenURL(urlString: "http://verytinymachines.com/numerical")
        case .cloudSync:
            NumericalHelper.flipSetting(string: NumericalHelperSetting.iCloudHistorySync)
            reloadData()
            
            if NumericalHelper.isSettingEnabled(string: NumericalHelperSetting.iCloudHistorySync) {
                // This is enabled.
                EquationStore.sharedStore.initialiseiCloud()
            }
            
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
            alert.addAction(UIAlertAction(title: theme.title, style: UIAlertActionStyle.default, handler: { (action) in
                PremiumCoordinator.shared.setTheme(string: theme.themeID)
            }))
        }
        
        alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: { (action) in
            
        }))
        
        present(alert, animated: true) { 
            
        }
        
    }
    
    
}
