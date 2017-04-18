//
//  ThemeViewController.swift
//  Numerical2
//
//  Created by Andrew Clark on 1/12/2016.
//  Copyright © 2016 Very Tiny Machines. All rights reserved.
//

import UIKit

class ThemeViewController: NumericalViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    
    let kBorder:CGFloat = 10.0
    let kSectionCount = 2
    
    let kSectionCustomThemes = 0
    let kSectionSystemThemes = 1
    
    var gradiantLayer:CAGradientLayer?
    
    var selectedTheme:Theme?
    
    override func viewDidLoad() {
        SimpleLogger.appendLog(string: "ThemeViewController.viewDidLoad()")
        
        super.viewDidLoad()
        
        self.collectionView.dataSource = self
        self.collectionView.delegate = self
        
        self.collectionView.backgroundColor = UIColor.clear
        
        self.collectionView.contentInset = UIEdgeInsets(top: kBorder, left: 0, bottom: 0, right: 0)
        
        self.title = "Theme Selector"
        
        let flow = collectionView.collectionViewLayout as! UICollectionViewFlowLayout
        flow.sectionInset = UIEdgeInsetsMake(0, 0, kBorder, 0)
        let width = UIScreen.main.bounds.width - 6
        flow.itemSize = CGSize(width: width/3, height: width/3)
        flow.minimumInteritemSpacing = border()
        flow.minimumLineSpacing = border()
        
        let cancelButton = UIBarButtonItem(title: "Cancel", style: UIBarButtonItemStyle.plain, target: self, action: #selector(ThemeViewController.userPressedCancel))
        let doneButton = UIBarButtonItem(title: "Done", style: UIBarButtonItemStyle.done, target: self, action: #selector(ThemeViewController.userPressedDone))
        
        self.navigationItem.leftBarButtonItem = cancelButton
        self.navigationItem.rightBarButtonItem = doneButton
        
        NotificationCenter.default.addObserver(self, selector: #selector(ThemeViewController.themeChangedFromNotif), name: Notification.Name(rawValue: PremiumCoordinatorNotification.themeChanged), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(ThemeViewController.reloadData), name: Notification.Name(rawValue: PremiumCoordinatorNotification.premiumStatusChanged), object: nil)
        
        selectedTheme = ThemeCoordinator.shared.currentTheme()
        SimpleLogger.appendLog(string: "ThemeViewController selected theme set: \(selectedTheme)")
        
        themeChanged()
    }
    
    func themeChangedFromNotif() {
        selectedTheme = ThemeCoordinator.shared.currentTheme()
        self.reloadData()
    }
    
    func reloadData() {
        self.collectionView.reloadData()
        themeChanged()
    }
    
    func userPressedCancel() {
        dismissSelf()
    }
    
    func userPressedDone() {
        
        if let selectedTheme = selectedTheme {
            ThemeCoordinator.shared.changeTheme(toTheme: selectedTheme)
            dismissSelf()
        } else {
            dismissSelf()
        }
    }
    
    func dismissSelf() {
        self.dismiss(animated: true) {
            
        }
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ThemeCollectionViewCell", for: indexPath) as! ThemeCollectionViewCell
        
        if indexPath.section == kSectionCustomThemes {
            
            if indexPath.row == 0 {
                // New theme
                
                let theme = Theme(title: "New Theme", themeID: "newtheme", color1: "848484", color2: "848484", style: ThemeStyle.normal, premium: true)
                
                cell.backgroundColor = UIColor.clear
                
                cell.layoutWithTheme(theme: theme, selected: false)
                
            } else {
                let theme = ThemeCoordinator.shared.userThemes[indexPath.row - 1]
                
                cell.backgroundColor = UIColor.clear
                
                var selected = false
                
                if let selectedTheme = selectedTheme {
                    if selectedTheme.themeID == theme.themeID {
                        selected = true
                    }
                }
                
                cell.layoutWithTheme(theme: theme, selected: selected)
            }
            
        } else if indexPath.section == kSectionSystemThemes {
            let theme = ThemeCoordinator.shared.themes[indexPath.row]
            
            cell.backgroundColor = UIColor.clear
            
            var selected = false
            
            if let selectedTheme = selectedTheme {
                if selectedTheme.themeID == theme.themeID {
                    selected = true
                }
            }
            
            cell.layoutWithTheme(theme: theme, selected: selected)
        }
        
        return cell
    }
    
    
    public func numberOfSections(in collectionView: UICollectionView) -> Int {
        return kSectionCount
    }
    
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        if section == kSectionCustomThemes {
            return ThemeCoordinator.shared.userThemes.count + 1
        } else if section == kSectionSystemThemes {
            return ThemeCoordinator.shared.themes.count
        }
        
        return 0
        
    }
    
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: IndexPath) -> CGSize {
        
        let size = preferredSize()
        return CGSize(width: size - 1, height: size - 1)
    }
    
    func preferredSize() -> CGFloat {
        
        let size = (self.view.frame.width - (CGFloat(numberOfColumns()) - 1) * border()) / CGFloat(numberOfColumns())
        
        return size - 1
    }
    
    func numberOfColumns() -> Int {
        
        var columnCount = 3
        
        if NumericalViewHelper.isDevicePad() {
            columnCount = Int(round(self.view.frame.width / 200.0))
        } else {
            columnCount = Int(round(self.view.frame.width / 140.0))
        }
        
        if columnCount > 3 {
            return columnCount
        } else {
            return 3
        }
    }
    
    func border() -> CGFloat {
        return 10.0
    }
    
    func themeChanged() {
        
        SimpleLogger.appendLog(string: "ThemeViewController.themeChanged()")
        
        self.view.layoutIfNeeded()
        
        gradiantLayer?.removeFromSuperlayer()
        
        if let selectedTheme = selectedTheme {
            
            self.navigationController?.navigationBar.barTintColor = selectedTheme.firstColor
            
            let foregroundColor = ThemeFormatter.foregroundColorForTheme(theme: selectedTheme)
            self.navigationController?.navigationBar.tintColor = foregroundColor
            self.navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName:foregroundColor]
            
            let layer = ThemeFormatter.gradiantLayerForTheme(theme: selectedTheme)
            layer.frame = self.view.frame
            
            self.view.layer.insertSublayer(layer, at: 0)
            
            self.view.backgroundColor = selectedTheme.firstColor
            
            gradiantLayer = layer
            
            self.setNeedsStatusBarAppearanceUpdate()
        }
        
        self.collectionView.reloadData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if let theSelectedTheme = selectedTheme {
            if ThemeCoordinator.shared.doesThemeStillExist(theme: theSelectedTheme) == false {
                selectedTheme = ThemeCoordinator.shared.currentTheme()
            }
        }
        
        themeChanged()
    }
    
    
    override var preferredStatusBarStyle : UIStatusBarStyle {
        if let selectedTheme = selectedTheme {
            return ThemeFormatter.preferredStatusBarStyleForTheme(theme: selectedTheme)
        } else {
            return ThemeCoordinator.shared.preferredStatusBarStyleForCurrentTheme()
        }
    }

    
    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if indexPath.section == kSectionCustomThemes {
            if indexPath.row == 0 {
                // Present theme creator
                pushThemeCreator(theme: nil)
            } else {
                let theme = ThemeCoordinator.shared.userThemes[indexPath.row - 1]
                
                if let theSelectedTheme = selectedTheme {
                    // Edit this theme if allowed.
                    if theme.themeID == theSelectedTheme.themeID && theSelectedTheme.isUserCreated {
                        
                        pushThemeCreator(theme: theSelectedTheme) // A user can always access the theme creator scree, but they cannot press the Done button.
                        
                        /*
                        if PremiumCoordinator.shared.canAccessThemes() {
                            pushThemeCreator(theme: theSelectedTheme)
                        } else {
                            presentSalesScreen(type: SalesScreenType.themeCreator)
                        }
 */
                    } else {
                        selectedTheme = theme
                    }
                } else {
                    selectedTheme = theme
                }
                
                themeChanged()
            }
        } else if indexPath.section == kSectionSystemThemes {
            let theme = ThemeCoordinator.shared.themes[indexPath.row]
            selectedTheme = theme
            themeChanged()
        }
    }
    
    func pushThemeCreator(theme: Theme?) {
        if let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ThemeCreatorViewController") as? ThemeCreatorViewController {
            vc.updateTheme = theme
            navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        coordinator.animate(alongsideTransition: { (context) in
            self.reloadData()
            self.themeChanged()
        }) { (context) in
            self.reloadData()
            self.themeChanged()
        }
    }
    
    
}

