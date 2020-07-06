//
//  ChromecastAdapterBridge.swift
//  ZappGeneralPluginChromecast
//
//  Created by Alex Zchut on 29/03/2020.
//  Copyright © 2020 Applicaster. All rights reserved.
//

import Foundation
import React

@objc(ChromecastButtonManager)
public class ChromecastButtonManager: RCTViewManager {
    static let chromecastModuleName = "ChromecastButton"

    override public static func moduleName() -> String? {
        return ChromecastButtonManager.chromecastModuleName
    }
    
    override public class func requiresMainQueueSetup() -> Bool {
        return true
    }
    
    override open var methodQueue: DispatchQueue {
        return bridge.uiManager.methodQueue
    }
    
    override public func view() -> UIView? {
        guard let eventDispatcher = bridge?.eventDispatcher() else {
            return nil
        }
        return ChromecastButton(eventDispatcher: eventDispatcher)
    }
}
