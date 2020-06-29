//
//  ChromecastAdapter+ChromecastMiniPlayerViewControllerProtocol.swift
//  ZappChromecast
//
//  Created by Alex Zchut on 4/12/2020
//  Copyright © 2020 Applicaster. All rights reserved.
//

import Foundation
import GoogleCast
import ZappCore

extension ChromecastAdapter : ChromecastMiniPlayerViewControllerProtocol {
    public func createMiniPlayerViewController() {
        if GCKCastContext.isSharedInstanceInitialized(),
            self.miniMediaControlsViewController == nil {
            //add listener to session changes
            GCKCastContext.sharedInstance().sessionManager.add(self);

            self.miniMediaControlsViewController = GCKCastContext.sharedInstance().createMiniMediaControlsViewController()
            self.miniMediaControlsViewController?.delegate = self
        }
    }
    
    public func getMiniMediaControlsViewController() -> UIViewController? {
        return self.miniMediaControlsViewController
    }

    public func uninstallMiniPlayerViewController() {
        if let controlsViewController = self.miniMediaControlsViewController,
            let heightConstraint = self.localContainerViewEventsDelegate?.chromecastContainerViewHeightConstraint(),
            let parentViewController = self.localContainerViewEventsDelegate?.chromecastContainerParentViewController() {

            controlsViewController.willMove(toParent: nil)
            controlsViewController.view.removeFromSuperview()
            controlsViewController.removeFromParent()

            //remove
            heightConstraint.constant = 0
            self.updateParentViewControllerLayout(parentViewController, needToNotifyListeners: false, completion: {
                //do nothing
            })
        }
    }

    public func updateVisibilityOfMiniPlayerViewController() {
        self.updateVisibilityOfMiniPlayerViewController(completion: nil)
    }
    
    fileprivate func installMiniPlayerViewController() {

        if let container = self.localContainerViewEventsDelegate?.chromecastContainerView(),
            let parentViewController = self.localContainerViewEventsDelegate?.chromecastContainerParentViewController(),
            let controlsViewController = self.miniMediaControlsViewController {

            if controlsViewController.parent == nil {

                controlsViewController.view.translatesAutoresizingMaskIntoConstraints = false

                //add child view controller
                parentViewController.addChild(controlsViewController)

                //add subview
                container.addSubview(controlsViewController.view)

                //set constraints
                let views = ["view": controlsViewController.view as UIView]
                container.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[view]|", options: .alignAllCenterX, metrics: nil, views: views))
                container.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[view]|", options: .alignAllCenterY, metrics: nil, views: views))

                //mode to parent
                controlsViewController.didMove(toParent: parentViewController)
            }
        }
    }

    func updateVisibilityOfMiniPlayerViewController(needUpdateAppearance: Bool = true) {
        self.updateVisibilityOfMiniPlayerViewController(needUpdateAppearance: needUpdateAppearance, completion: nil)
    }

    func updateVisibilityOfMiniPlayerViewController(needUpdateAppearance: Bool = true, completion:(() -> Void)?) {

        if let containerView = self.localContainerViewEventsDelegate?.chromecastContainerView(),
            let heightConstraint = self.localContainerViewEventsDelegate?.chromecastContainerViewHeightConstraint(),
            let parentViewController = self.localContainerViewEventsDelegate?.chromecastContainerParentViewController(),
            let controlsViewController = self.miniMediaControlsViewController {

            //install if not installed before
            self.installMiniPlayerViewController()

            var needToNotifyListeners: Bool = needUpdateAppearance
            if controlsViewController.active {
                if heightConstraint.constant != controlsViewController.minHeight {
                    heightConstraint.constant = controlsViewController.minHeight
                }
                else {
                    //no need to update if no change
                    needToNotifyListeners = false
                }

                parentViewController.view.bringSubviewToFront(containerView)
            }
            else {
                if heightConstraint.constant > 0 {
                    heightConstraint.constant = 0
                }
                else {
                    //no need to update if no change
                    needToNotifyListeners = false
                }
            }
            self.updateParentViewControllerLayout(parentViewController, needToNotifyListeners: needToNotifyListeners, completion: completion)
        }
        else if self.miniMediaControlsViewController == nil {
            //delay in updating mini controls because this event received too early before creating them
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                self.updateVisibilityOfMiniPlayerViewController(needUpdateAppearance: needUpdateAppearance, completion: completion)
            }
        }
    }

    fileprivate func updateParentViewControllerLayout(_ parentViewController: UIViewController, needToNotifyListeners: Bool, completion:(() -> Void)?) {
        completion?()
    }
}