class ThemeCollectionViewCell: UICollectionViewCell {
    var gradiantLayer:CAGradientLayer?
    
    @IBOutlet weak var mainLabel: UILabel!
    
    func layoutWithTheme(theme: Theme, selected: Bool) {
        
        self.gradiantLayer?.removeFromSuperlayer()
        
        let newLayer = ThemeFormatter.gradiantLayerForTheme(theme: theme)
        
        newLayer.frame = CGRect(x: 0, y: 0, width: self.frame.width, height: self.frame.height)
        
        if selected {
            newLayer.borderColor = ThemeFormatter.foregroundColorForTheme(theme: theme).cgColor
            newLayer.borderWidth = 5
        } else {
            newLayer.borderColor = nil
            newLayer.borderWidth = 0
        }
        
        newLayer.cornerRadius = newLayer.frame.width / 2
        
        self.layer.insertSublayer(newLayer, at: 0)
        
        self.gradiantLayer = newLayer
        self.mainLabel.text = theme.title
        
        if theme.isPremium && PremiumCoordinator.shared.canAccessThemes() == false && theme.isUserCreated == false {
            self.mainLabel.text = theme.title + "\n(Pro)"
        } else if theme.isUserCreated && selected {
            self.mainLabel.text = "Tap to\nEdit"
        }
        
        self.mainLabel.textColor = ThemeFormatter.foregroundColorForTheme(theme: theme)
        self.mainLabel.font = NumericalHelper.aboutMenuFont()
    }
}

class ThemeNavigationController: UINavigationController {
    
    override var preferredStatusBarStyle : UIStatusBarStyle {
        
        if let visibleView = self.viewControllers.last {
            return visibleView.preferredStatusBarStyle
        }
        
        return UIStatusBarStyle.lightContent
    }
}

