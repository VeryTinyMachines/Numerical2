//
//  ThemeViewController.swift
//  Numerical2
//
//  Created by Andrew Clark on 1/12/2016.
//  Copyright © 2016 Very Tiny Machines. All rights reserved.
//

import UIKit

class ThemeViewController: NumericalViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    
    var gradiantLayer:CAGradientLayer?
    
    var selectedTheme:Theme?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.collectionView.dataSource = self
        self.collectionView.delegate = self
        
        self.collectionView.backgroundColor = UIColor.clear
        
        self.collectionView.contentInset = UIEdgeInsets(top: 10, left: 0, bottom: 0, right: 0)
        
        self.title = "Theme Selector"
        
        let flow = collectionView.collectionViewLayout as! UICollectionViewFlowLayout
        flow.sectionInset = UIEdgeInsetsMake(0, 0, 0, 0)
        let width = UIScreen.main.bounds.width - 6
        flow.itemSize = CGSize(width: width/3, height: width/3)
        flow.minimumInteritemSpacing = border()
        flow.minimumLineSpacing = border()
        
        let cancelButton = UIBarButtonItem(title: "Cancel", style: UIBarButtonItemStyle.plain, target: self, action: #selector(ThemeViewController.userPressedCancel))
        let doneButton = UIBarButtonItem(title: "Done", style: UIBarButtonItemStyle.done, target: self, action: #selector(ThemeViewController.userPressedDone))
        
        self.navigationItem.leftBarButtonItem = cancelButton
        self.navigationItem.rightBarButtonItem = doneButton
        
        NotificationCenter.default.addObserver(self, selector: #selector(ThemeViewController.themeChanged), name: Notification.Name(rawValue: PremiumCoordinatorNotification.themeChanged), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(ThemeViewController.reloadData), name: Notification.Name(rawValue: PremiumCoordinatorNotification.premiumStatusChanged), object: nil)
        
        selectedTheme = ThemeCoordinator.shared.currentTheme()
        
        themeChanged()
        
//        Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { (timer) in
//            PremiumCoordinator.shared.premiumIAPUser = true
//            PremiumCoordinator.shared.postUserPremiumStatusChanged()
//        }
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
            
            if selectedTheme.isPremium {
                
                if PremiumCoordinator.shared.canAccessThemes() {
                    ThemeCoordinator.shared.changeTheme(toTheme: selectedTheme)
                    dismissSelf()
                } else {
                    // Cannot apply this theme. Show the sales view
                    self.presentSalesScreen(type: SalesScreenType.theme)
                }
                
            } else {
                ThemeCoordinator.shared.changeTheme(toTheme: selectedTheme)
                dismissSelf()
            }
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
        
        let theme = ThemeCoordinator.shared.themes[indexPath.row]
        
        cell.backgroundColor = UIColor.clear
        
        var selected = false
        
        if let selectedTheme = selectedTheme {
            if selectedTheme.themeID == theme.themeID {
                selected = true
            }
        }
        
        cell.layoutWithTheme(theme: theme, selected: selected)
        
        return cell
    }
    
    
    public func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return ThemeCoordinator.shared.themes.count
    }
    
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: IndexPath) -> CGSize {
        let size = (self.view.frame.width - (CGFloat(numberOfColumns()) - 1) * border()) / CGFloat(numberOfColumns())
        return CGSize(width: size, height: size)
    }
    
    func numberOfColumns() -> Int {
        return 3
    }
    
    func border() -> CGFloat {
        return 10.0
    }
    
    func themeChanged() {
        
        self.view.layoutIfNeeded()
        
        gradiantLayer?.removeFromSuperlayer()
        
        if let selectedTheme = selectedTheme {
            
            self.navigationController?.navigationBar.barTintColor = selectedTheme.firstColor
            
            let foregroundColor = ThemeCoordinator.shared.foregroundColorForTheme(theme: selectedTheme)
            self.navigationController?.navigationBar.tintColor = foregroundColor
            
            self.navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName:foregroundColor]
            
            let layer = ThemeCoordinator.shared.gradiantLayerForTheme(theme: selectedTheme)
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
        themeChanged()
    }
    
    
    override var preferredStatusBarStyle : UIStatusBarStyle {
        if let selectedTheme = selectedTheme {
            return ThemeCoordinator.shared.preferredStatusBarStyleForTheme(theme: selectedTheme)
        } else {
            return ThemeCoordinator.shared.preferredStatusBarStyleForCurrentTheme()
        }
    }

    
    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let theme = ThemeCoordinator.shared.themes[indexPath.row]
        selectedTheme = theme
        themeChanged()
    }
}

class ThemeCollectionViewCell: UICollectionViewCell {
    var gradiantLayer:CAGradientLayer?
    
    @IBOutlet weak var mainLabel: UILabel!
    
    func layoutWithTheme(theme: Theme, selected: Bool) {
        
        self.gradiantLayer?.removeFromSuperlayer()
        
        let newLayer = ThemeCoordinator.shared.gradiantLayerForTheme(theme: theme)
        
        newLayer.frame = CGRect(x: 0, y: 0, width: self.frame.width, height: self.frame.height)
        
        if selected {
            newLayer.borderColor = ThemeCoordinator.shared.foregroundColorForTheme(theme: theme).cgColor
            newLayer.borderWidth = 5
        } else {
            newLayer.borderColor = nil
            newLayer.borderWidth = 0
        }
        
        newLayer.cornerRadius = newLayer.frame.width / 2
        
        self.layer.insertSublayer(newLayer, at: 0)
        
        self.gradiantLayer = newLayer
        self.mainLabel.text = theme.title
        
        if theme.isPremium && PremiumCoordinator.shared.canAccessThemes() == false {
            self.mainLabel.text = theme.title + "\n(Pro)"
        }
        
        self.mainLabel.textColor = ThemeCoordinator.shared.foregroundColorForTheme(theme: theme)
        self.mainLabel.font = NumericalHelper.aboutMenuFont()
    }
}

class ThemeNavigationController: UINavigationController {
    
    override var preferredStatusBarStyle : UIStatusBarStyle {
        if let rootView = self.viewControllers.first as? ThemeViewController {
            return rootView.preferredStatusBarStyle
        } else {
            return UIStatusBarStyle.lightContent
        }
    }
    
}

