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

public enum KeypadViewType {
    case about
    case regular
    case compactScientific
    case compactStandard
    case history
}


class KeypadPageViewController: NumericalViewController, UIPageViewControllerDataSource, UIPageViewControllerDelegate, KeypadDelegate, UIScrollViewDelegate {
    
    func unpressedKey(_ key: Character, sourceView: UIView?) {
        
    }
    
    var cachedViewController = [KeypadViewType:UIViewController]()
    
    var delegate: KeypadDelegate?
    
    var pageViewDelegate: KeypadPageViewDelegate?
    
    var pageViewController : SwipePageViewController?
    
    var currentIndex : Int = 0
    
    var currentLegalKeys:Set<Character> = []
    
    var pageViewSetup = false
    var pageIsScrolling = false
    var originalContentOffset:CGPoint?
    var scrollingOffset:CGFloat?
    
    // var currentView:KeypadViewController?
    
    @IBOutlet weak var keypadHolder1: UIView!
    
    @IBOutlet weak var keypadHolder2: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // If the theme changes we may need to reset the keyboard (since keyboards might have disappeared)
        
        NotificationCenter.default.addObserver(self, selector: #selector(KeypadPageViewController.setupPageView), name: Notification.Name(rawValue: PremiumCoordinatorNotification.themeChanged), object: nil)
        
        // Add swipe left and swipe right gestures
        let swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(KeypadPageViewController.swipeLeft))
        swipeLeft.direction = .left
        self.view.addGestureRecognizer(swipeLeft)
        
