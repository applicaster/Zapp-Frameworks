//
//  FocusableManagerModule.swift
//  QuickBrickApple
//
//  Created by Anton Kononenko on 6/28/19.
//  Copyright © 2019 Anton Kononenko. All rights reserved.
//

import Foundation
import React

let kFocusableManagerModule = "FocusableManagerModule"

@objc(FocusableManagerModule)
class FocusableManagerModule: NSObject, RCTBridgeModule {
    
    /// Delay timer before focus will be invoked, was done to resolve async problems.
    /// Sometimes focusale item did has superview when it render that may cayse glitches.
    var delayTimer = 100
    
    /// main React bridge
    public var bridge: RCTBridge?
    
    
    static func moduleName() -> String! {
        return kFocusableManagerModule
    }
    
    public class func requiresMainQueueSetup() -> Bool {
        return true
    }
    
    /// prefered thread on which to run this native module
    @objc public var methodQueue: DispatchQueue {
        return DispatchQueue.main
    }
    
    
    /// Updates next preffered focus item for focusable group
    ///
    /// - Parameters:
    ///   - groupId: id of the focusable group
    ///   - itemId: id of the focusable item
    /// - Note: This method not forcing to focus on item it just saves next preffered focus item to focus for current group
    @objc func setPreferredFocus(_ groupId: String?, itemId: String?) {
        // We need delay to make sure that on native side group will have superview
        let delay = DispatchTime.now() + DispatchTimeInterval.milliseconds(delayTimer)
        
        DispatchQueue.main.asyncAfter(deadline: delay)  {
            FocusableGroupManager.updateFocus(groupId,
                                              itemId: itemId)
        }
        
    }
    
    /// Force updates next preffered focus item for focusable group
    ///
    /// - Parameters:
    ///   - groupId: id of the focusable group
    ///   - itemId: id of the focusable item
    /// - Note: This method is forcing focus engine to focus on focusable item in focusable group
    @objc func forceFocus(_ groupId: String?, itemId: String?, callback:RCTResponseSenderBlock?) {
        // We need delay to make sure that on native side group will have superview
        let delay = DispatchTime.now() + DispatchTimeInterval.milliseconds(delayTimer)
        
        DispatchQueue.main.asyncAfter(deadline: delay)  {
            FocusableGroupManager.updateFocus(groupId,
                                              itemId: itemId,
                                              needsForceUpdate: true, completion: { (succeed) in
                                                callback?([succeed])
                                                
            })
        }
    }
}

