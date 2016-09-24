//
//  KeyPanelViewController.swift
//  Numerical2
//
//  Created by Andrew J Clark on 1/08/2015.
//  Copyright © 2015 Very Tiny Machines. All rights reserved.
//

import UIKit

public enum ViewType {
    case standardKeypad
    case scientificKeypad
    case aboutView
}

class KeyPanelViewController: UIViewController, KeypadDelegate, UIPageViewControllerDataSource, UIPageViewControllerDelegate {
    
    var delegate: KeypadDelegate?
    
    var cachedViews = Dictionary<ViewType,AnyObject>()
    
    var pageController: UIPageViewController?
    
    var nextIndex:Int?
    
    var currentView = ViewType.standardKeypad
    var currentLegalKeys:Set<Character> = []
    var currentPage:AnyObject?
    
    @IBOutlet weak var pageControl: UIPageControl!
    
    @IBOutlet weak var containerTwoWidthConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var containerOneWidthConstraint: NSLayoutConstraint!

    func pressedKey(_ key: Character) {
//        animateKeyPadSwitch()
        if let keyDelegate = delegate {
            keyDelegate.pressedKey(key)
        }
    }
    
    func viewIsWide() -> Bool {
        return false
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        
        if viewIsWideForSize(self.view.bounds.size) {
            if let _ = viewController as? KeypadViewController {
                return viewForType(ViewType.aboutView)
            }
        } else {
            if let view = viewController as? KeypadViewController {
                
                if view.layoutType == KeypadLayout.compactScientific {
                    return viewForType(ViewType.aboutView)
                } else if view.layoutType == KeypadLayout.compactStandard {
                    return viewForType(ViewType.scientificKeypad)
                } else if view.layoutType == KeypadLayout.regular {
                    return viewForType(ViewType.aboutView)
                }
            }
        }
        
        return nil
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        
        if viewIsWideForSize(self.view.bounds.size) {
            if let _ = viewController as? KeypadViewController {
                return nil
            } else {
                return viewForType(ViewType.scientificKeypad)
            }
        } else {
            if let view = viewController as? KeypadViewController {
                
                if view.layoutType == KeypadLayout.compactScientific {
                    return viewForType(ViewType.standardKeypad)
                } else if view.layoutType == KeypadLayout.compactStandard {
                    return nil
                }
            } else {
                return viewForType(ViewType.scientificKeypad)
            }
        }
        
        
        return nil
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        pageController = UIPageViewController(
            transitionStyle: UIPageViewControllerTransitionStyle.scroll,
            navigationOrientation: .horizontal,
            options: nil)
        
        
        if let startingViewController = viewForType(ViewType.standardKeypad) {
            let viewControllers: Array = [startingViewController]
            
            currentPage = startingViewController
            
            pageController!.setViewControllers(viewControllers, direction: UIPageViewControllerNavigationDirection.forward, animated: false, completion: nil)
            
            pageController?.delegate = self
            pageController?.dataSource = self
        
            
            updatePageCount()
        }
        
        self.addChildViewController(pageController!)
        self.view.addSubview(self.pageController!.view)
        
        let pageViewRect = self.view.bounds
        pageController!.view.frame = pageViewRect    
        pageController!.didMove(toParentViewController: self)
        
    }
    
    
    func layoutKeypad(_ theKeypad: KeypadViewController, type: ViewType, size: CGSize) {
        print("layoutKeypad")
        if viewIsWideForSize(size) {
            theKeypad.layoutType = KeypadLayout.regular
        } else {
            theKeypad.layoutType = theKeypad.originLayoutType
        }
        
        theKeypad.setLegalKeys(currentLegalKeys)
        theKeypad.setupKeys()
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, willTransitionTo pendingViewControllers: [UIViewController]) {
        
        if let nextView = pendingViewControllers.first {
            
            if let theKeyPad = nextView as? KeypadViewController {
                if theKeyPad.originLayoutType == KeypadLayout.compactScientific {
                    layoutKeypad(theKeyPad, type: ViewType.scientificKeypad, size: self.view.bounds.size)
                } else if theKeyPad.originLayoutType == KeypadLayout.compactStandard {
                    layoutKeypad(theKeyPad, type: ViewType.standardKeypad, size: self.view.bounds.size)
                }
            }
        }
        
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        
        if completed {
            currentPage = pageViewController.viewControllers?.first
        }
        
        updatePageCount()
        
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        
        // Nullify the page view controller's data
        self.pageController?.dataSource = nil
        self.pageController?.dataSource = self
        
        // Get the current view, change it's type if necessary
        
        if let theKeyPad = self.currentPage as? KeypadViewController {
            if theKeyPad.originLayoutType == KeypadLayout.compactScientific {
                self.layoutKeypad(theKeyPad, type: ViewType.scientificKeypad, size: size)
            } else if theKeyPad.originLayoutType == KeypadLayout.compactStandard {
                self.layoutKeypad(theKeyPad, type: ViewType.standardKeypad, size: size)
            }
        }
        
        DispatchQueue.main.async(execute: { () -> Void in
            self.updatePageCount()
        })
        
        coordinator.animate(alongsideTransition: { context in
            // do whatever with your context
            
            }, completion: { context in
                // do whatever with your context
        })
    }
    