        let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(KeypadPageViewController.swipeRight))
        swipeRight.direction = .right
        self.view.addGestureRecognizer(swipeRight)
        
        
    }
    
    func swipeLeft() {
        print("left")
        /*
        if let currentView = currentView {
            // Get the view before this one
            let viewType = keyForView(viewController: currentView)
            let viewsArray = self.viewsArray()
            
            // Find the index of the viewtype, then determine the previous one
            
            if let index = viewsArray.index(of: viewType) {
                if index < viewsArray.count - 1 {
                    let typeNeeded = viewsArray[index + 1]
                    if let incomingVC = viewControllerForType(type: typeNeeded) {
                        currentView.removeFromParentViewController()
                        currentView.view.removeFromSuperview()
                        
                        self.autoLayoutAddViewController(viewController: incomingVC, intoView: self.view, parentViewController: self)
                        //self.currentView = incomingVC
                        
                        self.updateDelegatePageControl()
                    }
                }
            }
        }
        */
    }
    
    func swipeRight() {
        print("right")
        /*
        if let currentView = currentView {
            // Get the view before this one
            let viewType = keyForView(viewController: currentView)
            let viewsArray = self.viewsArray()
            
            // Find the index of the viewtype, then determine the previous one
            
            if let index = viewsArray.index(of: viewType) {
                if index > 0 {
                    let typeNeeded = viewsArray[index - 1]
                    if let incomingVC = viewControllerForType(type: typeNeeded) {
                        currentView.removeFromParentViewController()
                        currentView.view.removeFromSuperview()
                        
                        self.autoLayoutAddViewController(viewController: incomingVC, intoView: self.view, parentViewController: self)
                        //self.currentView = incomingVC
                        
                        self.updateDelegatePageControl()
                    }
                }
            }
        }
         */
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if pageViewSetup == false {
            setupPageView()
        }
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        
        hideMenu()
        
        let duration = coordinator.transitionDuration
        
        coordinator.animate(alongsideTransition: { (context) in
            
        }) { (context) in
            self.setupPageView()
            self.updateDelegatePageControl()
            
            if let firstView = self.pageViewController?.viewControllers?.first {
                if let keyPad = firstView as? KeypadViewController {
                    keyPad.updateLegalKeys()
                }
            }
        }
    }
    
    
    func setupPageView() {
        
        let currentVC = self.pageViewController?.viewControllers?.first
        
        let currentView = currentViewKey()
        
        if let pageVC = pageViewController {
            pageVC.dataSource = nil
            pageVC.delegate = nil
            pageVC.removeFromParentViewController()
            pageVC.view.removeFromSuperview()
            pageVC.didMove(toParentViewController: nil)
        }
        
        pageViewController = nil;
        
        let viewsArray = self.viewsArray()
        
        // Find the first instance of regular or compactStandard
        
        if viewsArray.contains(currentView) {
            // This new viewarray contains that view, so let's set that up
            
            // Let's try and re-use the currentVC first
            if let currentVC = currentVC {
                setupPageViewController(withViewController: currentVC)
            } else if let vc = viewControllerForType(type: currentView) {
                setupPageViewController(withViewController: vc)
            }
        } else if viewsArray.contains(KeypadViewType.regular) {
            // Couldn't find current view, try and show the regular keypad
            if let vc = viewControllerForType(type: KeypadViewType.regular) {
                setupPageViewController(withViewController: vc)
            }
        } else if viewsArray.contains(KeypadViewType.compactStandard) {
            // Couldn't find current view, try and show the compact standard
            if let vc = viewControllerForType(type: KeypadViewType.compactStandard) {
                setupPageViewController(withViewController: vc)
            }
        } else {
            // Couldn't find any of these views! Just show the first item in the view array.
            if let vc = viewControllerForType(type: viewsArray[0]) {
                setupPageViewController(withViewController: vc)
            }
        }
        
        pageViewSetup = true
        
        if let pageViewController = pageViewController {
            for view in pageViewController.view.subviews {
                if let subView = view as? UIScrollView {
                    // subView.isScrollEnabled = false
                }
            }
        }
        
        
        
        /*
        if let vc = viewControllerWithKeypadLayout(KeypadLayout.compactStandard) {
            // Add this keypad
            
            self.autoLayoutAddViewController(viewController: vc, intoView: self.view, parentViewController: self)
            currentView = vc
        }
         */
    }
    
    func setupPageViewController(withViewController viewController: UIViewController) {
        pageViewController = SwipePageViewController(transitionStyle: .scroll, navigationOrientation: .horizontal, options: nil)
        pageViewController!.view.frame = self.view.bounds
        
        pageViewController!.setViewControllers([viewController], direction: .forward, animated: false, completion: nil)
        
        if let scrollView = pageViewController!.view.subviews.first(where: { $0 is UIScrollView }) as? UIScrollView {
            scrollView.delegate = self
        }
        
        updateDelegatePageControl()
        updateDelegateDatasource()
        
        addChildViewController(pageViewController!)
        view.addSubview(pageViewController!.view)
        pageViewController!.didMove(toParentViewController: self)
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        originalContentOffset = scrollView.contentOffset
        pageIsScrolling = true
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if let originalContentOffset = originalContentOffset {
            self.scrollingOffset = originalContentOffset.x - scrollView.contentOffset.x
        }
    }
    
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        //print("scrollViewDidEndDragging")
        //pageIsScrolling = false
        Timer.scheduledTimer(withTimeInterval: 0.5, repeats: false) { (timer) in
            self.pageIsScrolling = false
            self.originalContentOffset = nil
        }
    }
    
    func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        self.pageIsScrolling = false
        self.originalContentOffset = nil
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        self.pageIsScrolling = false
        self.originalContentOffset = nil
    }
    
    func isPageScrolling() -> Bool {
        if self.pageIsScrolling {
            if let scrollingOffset = scrollingOffset {
                if scrollingOffset < 10 && scrollingOffset > -10 {
                    // We still haven't scrolled enough to consider the page "scrolling"
                    return false
                }
            }
            
            return true
        }
        
        return false
    }
    
    
    func viewIsWide() -> Bool {
        
        // If we are on an iPad, in portrait, and the history is meant to be on the side, then we should report ourselves as NOT wide.
        
        if NumericalViewHelper.isDevicePad() {
            // It's an iPad!
            
            if self.view.frame.width < self.view.frame.height {
                print("self.view.bounds.width: \(self.view.bounds.width)")
                print("")
                if self.view.bounds.width < 650 {
                    // It's an ipad but this view is so thin that really it's more like an iPhone
                    return false
                }
            }
            
            return true
        } else {
            // It's an iPhone
            
            if self.view.frame.width > self.view.frame.height && self.view.bounds.width > 450 {
                // This view is wider than it is tall, so it's actually a wide device
                return true
            } else {
                return false
            }
        }
    }
    
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        
        let viewType = keyForView(viewController: viewController)
        let viewsArray = self.viewsArray()
        
        // Find the index of the viewtype, then determine the previous one
        
        if let index = viewsArray.index(of: viewType) {
            if index > 0 {
                let typeNeeded = viewsArray[index - 1]
                return viewControllerForType(type: typeNeeded)
            }
        }
        
        return nil
        
        /*
        if let currentView = viewController as? KeypadViewController {
            
            if currentView.layoutType == KeypadLayout.compactStandard {
                // Need scientific pad
                if let scientificPad = viewControllerWithKeypadLayout(KeypadLayout.compactScientific) {
                    return scientificPad;
                }
            } else if currentView.layoutType == KeypadLayout.compactScientific {
                if NumericalViewHelper.shouldSettingsScreenBeModal() == false {
                    if let aboutView = viewControllerForAboutView() {
                        return aboutView
                    }
                }
            } else if currentView.layoutType == KeypadLayout.regular {
                if NumericalViewHelper.shouldSettingsScreenBeModal() == false {
                    if let aboutView = viewControllerForAboutView() {
                        return aboutView
                    }
                }
            }
        }
        
        return nil
         */
    }
    
    func viewControllerForType(type: KeypadViewType) -> UIViewController? {
        
        // cachedViewController
        
        if let vc = cachedViewController[type] {
            return vc
        }
        
        switch type {
        case .about:
            if let view = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "AboutViewController") as? AboutViewController {
                cachedViewController[type] = view
                return view
            }
        case .compactScientific:
            if let view = viewControllerWithKeypadLayout(KeypadLayout.compactScientific) {
                cachedViewController[type] = view
                return view
            }
        case .compactStandard:
            if let view = viewControllerWithKeypadLayout(KeypadLayout.compactStandard) {
                return view
            }
        case .history:
            if let view =  UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "HistoryViewController") as? HistoryViewController {
                
                if let delegate = delegate as? WorkPanelViewController {
                    if let delegate = delegate.delegate as? ViewController {
                        view.delegate = delegate
                    }
                }
                // historyVC.updateSelectedEquation()
                
                cachedViewController[type] = view
                return view
            }
        case .regular:
            if let view = viewControllerWithKeypadLayout(KeypadLayout.regular) {
                cachedViewController[type] = view
                return view;
            }
        }
        
        return nil
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController?
    {
        
        let viewType = keyForView(viewController: viewController)
        let viewsArray = self.viewsArray()
        
        // Find the index of the viewtype, then determine the next one
        
        if let index = viewsArray.index(of: viewType) {
            if index < viewsArray.count - 1 {
                let typeNeeded = viewsArray[index + 1]
                return viewControllerForType(type: typeNeeded)
            }
        }
        
        // We could not find anything after the about view, which is likely because we have moved on a view that allows the about screen and one that does not. Just default to the first view.
        if viewType == .about {
            let typeNeeded = viewsArray[0]
            return viewControllerForType(type: typeNeeded)
        }
        
        return nil
        
        /*
        if let currentView = viewController as? KeypadViewController {
            
            if currentView.layoutType == KeypadLayout.compactScientific {
                // Need standard pad
                if let standardPad = viewControllerWithKeypadLayout(KeypadLayout.compactStandard) {
                    return standardPad;
                }
            }
            
            if currentView.layoutType == KeypadLayout.compactStandard {
                // If we need the history view then give that
                
                if let historyVC =  UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "HistoryViewController") as? HistoryViewController {
                    return historyVC
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
         */
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
        
        /*
        if let keyPad = currentView as? KeypadViewController {
            keyPad.setLegalKeys(currentLegalKeys)
        }
 */
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
        let currentView = self.currentViewKey()
        
        let viewsArray = self.viewsArray()
        
        // now find the currentView key in this
        
        if let index = viewsArray.index(of: currentView) {
            return (currentPage: index, numberOfPages: viewsArray.count)
        } else {
            return (currentPage: 0, numberOfPages: viewsArray.count)
        }
    }
    
    func viewsArray() -> [KeypadViewType] {
        var viewsArray = [KeypadViewType]()
        
        if self.viewIsWide() {
            if NumericalViewHelper.scientificKeypadNeeded() {
                viewsArray.append(.regular)
            } else {
                // Just show compact standard
                viewsArray.append(.compactStandard)
            }
            
        } else {
            if NumericalViewHelper.scientificKeypadNeeded() {
                viewsArray.append(.compactScientific)
            }
            viewsArray.append(.compactStandard)
        }
        
        if NumericalViewHelper.historyKeypadNeeded() {
            viewsArray.append(.history)
        }
        
        if viewsArray.contains(KeypadViewType.regular) == false {
            // This view doesn't have the scientific keyboard with the menu button, so it needs an about view that can be swiped to
            viewsArray.insert(.about, at: 0)
        } else if UIScreen.main.traitCollection.userInterfaceIdiom == .phone {
            // We do have the regular pad but this is also an iphone so we still prefer an about view.
            viewsArray.insert(.about, at: 0)
        }
        
        return viewsArray
    }
    
    func currentViewKey() -> KeypadViewType {
        
        if let viewController = pageViewController?.viewControllers?.first {
            return self.keyForView(viewController: viewController)
        }
        
        return .regular
    }
    
    func keyForView(viewController:UIViewController) -> KeypadViewType {
        
        if let keypadViewController = viewController as? KeypadViewController {
            switch keypadViewController.layoutType {
            case .compactScientific:
                return .compactScientific
            case .compactStandard:
                return .compactStandard
            case .regular:
                return .regular
            case .all:
                return .regular
            }
        } else if let _ = viewController as? AboutViewController {
            return .about
        } else if let _ = viewController as? HistoryViewController {
            return .history
        }
        
        return .regular
    }
    
    func updateDelegatePageControl(_ currentPage: NSInteger, numberOfPages: NSInteger) {
        if let theDelegate = pageViewDelegate {
            theDelegate.updatePageControl(currentPage, numberOfPages: numberOfPages)
        }
    }
    
    func disableScrolling() {
        if let pageViewController = pageViewController {
            for view in pageViewController.view.subviews {
                if let subView = view as? UIScrollView {
                    subView.isScrollEnabled = false
                }
            }
        }
    }
    
    func enableScrolling() {
        if let pageViewController = pageViewController {
            for view in pageViewController.view.subviews {
                if let subView = view as? UIScrollView {
                    subView.isScrollEnabled = true
                }
            }
        }
    }
    
}
