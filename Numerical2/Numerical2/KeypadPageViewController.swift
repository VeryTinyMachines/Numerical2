//
//  KeypadPageViewController.swift
//  Numerical2
//
//  Created by Andrew J Clark on 10/10/2015.
//  Copyright © 2015 Very Tiny Machines. All rights reserved.
//

import UIKit

protocol KeypadPageViewDelegate {
    func updatePageControl(currentPage: NSInteger, numberOfPages: NSInteger)
}

class KeypadPageViewController: UIViewController, UIPageViewControllerDataSource, UIPageViewControllerDelegate, KeypadDelegate {
    
    var delegate: KeypadDelegate?
    var pageViewDelegate: KeypadPageViewDelegate?
    
    var pageViewController : UIPageViewController?
    
    var currentIndex : Int = 0
    
    var regularView: Bool = false
    
    var currentLegalKeys:Set<Character> = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
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
            self.pageViewController?.dataSource = nil
        } else {
            regularView = false
            self.pageViewController?.dataSource = self
        }
        
        let duration = coordinator.transitionDuration()
        
        UIView.animateWithDuration(duration / 2, animations: { () -> Void in
            self.pageViewController?.view.alpha = 0.0
            }) { (complete) -> Void in
                
                self.setupPageView()
                
                if size.width > size.height {
                    self.pageViewController?.dataSource = nil
                }
                
                self.pageViewController?.view.alpha = 0.0
                
                UIView.animateWithDuration(duration / 2, animations: { () -> Void in
                    self.pageViewController?.view.alpha = 1.0
                    }) { (complete) -> Void in
                        
                        if let keypad = self.pageViewController?.viewControllers?.first as? KeypadViewController {
                            keypad.updateLegalKeys()
                            self.updateDelegatePageControl(keypad)
                        }
                }
        }
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
            pageViewController!.delegate = self
            
            pageViewController!.setViewControllers([vc], direction: .Forward, animated: false, completion: nil)
            
            addChildViewController(pageViewController!)
            view.addSubview(pageViewController!.view)
            pageViewController!.didMoveToParentViewController(self)
            
            updateDelegatePageControl(vc)
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
                keypad.setLegalKeys(currentLegalKeys)
                return keypad
            }
        } else if layout == KeypadLayout.Regular {
            if let keypad = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("RegularKeypadViewController") as? KeypadViewController {
                keypad.delegate = self
                keypad.layoutType = layout
                keypad.setLegalKeys(currentLegalKeys)
                return keypad
            }
        }
        
        return nil
    }
    
    func pageViewController(pageViewController: UIPageViewController, willTransitionToViewControllers pendingViewControllers: [UIViewController]) {
        

        if let vc = pendingViewControllers.first as? KeypadViewController {
            updateDelegatePageControl(vc)
        }
    }
    
    func pageViewController(pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        
        if let vc = pageViewController.viewControllers?.first as? KeypadViewController {
            updateDelegatePageControl(vc)
        }
        
    }
    
    func pressedKey(key: Character) {
        print("pressedKey")
        
        if let theDelegate = delegate {
            theDelegate.pressedKey(key)
        }
    }
    
    func setLegalKeys(legalKeys: Set<Character>) {
        currentLegalKeys = legalKeys
        
        if let keyPad = pageViewController?.viewControllers?.first as? KeypadViewController {
            keyPad.setLegalKeys(currentLegalKeys)
        }
        
    }
    
    func updateDelegatePageControl(keypadViewController: KeypadViewController) {
        
        
        switch keypadViewController.layoutType {
        case .CompactScientific:
            updateDelegatePageControl(0, numberOfPages: 2)
        case .CompactStandard:
            updateDelegatePageControl(1, numberOfPages: 2)
        case .Regular:
            updateDelegatePageControl(0, numberOfPages: 0)
        case .All:
            updateDelegatePageControl(0, numberOfPages: 0)
        }
    }
    
    func updateDelegatePageControl(currentPage: NSInteger, numberOfPages: NSInteger) {
        
        if let theDelegate = pageViewDelegate {
            theDelegate.updatePageControl(currentPage, numberOfPages: numberOfPages)
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
