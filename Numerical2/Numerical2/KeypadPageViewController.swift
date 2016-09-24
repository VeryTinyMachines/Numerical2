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
            self.pageViewController?.dataSource = self
        } else {
            regularView = false
            self.pageViewController?.dataSource = self
        }
        
        let duration = coordinator.transitionDuration
        
        UIView.animate(withDuration: duration / 2, animations: { () -> Void in
            self.pageViewController?.view.alpha = 0.0
            }, completion: { (complete) -> Void in
                
                self.setupPageView()
                
                self.pageViewController?.view.alpha = 0.0
                
                UIView.animate(withDuration: duration / 2, animations: { () -> Void in
                    self.pageViewController?.view.alpha = 1.0
                    }, completion: { (complete) -> Void in
                        
                        if let firstView = self.pageViewController?.viewControllers?.first {
                            self.updateDelegatePageControl(firstView)
                            
                            if let keyPad = firstView as? KeypadViewController {
                                keyPad.updateLegalKeys()
                            }
                        }
                }) 
        }) 
    }
    
    
    func setupPageView() {
        
        var startingLayout = KeypadLayout.compactStandard
        
        if regularView {
            startingLayout = KeypadLayout.regular
        }
        
        // If we are current on an about screen then stick to that.
        
        // ZZZ
        
        var needsAboutView = false
        
        if let currentView = pageViewController?.viewControllers?.first {
            if let _ = currentView as? AboutViewController {
                needsAboutView = true
            }
        }
        
        if let pageVC = pageViewController {
            pageVC.dataSource = nil
            pageVC.delegate = nil
            pageVC.removeFromParentViewController()
            pageVC.view.removeFromSuperview()
            pageVC.didMove(toParentViewController: pageVC.parent)
        }
        
        pageViewController = nil;
        
        if needsAboutView {
            if let aboutView = viewControllerForAboutView() {
                setupPageViewController(withViewController: aboutView)
            }
        } else if let vc = viewControllerWithKeypadLayout(startingLayout) {
            setupPageViewController(withViewController: vc)
        }
    }
    
    func setupPageViewController(withViewController viewController: UIViewController) {
        pageViewController = UIPageViewController(transitionStyle: .scroll, navigationOrientation: .horizontal, options: nil)
        pageViewController!.view.frame = self.view.bounds
        
        pageViewController!.dataSource = self
        pageViewController!.delegate = self
        
        pageViewController!.setViewControllers([viewController], direction: .forward, animated: false, completion: nil)
        
        addChildViewController(pageViewController!)
        view.addSubview(pageViewController!.view)
        pageViewController!.didMove(toParentViewController: self)
        
        updateDelegatePageControl(viewController)
    }
    
    func viewIsWide() -> Bool {
        
        if self.view.bounds.width > self.view.bounds.height {
            return true
        }
        
        return false
    }
    
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        
        if let currentView = viewController as? KeypadViewController {
            
            if currentView.layoutType == KeypadLayout.compactStandard {
                // Need scientific pad
                if let scientificPad = viewControllerWithKeypadLayout(KeypadLayout.compactScientific) {
                    return scientificPad;
                }
            } else if currentView.layoutType == KeypadLayout.compactScientific {
                if let aboutView = viewControllerForAboutView() {
                    return aboutView
                }
            } else if currentView.layoutType == KeypadLayout.regular {
                if let aboutView = viewControllerForAboutView() {
                    return aboutView
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
        } else if let _ = viewController as? AboutViewController {
            if regularView {
                if let view = viewControllerWithKeypadLayout(KeypadLayout.regular) {
                    return view;
                }
            } else {
                if let view = viewControllerWithKeypadLayout(KeypadLayout.compactScientific) {
                    return view;
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
    
    
    func viewControllerForAboutView() -> AboutViewController? {
        if let view = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "AboutViewController") as? AboutViewController {
            return view
        }
        
        return nil
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, willTransitionTo pendingViewControllers: [UIViewController]) {
        
        if let firstView = pageViewController.viewControllers?.first {
            updateDelegatePageControl(firstView)
            
            if let vc = firstView as? KeypadViewController {
                vc.setLegalKeys(currentLegalKeys)
            }
            
            if let pendingVC = pendingViewControllers.first as? KeypadViewController {
                pendingVC.setLegalKeys(currentLegalKeys)
            }
        }
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        
        if let firstView = pageViewController.viewControllers?.first {
            updateDelegatePageControl(firstView)
            
            if let vc = firstView as? KeypadViewController {
                vc.setLegalKeys(currentLegalKeys)
            }
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
    
    func updateDelegatePageControl(_ viewController: UIViewController) {
        
        if let keypadViewController = viewController as? KeypadViewController {
            switch keypadViewController.layoutType {
            case .compactScientific:
                updateDelegatePageControl(1, numberOfPages: 3)
            case .compactStandard:
                updateDelegatePageControl(2, numberOfPages: 3)
            case .regular:
                updateDelegatePageControl(1, numberOfPages: 2)
            case .all:
                updateDelegatePageControl(0, numberOfPages: 0)
            }
        } else if let _ = viewController as? AboutViewController {
            if regularView {
                updateDelegatePageControl(0, numberOfPages: 2)
            } else {
                updateDelegatePageControl(0, numberOfPages: 3)
            }
        }
        
        
    }
    
    func updateDelegatePageControl(_ currentPage: NSInteger, numberOfPages: NSInteger) {
        
        if let theDelegate = pageViewDelegate {
            theDelegate.updatePageControl(currentPage, numberOfPages: numberOfPages)
        }
    }
}
