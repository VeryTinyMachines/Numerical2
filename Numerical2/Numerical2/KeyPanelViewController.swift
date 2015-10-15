//
//  KeyPanelViewController.swift
//  Numerical2
//
//  Created by Andrew J Clark on 1/08/2015.
//  Copyright © 2015 Very Tiny Machines. All rights reserved.
//

import UIKit

public enum ViewType {
    case StandardKeypad
    case ScientificKeypad
    case AboutView
}

class KeyPanelViewController: UIViewController, KeypadDelegate, UIPageViewControllerDataSource, UIPageViewControllerDelegate {
    
    var delegate: KeypadDelegate?
    
    var cachedViews = Dictionary<ViewType,AnyObject>()
    
    var pageController: UIPageViewController?
    
    var nextIndex:Int?
    
    var currentView = ViewType.StandardKeypad
    var currentLegalKeys:Set<Character> = []
    var currentPage:AnyObject?
    
    @IBOutlet weak var pageControl: UIPageControl!
    
    @IBOutlet weak var containerTwoWidthConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var containerOneWidthConstraint: NSLayoutConstraint!

    func pressedKey(key: Character) {
//        animateKeyPadSwitch()
        if let keyDelegate = delegate {
            keyDelegate.pressedKey(key)
        }
    }
    
    func viewIsWide() -> Bool {
        return false
    }
    
    func pageViewController(pageViewController: UIPageViewController, viewControllerBeforeViewController viewController: UIViewController) -> UIViewController? {
        
        if viewIsWideForSize(self.view.bounds.size) {
            if let _ = viewController as? KeypadViewController {
                return viewForType(ViewType.AboutView)
            }
        } else {
            if let view = viewController as? KeypadViewController {
                
                if view.layoutType == KeypadLayout.CompactScientific {
                    return viewForType(ViewType.AboutView)
                } else if view.layoutType == KeypadLayout.CompactStandard {
                    return viewForType(ViewType.ScientificKeypad)
                } else if view.layoutType == KeypadLayout.Regular {
                    return viewForType(ViewType.AboutView)
                }
            }
        }
        
        return nil
    }
    
    func pageViewController(pageViewController: UIPageViewController, viewControllerAfterViewController viewController: UIViewController) -> UIViewController? {
        
        if viewIsWideForSize(self.view.bounds.size) {
            if let _ = viewController as? KeypadViewController {
                return nil
            } else {
                return viewForType(ViewType.ScientificKeypad)
            }
        } else {
            if let view = viewController as? KeypadViewController {
                
                if view.layoutType == KeypadLayout.CompactScientific {
                    return viewForType(ViewType.StandardKeypad)
                } else if view.layoutType == KeypadLayout.CompactStandard {
                    return nil
                }
            } else {
                return viewForType(ViewType.ScientificKeypad)
            }
        }
        
        
        return nil
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        pageController = UIPageViewController(
            transitionStyle: UIPageViewControllerTransitionStyle.Scroll,
            navigationOrientation: .Horizontal,
            options: nil)
        
        
        if let startingViewController = viewForType(ViewType.StandardKeypad) {
            let viewControllers: Array = [startingViewController]
            
            currentPage = startingViewController
            
            pageController!.setViewControllers(viewControllers, direction: UIPageViewControllerNavigationDirection.Forward, animated: false, completion: nil)
            
            pageController?.delegate = self
            pageController?.dataSource = self
        
            
            updatePageCount()
        }
        
        
        
        
        self.addChildViewController(pageController!)
        self.view.addSubview(self.pageController!.view)
        
        let pageViewRect = self.view.bounds
        pageController!.view.frame = pageViewRect    
        pageController!.didMoveToParentViewController(self)
        
    }
    
    
    func layoutKeypad(theKeypad: KeypadViewController, type: ViewType, size: CGSize) {
        print("layoutKeypad")
        if viewIsWideForSize(size) {
            theKeypad.layoutType = KeypadLayout.Regular
        } else {
            theKeypad.layoutType = theKeypad.originLayoutType
        }
        
        theKeypad.setLegalKeys(currentLegalKeys)
        theKeypad.setupKeys()
    }
    
