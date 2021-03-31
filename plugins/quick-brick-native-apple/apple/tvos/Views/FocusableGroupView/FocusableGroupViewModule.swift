//
//  FocusableGroupViewModule.swift
//  QuickBrickApple
//
//  Created by Anton Kononenko on 3/1/19.
//  Copyright © 2019 Anton Kononenko. All rights reserved.
//

import Foundation
import React

@objc(FocusableGroupViewModule)
public class FocusableGroupViewModule: RCTViewManager {
    static let focusableGroupViewModuleName = "FocusableGroupViewModule"
    
    override public static func moduleName() -> String? {
        return focusableGroupViewModuleName
    }
    
    override public class func requiresMainQueueSetup() -> Bool {
        return true
    }
    
    override open var methodQueue: DispatchQueue {
        return bridge.uiManager.methodQueue
    }
    
    override public func view() -> UIView? {
        let retVal = FocusableGroupView()
        retVal.manager = self
        return retVal
    }
    
    public func viewFromReactTag(reactTag:NSNumber?) -> RCTTVView? {
        guard let reactTag = reactTag else {
            return nil
        }
        return self.bridge.uiManager.view(forReactTag: reactTag) as? RCTTVView
    }
}
