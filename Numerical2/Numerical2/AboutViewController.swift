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
    case keyboard
}

class AboutViewController: NumericalViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var separatorView: UIView!
    
    var items = [AboutViewItem]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.dataSource = self
        tableView.delegate = self
        tableView.separatorStyle = UITableViewCellSeparatorStyle.none
        
        updateBackgroundColorForPresentationType()
        
        items = [
        
        // AboutViewItem.premiumInfo,
        
        // AboutViewItem.seperator,
        
        AboutViewItem.themeSelector,
        
        AboutViewItem.seperator,
        
        AboutViewItem.sounds,
        
        AboutViewItem.seperator,
        
        AboutViewItem.autoBracket,
        
        AboutViewItem.seperator,
        
        AboutViewItem.cloudSync,
        
        AboutViewItem.seperator,
        
        AboutViewItem.keyboard,
        
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
        
        NotificationCenter.default.addObserver(self, selector: #selector(AboutViewController.themeChanged), name: Notification.Name(rawValue: PremiumCoordinatorNotification.themeChanged), object: nil)
        
//        for cellName in ["SwitchCell"] {
//            let nib = UINib(nibName: cellName, bundle: nil)
//            self.tableView.register(nib, forCellReuseIdentifier: cellName)
//        }
        
        self.themeChanged()
    }
    
    func themeChanged() {
        self.reloadData()
        
        separatorView.backgroundColor = ThemeCoordinator.shared.foregroundColorForCurrentTheme().withAlphaComponent(0.33)
        
        updateBackgroundColorForPresentationType()
    }
    
    func userPressedCloseButton() {
        self.dismiss(animated: true) { 
            
        }
    }
    
    func updateBackgroundColorForPresentationType() {
        if let _ = self.navigationController {
            // We are in a navigation controller context and need to define our own background
            tableView.backgroundColor = ThemeCoordinator.shared.currentTheme().firstColor
            view.backgroundColor = ThemeCoordinator.shared.currentTheme().firstColor
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
        cell.textLabel?.textColor = ThemeCoordinator.shared.foregroundColorForCurrentTheme()
        cell.backgroundColor = UIColor.clear
        cell.selectionStyle = UITableViewCellSelectionStyle.none
        
        switch items[indexPath.row] {
        case .about:
            cell.textLabel?.text = "Numerical is the calculator without equal. We hope you like it!"
        case .autoBracket:
            
            let switchCell = tableView.dequeueReusableCell(withIdentifier: "SwitchCell", for: indexPath) as! SwitchCell
            
            var string = "Auto Brackets"
            
            if !NumericalHelper.isSettingEnabled(string: NumericalHelperSetting.autoBrackets) {
                string += "\n(Remeber your Order Of Evaluation)"
            }
            
            setSwitchCell(text: "Auto Brackets", isOn: NumericalHelper.isSettingEnabled(string: NumericalHelperSetting.autoBrackets), row: indexPath.row, switchCell: switchCell)
            
            return switchCell
            
        case .cloudSync:
            
            var string = "iCloud Sync"
            
            switch EquationStore.sharedStore.accountStatus {
            case .available:
                break
            case .couldNotDetermine:
                string += "\n(Could not determine iCloud Status)"
            case .noAccount:
                string += "\n(No iCloud account)"
            case .restricted:
                string += "\n(iCloud access restricted)"
            }
            
            let switchCell = tableView.dequeueReusableCell(withIdentifier: "SwitchCell", for: indexPath) as! SwitchCell
            
            setSwitchCell(text: string, isOn: NumericalHelper.isSettingEnabled(string: NumericalHelperSetting.iCloudHistorySync), row: indexPath.row, switchCell: switchCell)
            
            return switchCell
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
            cell.textLabel?.text = "Change & Create Themes"
        case .seperator:
            cell.textLabel?.text = ""
            cell.backgroundColor = ThemeCoordinator.shared.foregroundColorForCurrentTheme().withAlphaComponent(0.25)
            cell.selectionStyle = UITableViewCellSelectionStyle.none
        case .sounds:
            
            let switchCell = tableView.dequeueReusableCell(withIdentifier: "SwitchCell", for: indexPath) as! SwitchCell
            
            setSwitchCell(text: "Sounds", isOn: NumericalHelper.isSettingEnabled(string: NumericalHelperSetting.sounds), row: indexPath.row, switchCell: switchCell)
            
            return switchCell

        case .keyboard:
            cell.textLabel?.text = "Keyboard"
        }
        
        cell.textLabel?.numberOfLines = 3
        
        return cell
    }
    
    func setSwitchCell(text: String, isOn: Bool, row: Int, switchCell: SwitchCell) {
        switchCell.backgroundColor = UIColor.clear
        switchCell.backgroundColor = UIColor.clear
        switchCell.selectionStyle = UITableViewCellSelectionStyle.none
        
        switchCell.mainLabel.font =  NumericalHelper.aboutMenuFont()
        switchCell.mainLabel.numberOfLines = 2
        switchCell.mainLabel.adjustsFontSizeToFitWidth = true
        switchCell.mainLabel.minimumScaleFactor = 0.5
        switchCell.mainLabel.textColor = ThemeCoordinator.shared.foregroundColorForCurrentTheme()
        switchCell.mainLabel.text = text
        
        switchCell.mainSwitch.tag = row
        switchCell.mainSwitch.onTintColor = ThemeCoordinator.shared.foregroundColorForCurrentTheme().withAlphaComponent(0.66)
        
        switchCell.mainSwitch.addTarget(self, action: #selector(AboutViewController.switchChanged(_:)), for: UIControlEvents.valueChanged)
        
        switchCell.mainSwitch.isOn = isOn
    }
    
    func switchChanged(_ sender: UISwitch) {
        
        switch items[sender.tag] {
        case .cloudSync:
            NumericalHelper.flipSetting(string: NumericalHelperSetting.iCloudHistorySync)
            
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: NumericalHelperSetting.iCloudHistorySync), object: nil)
            
            if EquationStore.sharedStore.accountStatus == .available {
                if NumericalHelper.isSettingEnabled(string: NumericalHelperSetting.iCloudHistorySync) {
                    // This is enabled.
                    EquationStore.sharedStore.initialiseiCloud()
                    EquationStore.sharedStore.subscribeToCKIfNeeded()
                }
            } else {
                if NumericalHelper.isSettingEnabled(string: NumericalHelperSetting.iCloudHistorySync) {
                    // This is enabled but iCloud isn't available. Show a help message.
                    self.displayAlert(title: "iCloud Issue", message: "Sorry but there is something wrong with iCloud. Please check the iOS Settings app and enable iCloud Drive for Numerical²")
                }
            }
            
        case .autoBracket:
            NumericalHelper.flipSetting(string: NumericalHelperSetting.autoBrackets)
        case .sounds:
            NumericalHelper.flipSetting(string: NumericalHelperSetting.sounds)
        default:
            break
        }
        
        reloadData()
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        switch items[indexPath.row] {
        case .about:
            break
        case .autoBracket:
            break
        case .contact:
            self.email(emailAddress: "verytinymachines@gmail.com", subject: "Numerical²")
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
            break
        case .sounds:
            break
        case .keyboard:
            let alert = UIAlertController(title: "Numerical² Keyboard", message: "To install the Numerical² keyboard open Settings > General > Keyboard > Keyboards and select Numerical²", preferredStyle: UIAlertControllerStyle.actionSheet)
            
            alert.addAction(UIAlertAction(title: "Open Settings", style: UIAlertActionStyle.default, handler: { (action) in
                UIApplication.shared.open(URL(string: "App-Prefs:root=General&path=Keyboard")!)
            }))
            
            alert.addAction(UIAlertAction(title: "Contact Support", style: UIAlertActionStyle.default, handler: { (action) in
                self.email(emailAddress: "verytinymachines@gmail.com", subject: "Numerical² Keyboard")
            }))
            
            alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: { (action) in
                
            }))
            
            self.present(alert, animated: true, completion: {
                
            })
            
        case .seperator:
            break
        }
    }
    
    func reloadData() {
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
    
}
