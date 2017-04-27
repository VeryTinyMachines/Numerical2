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
    case whatsnew
    case themes
    case logging
    case migratehistory
    case preferdecimal
    case preferradians
    case showscientific
    case historybehind
    
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
        
        setupItems()
        
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
        
        NotificationCenter.default.addObserver(self, selector: #selector(AboutViewController.reloadData), name: Notification.Name(rawValue: NumericalHelperSetting.migration), object: nil)
        
//        for cellName in ["SwitchCell"] {
//            let nib = UINib(nibName: cellName, bundle: nil)
//            self.tableView.register(nib, forCellReuseIdentifier: cellName)
//        }
        
        self.themeChanged()
    }
    
    func setupItems() {
        
        items.removeAll()
        
        items.append(AboutViewItem.whatsnew)
        items.append(AboutViewItem.seperator)
        items.append(AboutViewItem.premiumInfo)
        items.append(AboutViewItem.seperator)
        
        if NumericalHelper.isSettingEnabled(string: NumericalHelperSetting.themes) {
            items.append(AboutViewItem.themeSelector)
            items.append(AboutViewItem.seperator)
        }
        
        items.append(AboutViewItem.sounds)
        items.append(AboutViewItem.seperator)
        
        items.append(AboutViewItem.autoBracket)
        items.append(AboutViewItem.seperator)
        
        items.append(AboutViewItem.cloudSync)
        items.append(AboutViewItem.seperator)
        
        items.append(AboutViewItem.logging)
        items.append(AboutViewItem.seperator)
        
        if EquationStore.sharedStore.canConvertDeprecatedEquations() {
            items.append(AboutViewItem.migratehistory)
            items.append(AboutViewItem.seperator)
        }
        
        items.append(AboutViewItem.preferdecimal)
        items.append(AboutViewItem.seperator)
        
        items.append(AboutViewItem.preferradians)
        items.append(AboutViewItem.seperator)
        
        // Show Scientific Keyboard
        items.append(AboutViewItem.showscientific)
        items.append(AboutViewItem.seperator)
        
        // Prefer History Behind
        items.append(AboutViewItem.historybehind)
        items.append(AboutViewItem.seperator)
        
        items.append(AboutViewItem.keyboard)
        items.append(AboutViewItem.seperator)
        items.append(AboutViewItem.contact)
        items.append(AboutViewItem.follow)
        items.append(AboutViewItem.share)
        items.append(AboutViewItem.rate)
        items.append(AboutViewItem.website)
    }
    
    func themeChanged() {
        self.reloadData()
        
        separatorView.isHidden = true
        //separatorView.backgroundColor = ThemeCoordinator.shared.foregroundColorForCurrentTheme().withAlphaComponent(0.33)
        
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
        
        return 66
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
                string += "Thanks for supporting Numerical - you rock!\nManage Subscription"
            } else {
                string += "Support Numerical"
            }
            
