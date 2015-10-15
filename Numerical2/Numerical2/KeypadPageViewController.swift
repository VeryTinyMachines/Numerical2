//
//  KeypadPageViewController.swift
//  Numerical2
//
//  Created by Andrew J Clark on 10/10/2015.
//  Copyright © 2015 Very Tiny Machines. All rights reserved.
//

import UIKit

class KeypadPageViewController: UIViewController, UIPageViewControllerDataSource, UIPageViewControllerDelegate, KeypadDelegate {
    
    var delegate: KeypadDelegate?
    
    var pageViewController : UIPageViewController?
    
    var pageTitles : Array<String> = ["God vs Man", "Cool Breeze", "Fire Sky"]
    var pageImages : Array<String> = ["page1.png", "page2.png", "page3.png"]
    
    var currentIndex : Int = 0
    
    var regularView: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        var startingLayout = KeypadLayout.CompactStandard
        
//        print(UIDevice.currentDevice().orientation.rawValue)
        
        regularView = viewIsWide()
        
        setupPageView()
        
        /*
        if regularView {
            startingLayout = KeypadLayout.Regular
        }
        
        if let vc = viewControllerWithKeypadLayout(startingLayout) {
            pageViewController = UIPageViewController(transitionStyle: .Scroll, navigationOrientation: .Horizontal, options: nil)
            pageViewController!.dataSource = self
            
            pageViewController!.setViewControllers([vc], direction: .Forward, animated: false, completion: nil)
            
            addChildViewController(pageViewController!)
            view.addSubview(pageViewController!.view)
            pageViewController!.didMoveToParentViewController(self)
        }
        */
        
    }
    

    
    override func viewWillTransitionToSize(size: CGSize, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {
        
        if size.width > size.height {
            regularView = true
        } else {
            regularView = false
        }
        
        let duration = coordinator.transitionDuration()
        
        UIView.animateWithDuration(duration / 2, animations: { () -> Void in
            self.pageViewController?.view.alpha = 0.0
            }) { (complete) -> Void in
                
                self.setupPageView()
                self.pageViewController?.view.alpha = 0.0
                
                UIView.animateWithDuration(duration / 2, animations: { () -> Void in
                    self.pageViewController?.view.alpha = 1.0
                    }) { (complete) -> Void in
                        
                        
                        
                }
                
                
        }
        
        
        
//        setupPageView()
    }
    
    func setupPageView() {
        
        var startingLayout = KeypadLayout.CompactStandard
        
        if regularView {
            startingLayout = KeypadLayout.Regular
        }
        
        if let pageVC = pageViewController {
            pageVC.dataSource = nil
            pageVC.delegate = nil
            pageVC.removeFromParentViewController()
            pageVC.view.removeFromSuperview()
            pageVC.didMoveToParentViewController(pageVC.parentViewController)
        }
        
        pageViewController = nil;
        
        if let vc = viewControllerWithKeypadLayout(startingLayout) {
            pageViewController = UIPageViewController(transitionStyle: .Scroll, navigationOrientation: .Horizontal, options: nil)
            pageViewController!.view.frame = self.view.bounds
            
            pageViewController!.dataSource = self
            
            pageViewController!.setViewControllers([vc], direction: .Forward, animated: false, completion: nil)
            
            addChildViewController(pageViewController!)
            view.addSubview(pageViewController!.view)
            pageViewController!.didMoveToParentViewController(self)
        }

    }
    
    func viewIsWide() -> Bool {
        
        if self.view.bounds.width > self.view.bounds.height {
            return true
        }
        
        return false
    }
    
    
    
    
    func pageViewController(pageViewController: UIPageViewController, viewControllerBeforeViewController viewController: UIViewController) -> UIViewController?
    {
        
        if let currentView = viewController as? KeypadViewController {
            
            if currentView.layoutType == KeypadLayout.CompactStandard {
                // Need scientific pad
                if let scientificPad = viewControllerWithKeypadLayout(KeypadLayout.CompactScientific) {
                    return scientificPad;
                }
            }
        }
        
        return nil
    }
    
    func pageViewController(pageViewController: UIPageViewController, viewControllerAfterViewController viewController: UIViewController) -> UIViewController?
    {
        if let currentView = viewController as? KeypadViewController {
            
            if currentView.layoutType == KeypadLayout.CompactScientific {
                // Need standard pad
                if let standardPad = viewControllerWithKeypadLayout(KeypadLayout.CompactStandard) {
                    return standardPad;
                }
            }
        }
        
        return nil
        
    }
    
    func viewControllerWithKeypadLayout(layout: KeypadLayout) -> KeypadViewController? {
        
        if layout == KeypadLayout.CompactScientific || layout == KeypadLayout.CompactStandard {
            if let keypad = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("CompactKeypadViewController") as? KeypadViewController {
                keypad.delegate = self
                keypad.layoutType = layout
                return keypad
            }
        } else if layout == KeypadLayout.Regular {
            if let keypad = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("RegularKeypadViewController") as? KeypadViewController {
                keypad.delegate = self
                keypad.layoutType = layout
                return keypad
            }
        }
        
        return nil
    }
    
    func pressedKey(key: Character) {
        print("pressedKey")
        
        if let theDelegate = delegate {
            theDelegate.pressedKey(key)
        }
    }
    
//    func presentationCountForPageViewController(pageViewController: UIPageViewController) -> Int
//    {
//        return self.pageTitles.count
//    }
//    
//    func presentationIndexForPageViewController(pageViewController: UIPageViewController) -> Int
//    {
//        return 0
//    }
    
    
}
