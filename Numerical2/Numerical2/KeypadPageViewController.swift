//
//  KeypadPageViewController.swift
//  Numerical2
//
//  Created by Andrew J Clark on 10/10/2015.
//  Copyright © 2015 Very Tiny Machines. All rights reserved.
//

import UIKit

protocol KeypadPageViewDelegate {
    func updatePageControl(_ currentPage: NSInteger, numberOfPages: NSInteger)
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

    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        
        if size.width > size.height {
            regularView = true
            self.pageViewController?.dataSource = nil
        } else {
            regularView = false
            self.pageViewController?.dataSource = self
        }
        
        let duration = coordinator.transitionDuration
        
        UIView.animate(withDuration: duration / 2, animations: { () -> Void in
            self.pageViewController?.view.alpha = 0.0
            }, completion: { (complete) -> Void in
                
                self.setupPageView()
                
                if size.width > size.height {
                    self.pageViewController?.dataSource = nil
                }
                
                self.pageViewController?.view.alpha = 0.0
                
                UIView.animate(withDuration: duration / 2, animations: { () -> Void in
                    self.pageViewController?.view.alpha = 1.0
                    }, completion: { (complete) -> Void in
                        
                        if let keypad = self.pageViewController?.viewControllers?.first as? KeypadViewController {
                            keypad.updateLegalKeys()
                            self.updateDelegatePageControl(keypad)
                        }
                }) 
        }) 
    }
    
    
    func setupPageView() {
        
        var startingLayout = KeypadLayout.compactStandard
        
        if regularView {
            startingLayout = KeypadLayout.regular
        }
        
        if let pageVC = pageViewController {
            pageVC.dataSource = nil
            pageVC.delegate = nil
            pageVC.removeFromParentViewController()
            pageVC.view.removeFromSuperview()
            pageVC.didMove(toParentViewController: pageVC.parent)
        }
        
        pageViewController = nil;
        
        if let vc = viewControllerWithKeypadLayout(startingLayout) {
            pageViewController = UIPageViewController(transitionStyle: .scroll, navigationOrientation: .horizontal, options: nil)
            pageViewController!.view.frame = self.view.bounds
            
            pageViewController!.dataSource = self
            pageViewController!.delegate = self
            
            pageViewController!.setViewControllers([vc], direction: .forward, animated: false, completion: nil)
            
            addChildViewController(pageViewController!)
            view.addSubview(pageViewController!.view)
            pageViewController!.didMove(toParentViewController: self)
            
            updateDelegatePageControl(vc)
        }

    }
    
    func viewIsWide() -> Bool {
        
        if self.view.bounds.width > self.view.bounds.height {
            return true
        }
        
        return false
    }
    
    
    
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController?
    {
        
        if let currentView = viewController as? KeypadViewController {
            
            if currentView.layoutType == KeypadLayout.compactStandard {
                // Need scientific pad
                if let scientificPad = viewControllerWithKeypadLayout(KeypadLayout.compactScientific) {
                    return scientificPad;
                }
            }
        }
        
        return nil
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController?
    {
        if let currentView = viewController as? KeypadViewController {
            
            if currentView.layoutType == KeypadLayout.compactScientific {
                // Need standard pad
                if let standardPad = viewControllerWithKeypadLayout(KeypadLayout.compactStandard) {
                    return standardPad;
                }
            }
        }
        
        return nil
        
    }
    
    func viewControllerWithKeypadLayout(_ layout: KeypadLayout) -> KeypadViewController? {
        
        if layout == KeypadLayout.compactScientific || layout == KeypadLayout.compactStandard {
            if let keypad = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "CompactKeypadViewController") as? KeypadViewController {
                keypad.delegate = self
                keypad.layoutType = layout
                keypad.setLegalKeys(currentLegalKeys)
                return keypad
            }
        } else if layout == KeypadLayout.regular {
            if let keypad = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "RegularKeypadViewController") as? KeypadViewController {
                keypad.delegate = self
                keypad.layoutType = layout
                keypad.setLegalKeys(currentLegalKeys)
                return keypad
            }
        }
        
        return nil
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, willTransitionTo pendingViewControllers: [UIViewController]) {
        

        if let vc = pendingViewControllers.first as? KeypadViewController {
            vc.setLegalKeys(currentLegalKeys)
            updateDelegatePageControl(vc)
        }
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        
        if let vc = pageViewController.viewControllers?.first as? KeypadViewController {
            vc.setLegalKeys(currentLegalKeys)
            updateDelegatePageControl(vc)
        }
        
    }
    
    func pressedKey(_ key: Character) {
        if let theDelegate = delegate {
            theDelegate.pressedKey(key)
        }
    }
    
    func setLegalKeys(_ legalKeys: Set<Character>) {
        currentLegalKeys = legalKeys
        
        if let keyPad = pageViewController?.viewControllers?.first as? KeypadViewController {
            keyPad.setLegalKeys(currentLegalKeys)
        }
        
    }
    
    func updateDelegatePageControl(_ keypadViewController: KeypadViewController) {
        
        
        switch keypadViewController.layoutType {
        case .compactScientific:
            updateDelegatePageControl(0, numberOfPages: 2)
        case .compactStandard:
            updateDelegatePageControl(1, numberOfPages: 2)
        case .regular:
            updateDelegatePageControl(0, numberOfPages: 0)
        case .all:
            updateDelegatePageControl(0, numberOfPages: 0)
        }
    }
    
    func updateDelegatePageControl(_ currentPage: NSInteger, numberOfPages: NSInteger) {
        
        if let theDelegate = pageViewDelegate {
            theDelegate.updatePageControl(currentPage, numberOfPages: numberOfPages)
        }
    }
}