    func updateKeyLayout() {
        
        let size = self.view.frame.size
        
        // Nullify the page view controller's data
        self.pageController?.dataSource = nil
        self.pageController?.dataSource = self
        
        // Get the current view, change it's type if necessary
        
        if let theKeyPad = self.currentPage as? KeypadViewController {
            if theKeyPad.originLayoutType == KeypadLayout.compactScientific {
                self.layoutKeypad(theKeyPad, type: ViewType.scientificKeypad, size: size)
            } else if theKeyPad.originLayoutType == KeypadLayout.compactStandard {
                self.layoutKeypad(theKeyPad, type: ViewType.standardKeypad, size: size)
            }
        }
        
        DispatchQueue.main.async(execute: { () -> Void in
            self.updatePageCount()
        })
    }
    
    func viewIsWideForSize(_ size: CGSize) -> Bool {
        
        return false
        
//        if let theDelegate = delegate {
//            return theDelegate.viewIsWide()
//        } else {
//            return false
//        }
    }
    
    
    func setLegalKeys(_ legalKeys: Set<Character>) {
        currentLegalKeys = legalKeys
        
        if let theKeyPad = currentPage as? KeypadViewController {
            theKeyPad.setLegalKeys(legalKeys)
        }
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        updatePageCount()
    }
    
    
    func viewForType(_ type: ViewType) -> UIViewController? {
        
        // Let's get the currentView
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        
        if let cachedPad = cachedViews[type] as? UIViewController {
            
            print("loaded cachedKeyPad")
            
            if let cachedKeyPad = cachedPad as? KeypadViewController {
                cachedKeyPad.setLegalKeys(currentLegalKeys)
                return cachedKeyPad
            } else {
                return cachedPad
            }
            
        } else {
            
            if type == ViewType.aboutView {
                // AboutViewController
                
                let newKeyPad = storyboard.instantiateViewController(withIdentifier: "AboutViewController")
                
                
                print("instantiated About View")
                // Instantiate and insert the new view
                
                // Set the newKeyPad to be of the right kind.
                
                cachedViews[type] = newKeyPad
                
                return newKeyPad
                
                
            } else {
                
                if let newKeyPad = storyboard.instantiateViewController(withIdentifier: "KeypadViewController") as? KeypadViewController {
                    
                    print("instantiated newKeyPad")
                    // Instantiate and insert the new view
                    
                    // Set the newKeyPad to be of the right kind.
                    
                    if type == ViewType.standardKeypad {
                        newKeyPad.layoutType = KeypadLayout.compactStandard
                    } else if type == ViewType.scientificKeypad {
                        newKeyPad.layoutType = KeypadLayout.compactScientific
                    }
                    
                    newKeyPad.originLayoutType = newKeyPad.layoutType
                    newKeyPad.setLegalKeys(currentLegalKeys)
                    newKeyPad.delegate = self
                    
                    cachedViews[type] = newKeyPad
                    
                    return newKeyPad
                } else {
                    print("no keypad found")
                    return nil
                }
            }
        }
    }
    
    
    func updatePageCount() {
        
        
        var currentPageIndex = 0
        var pageCount = 0
        
        if viewIsWideForSize(self.view.frame.size) {
            
            if let theKeyPad = currentPage as? KeypadViewController {
                if theKeyPad.originLayoutType == KeypadLayout.compactScientific {
                    currentPageIndex = 1
                } else if theKeyPad.originLayoutType == KeypadLayout.compactStandard {
                    currentPageIndex = 1
                } else {
                    currentPageIndex = 0
                }
            }
            
            pageCount = 2
        } else {
            
            if let theKeyPad = currentPage as? KeypadViewController {
                if theKeyPad.originLayoutType == KeypadLayout.compactScientific {
                    currentPageIndex = 1
                } else if theKeyPad.originLayoutType == KeypadLayout.compactStandard {
                    currentPageIndex = 2
                } else {
                    currentPageIndex = 0
                }
            }
            pageCount = 3
        }
        self.pageControl.numberOfPages = pageCount
        self.pageControl.currentPage = currentPageIndex
        
    }
}
