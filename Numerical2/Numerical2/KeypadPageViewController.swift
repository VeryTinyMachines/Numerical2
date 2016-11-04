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


class KeypadPageViewController: NumericalViewController, UIPageViewControllerDataSource, UIPageViewControllerDelegate, KeypadDelegate {
    
    func unpressedKey(_ key: Character, sourceView: UIView?) {
        
    }

    
    var delegate: KeypadDelegate?
    
    var pageViewDelegate: KeypadPageViewDelegate?
    
    var pageViewController : UIPageViewController?
    
    var currentIndex : Int = 0
    
    var currentLegalKeys:Set<Character> = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupPageView()
    }

    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        
        hideMenu()
        
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
                            self.updateDelegatePageControl()
                            
                            if let keyPad = firstView as? KeypadViewController {
                                keyPad.updateLegalKeys()
                            }
                        }
                }) 
        }) 
    }
    
    
    func setupPageView() {
        
        var startingLayout = KeypadLayout.compactStandard
        
        if self.viewIsWide() {
            startingLayout = KeypadLayout.regular
        }
        
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
        
        pageViewController!.setViewControllers([viewController], direction: .forward, animated: false, completion: nil)
        
        updateDelegatePageControl()
        updateDelegateDatasource()
        
        addChildViewController(pageViewController!)
        view.addSubview(pageViewController!.view)
        pageViewController!.didMove(toParentViewController: self)
    }
    
    func viewIsWide() -> Bool {
        
        if NumericalHelper.isDevicePad() {
            // It's an iPad!
            return true
        } else {
            // It's an iPhone
            
            if self.view.bounds.width > self.view.bounds.height && self.view.bounds.width > 450 {
                // This view is wider than it is tall, so we should
                return true
            } else {
                return false
            }
        }
    }
    
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        
        if let currentView = viewController as? KeypadViewController {
            
            if currentView.layoutType == KeypadLayout.compactStandard {
                // Need scientific pad
                if let scientificPad = viewControllerWithKeypadLayout(KeypadLayout.compactScientific) {
                    return scientificPad;
                }
            } else if currentView.layoutType == KeypadLayout.compactScientific {
                if NumericalHelper.shouldSettingsScreenBeModal() == false {
                    if let aboutView = viewControllerForAboutView() {
                        return aboutView
                    }
                }
            } else if currentView.layoutType == KeypadLayout.regular {
                if NumericalHelper.shouldSettingsScreenBeModal() == false {
                    if let aboutView = viewControllerForAboutView() {
                        return aboutView
                    }
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
            if self.viewIsWide() {
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
            // Update the page control
            updateDelegatePageControl()
            
            // Update the datasource and delegate
            updateDelegateDatasource()
            
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
            updateDelegatePageControl()
            
            if let vc = firstView as? KeypadViewController {
                vc.setLegalKeys(currentLegalKeys)
            }
        }
    }
    
    func pressedKey(_ key: Character, sourceView: UIView?) {
        if let theDelegate = delegate {
            theDelegate.pressedKey(key, sourceView: sourceView)
        }
    }
    
    func setLegalKeys(_ legalKeys: Set<Character>) {
        currentLegalKeys = legalKeys
        
        if let keyPad = pageViewController?.viewControllers?.first as? KeypadViewController {
            keyPad.setLegalKeys(currentLegalKeys)
        }
    }
    
    func updateDelegateDatasource() {
        if pageCount().numberOfPages > 1 {
            self.pageViewController?.delegate = self
            self.pageViewController?.dataSource = self
        } else {
            self.pageViewController?.delegate = nil
            self.pageViewController?.dataSource = nil
        }
    }
    
    func updateDelegatePageControl() {
        let currentPageCount = pageCount()
        updateDelegatePageControl(currentPageCount.currentPage, numberOfPages: currentPageCount.numberOfPages)
    }
    
    func pageCount() -> (currentPage: Int, numberOfPages: Int) {
        
        if let viewController = pageViewController?.viewControllers?.first {
            let modal:Int = NumericalHelper.shouldSettingsScreenBeModal() ? 0 : 1
            
            if let keypadViewController = viewController as? KeypadViewController {
                switch keypadViewController.layoutType {
                case .compactScientific:
                    return (currentPage: 1, numberOfPages: 2 + modal)
                case .compactStandard:
                    return (currentPage: 2, numberOfPages: 2 + modal)
                case .regular:
                    return (currentPage: 1, numberOfPages: 1 + modal)
                case .all:
                    return (currentPage: 0, numberOfPages: 0)
                }
            } else if let _ = viewController as? AboutViewController {
                if self.viewIsWide() {
                    return (currentPage: 0, numberOfPages: 1 + modal)
                } else {
                    return (currentPage: 0, numberOfPages: 2 + modal)
                }
            }

        }
        
        return (currentPage: 0, numberOfPages: 0)
    }
    
    func updateDelegatePageControl(_ currentPage: NSInteger, numberOfPages: NSInteger) {
        
        if let theDelegate = pageViewDelegate {
            theDelegate.updatePageControl(currentPage, numberOfPages: numberOfPages)
        }
    }
    
}