    func pageViewController(pageViewController: UIPageViewController, willTransitionToViewControllers pendingViewControllers: [UIViewController]) {
        
        if let nextView = pendingViewControllers.first {
            
            if let theKeyPad = nextView as? KeypadViewController {
                if theKeyPad.originLayoutType == KeypadLayout.CompactScientific {
                    layoutKeypad(theKeyPad, type: ViewType.ScientificKeypad, size: self.view.bounds.size)
                } else if theKeyPad.originLayoutType == KeypadLayout.CompactStandard {
                    layoutKeypad(theKeyPad, type: ViewType.StandardKeypad, size: self.view.bounds.size)
                }
            }
        }
        
    }
    
    func pageViewController(pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        
        if completed {
            currentPage = pageViewController.viewControllers?.first
        }
        
        updatePageCount()
        
    }
    
    override func viewWillTransitionToSize(size: CGSize, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {
        
        // Nullify the page view controller's data
        self.pageController?.dataSource = nil
        self.pageController?.dataSource = self
        
        // Get the current view, change it's type if necessary
        
        if let theKeyPad = self.currentPage as? KeypadViewController {
            if theKeyPad.originLayoutType == KeypadLayout.CompactScientific {
                self.layoutKeypad(theKeyPad, type: ViewType.ScientificKeypad, size: size)
            } else if theKeyPad.originLayoutType == KeypadLayout.CompactStandard {
                self.layoutKeypad(theKeyPad, type: ViewType.StandardKeypad, size: size)
            }
        }
        
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            self.updatePageCount()
        })
        
        coordinator.animateAlongsideTransition({ context in
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
            if theKeyPad.originLayoutType == KeypadLayout.CompactScientific {
                self.layoutKeypad(theKeyPad, type: ViewType.ScientificKeypad, size: size)
            } else if theKeyPad.originLayoutType == KeypadLayout.CompactStandard {
                self.layoutKeypad(theKeyPad, type: ViewType.StandardKeypad, size: size)
            }
        }
        
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            self.updatePageCount()
        })
    }
    
    func viewIsWideForSize(size: CGSize) -> Bool {
        
        return false
        
//        if let theDelegate = delegate {
//            return theDelegate.viewIsWide()
//        } else {
//            return false
//        }
    }
    
    
    func setLegalKeys(legalKeys: Set<Character>) {
        currentLegalKeys = legalKeys
        
        if let theKeyPad = currentPage as? KeypadViewController {
            theKeyPad.setLegalKeys(legalKeys)
        }
    }
    
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        updatePageCount()
    }
    
    
    func viewForType(type: ViewType) -> UIViewController? {
        
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
            
            if type == ViewType.AboutView {
                // AboutViewController
                
                let newKeyPad = storyboard.instantiateViewControllerWithIdentifier("AboutViewController")
                
                
                print("instantiated About View")
                // Instantiate and insert the new view
                
                // Set the newKeyPad to be of the right kind.
                
                cachedViews[type] = newKeyPad
                
                return newKeyPad
                
                
            } else {
                
                if let newKeyPad = storyboard.instantiateViewControllerWithIdentifier("KeypadViewController") as? KeypadViewController {
                    
                    print("instantiated newKeyPad")
                    // Instantiate and insert the new view
                    
                    // Set the newKeyPad to be of the right kind.
                    
                    if type == ViewType.StandardKeypad {
                        newKeyPad.layoutType = KeypadLayout.CompactStandard
                    } else if type == ViewType.ScientificKeypad {
                        newKeyPad.layoutType = KeypadLayout.CompactScientific
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
                if theKeyPad.originLayoutType == KeypadLayout.CompactScientific {
                    currentPageIndex = 1
                } else if theKeyPad.originLayoutType == KeypadLayout.CompactStandard {
                    currentPageIndex = 1
                } else {
                    currentPageIndex = 0
                }
            }
            
            pageCount = 2
        } else {
            
            if let theKeyPad = currentPage as? KeypadViewController {
                if theKeyPad.originLayoutType == KeypadLayout.CompactScientific {
                    currentPageIndex = 1
                } else if theKeyPad.originLayoutType == KeypadLayout.CompactStandard {
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