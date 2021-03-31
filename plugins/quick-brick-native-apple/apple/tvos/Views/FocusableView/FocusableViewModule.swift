//
//  FocusableViewModule.swift
//  QuickBrickApple
//
//  Created by Anton Kononenko on 4/18/19.
//  Copyright © 2019 Anton Kononenko. All rights reserved.
//

import Foundation
import React

@objc(FocusableViewModule)
public class FocusableViewModule: RCTViewManager {
    static let focusableViewModuleName = "FocusableViewModule"
    
    override public static func moduleName() -> String? {
        return focusableViewModuleName
    }
    
    override public class func requiresMainQueueSetup() -> Bool {
        return true
    }
    
    override open var methodQueue: DispatchQueue {
        return bridge.uiManager.methodQueue
    }
    
    override public func view() -> UIView? {
        return FocusableView()
    }
    
}