//            if PremiumCoordinator.shared.legacyThemeUser {
//                string += "\nYou have purchased the legacy theme pack."
//            }
            
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
        case .whatsnew:
            cell.textLabel?.text = "What's New?"
        case .themes:
            let switchCell = tableView.dequeueReusableCell(withIdentifier: "SwitchCell", for: indexPath) as! SwitchCell
            
            setSwitchCell(text: "Enable Themes", isOn: NumericalHelper.isSettingEnabled(string: NumericalHelperSetting.themes), row: indexPath.row, switchCell: switchCell)
            
            return switchCell
        case .logging:
            let switchCell = tableView.dequeueReusableCell(withIdentifier: "SwitchCell", for: indexPath) as! SwitchCell
            
            setSwitchCell(text: "Enable Debug Logging", isOn: NumericalHelper.isSettingEnabled(string: NumericalHelperSetting.logging), row: indexPath.row, switchCell: switchCell)
            
            return switchCell
        case .migratehistory:
            cell.textLabel?.text = "Convert Numerical v1 History"
        case .preferdecimal:
            let switchCell = tableView.dequeueReusableCell(withIdentifier: "SwitchCell", for: indexPath) as! SwitchCell
            
            setSwitchCell(text: "Prefer Decimal Answers", isOn: NumericalHelper.isSettingEnabled(string: NumericalHelperSetting.preferdecimal), row: indexPath.row, switchCell: switchCell)
            
            return switchCell
        case .preferradians:
            let switchCell = tableView.dequeueReusableCell(withIdentifier: "SwitchCell", for: indexPath) as! SwitchCell
            
            if NumericalHelper.isSettingEnabled(string: NumericalHelperSetting.preferRadians) {
                setSwitchCell(text: "Prefer Radians\n(Turn off for Degrees)", isOn: NumericalHelper.isSettingEnabled(string: NumericalHelperSetting.preferRadians), row: indexPath.row, switchCell: switchCell)
            } else {
                setSwitchCell(text: "Prefer Radians", isOn: NumericalHelper.isSettingEnabled(string: NumericalHelperSetting.preferRadians), row: indexPath.row, switchCell: switchCell)
            }
            
            return switchCell
        case .showscientific:
            let switchCell = tableView.dequeueReusableCell(withIdentifier: "SwitchCell", for: indexPath) as! SwitchCell
            
            setSwitchCell(text: "Show Scientific Keys", isOn: NumericalHelper.isSettingEnabled(string: NumericalHelperSetting.showScientific), row: indexPath.row, switchCell: switchCell)
            
            return switchCell
        case .historybehind:
            
            let switchCell = tableView.dequeueReusableCell(withIdentifier: "SwitchCell", for: indexPath) as! SwitchCell
            
            if NumericalHelper.isSettingEnabled(string: NumericalHelperSetting.preferHistoryBehind) {
                setSwitchCell(text: "History List Behind Keypad", isOn: NumericalHelper.isSettingEnabled(string: NumericalHelperSetting.preferHistoryBehind), row: indexPath.row, switchCell: switchCell)
            } else {
                setSwitchCell(text: "History List Behind Keypad", isOn: NumericalHelper.isSettingEnabled(string: NumericalHelperSetting.preferHistoryBehind), row: indexPath.row, switchCell: switchCell)
            }
            
            return switchCell
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
                    self.displayAlert(title: "iCloud Issue", message: "Sorry but there is something wrong with iCloud. Please check the iOS Settings App and enable iCloud Drive for Numerical²")
                }
            }
            
        case .autoBracket:
            NumericalHelper.flipSetting(string: NumericalHelperSetting.autoBrackets)
        case .sounds:
            NumericalHelper.flipSetting(string: NumericalHelperSetting.sounds)
        case .themes:
            NumericalHelper.flipSetting(string: NumericalHelperSetting.themes)
            
            if NumericalHelper.isSettingEnabled(string: NumericalHelperSetting.themes) {
                // This is enabled.
                self.displayAlert(title: "Themes", message: "Something is going wrong with themes and we are still determining the cause. If you see a strange grey background color then please switch this off.")
            }
            
            setupItems()
            reloadData()
            
            ThemeCoordinator.shared.postThemeChangedNotification()
        case .logging:
            NumericalHelper.flipSetting(string: NumericalHelperSetting.logging)
            
            SimpleLogger.shared.loggingEnabled = NumericalHelper.isSettingEnabled(string: NumericalHelperSetting.logging)
            
            if NumericalHelper.isSettingEnabled(string: NumericalHelperSetting.logging) {
                // This is enabled.
                self.displayAlert(title: "Debug Logging is enabled", message: "This may affect app performance so disable this unless you want to use it and are helping AJC fix a bug.")
            }
        case .preferdecimal:
            NumericalHelper.flipSetting(string: NumericalHelperSetting.preferdecimal)
            // Reload the answer
            NotificationCenter.default.post(name: Notification.Name(rawValue: EquationStoreNotification.equationLogicChanged), object: nil)
        case .preferradians:
            NumericalHelper.flipSetting(string: NumericalHelperSetting.preferRadians)
            // Reload the answer
            NotificationCenter.default.post(name: Notification.Name(rawValue: EquationStoreNotification.equationLogicChanged), object: nil)
        case .showscientific:
            NumericalHelper.flipSetting(string: NumericalHelperSetting.showScientific)
            ThemeCoordinator.shared.postThemeChangedNotification()
        case .historybehind:
            NumericalHelper.flipSetting(string: NumericalHelperSetting.preferHistoryBehind)
            
            DispatchQueue.main.async {
                NotificationCenter.default.post(name: Notification.Name(rawValue: NumericalHelperSetting.preferHistoryBehind), object: nil)
            }
        default:
            break
        }
        
        reloadData()
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        DispatchQueue.main.async {
            switch self.items[indexPath.row] {
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
                self.presentThemeSelector()
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
            case .whatsnew:
                self.attemptToOpenURL(urlString: "http://verytinymachines.com/numerical2-whatsnew")
            case .themes:
                break
            case .seperator:
                break
            case .logging:
                break
            case .migratehistory:
                self.convertHistory(block: { (complete) in
                    
                })
            case .preferdecimal:
                break
            case .preferradians:
                break
            case .showscientific:
                break
            case .historybehind:
                break
            }
        }
    }
    
    
    func reloadData() {
        DispatchQueue.main.async {
            self.setupItems()
            self.tableView.reloadData()
        }
    }
    
}
