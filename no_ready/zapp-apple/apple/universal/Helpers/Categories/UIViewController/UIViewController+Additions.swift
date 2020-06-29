//
//  UIViewController+Additions.swift
//  ZappApple
//
//  Created by Anton Kononenko on 10/15/19.
//  Copyright © 2019 Anton Kononenko. All rights reserved.
//

import UIKit

extension UIViewController {
    func topMostModalViewController() -> UIViewController? {
        var retVal = self
        while retVal.presentedViewController != nil {
            if let presentedViewController = retVal.presentedViewController {
                retVal = presentedViewController
            }
        }
        return retVal
    }
    
    func addChildViewController(childController:UIViewController, to view:UIView) {
        addChild(childController)
        view.addSubview(childController.view)
        childController.view.matchParent()
        childController.didMove(toParent: self)
    }
    
    func removeViewControllerFromParent() {
        willMove(toParent: nil)
        view.removeFromSuperview()
        removeFromParent()
    }
}
