//
//  ChromecastExpandedMediaControlsViewController.swift
//  ZappChromecast
//
//  Created by Alex Zchut on 4/12/2020
//  Copyright © 2020 Applicaster. All rights reserved.
//

import Foundation
import ZappCore

open class ChromecastExpandedMediaControlsViewController: UIViewController {

    open weak var chromecastAdapter: ChromecastAdapter?
    
    init(adapter: ChromecastAdapter?) {
        super.init(nibName: nil, bundle: nil)
        chromecastAdapter = adapter
    }

    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public func isExpandedMediaControlsViewControllerAvailable() -> Bool {
        guard let _ = chromecastAdapter?.defaultExpandedMediaControlsViewController() else {
            return false
        }
        
        return true
    }
    
    open override func viewDidLoad() {
        
        super.viewDidLoad()
        
        //Insert chromecastExpandedViewController.view inside self.view
        if let chromecastViewController = chromecastAdapter?.defaultExpandedMediaControlsViewController() {
            self.addChild(chromecastViewController)
            
            //Update chromecast button
            chromecastAdapter?.lastActiveChromecastButton = .expendedNavbar
            
            //Send event when expanded controls going to be shown on screen
            if let triggedChromecastButton = chromecastAdapter?.triggeredChromecastButton {
                ChromecastAnalytics.sendOpenExpandedControlsEvent(triggeredChromecastButton: triggedChromecastButton)
            }
        }
    }
    
    open override func viewDidDisappear(_ animated: Bool) {
        //Send event when expanded controls going to be dismiss from the screen
        if let triggedChromecastButton = chromecastAdapter?.triggeredChromecastButton {
            ChromecastAnalytics.sendCloseExpandedControlsEvent(triggeredChromecastButton: triggedChromecastButton)
        }
        
        super.viewDidDisappear(animated)
    }
    
    override open var shouldAutorotate: Bool {
        return true
    }
    
    override open var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .all
    }
    
    override open func addChild(_ childController: UIViewController) {
        super.addChild(childController)
        self.view.addSubview(childController.view)
        childController.view.frame = self.view.bounds
        childController.didMove(toParent: self)
    }
}
