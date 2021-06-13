//
//  OneTrustBridge.swift
//  ZappCmpOneTrust
//
//  Created by Alex Zchut on 13/06/2021.
//  Copyright © 2021 Applicaster Ltd. All rights reserved.
//

import React
import ZappCore

@objc(OneTrustBridge)
class OneTrustBridge: NSObject, RCTBridgeModule {
    fileprivate let pluginIdentifier = "applicaster-cmp-onetrust"
    var bridge: RCTBridge!

    static func moduleName() -> String! {
        return "OneTrustBridge"
    }

    public class func requiresMainQueueSetup() -> Bool {
        return true
    }

    /// prefered thread on which to run this native module
    @objc public var methodQueue: DispatchQueue {
        return DispatchQueue.main
    }

    var pluginInstance: OneTrustCmp? {
        guard let provider = FacadeConnector.connector?.pluginManager?.getProviderInstance(identifier: pluginIdentifier) as? OneTrustCmp else {
            return nil
        }
        return provider
    }

    @objc public func showPreferences(_ resolver: @escaping RCTPromiseResolveBlock,
                                   rejecter: @escaping RCTPromiseRejectBlock) {
        guard let pluginInstance = self.pluginInstance else {
            rejecter("failure", "plugin not available", nil)
            return
        }

        let result = pluginInstance.showPreferences()

        if result.success {
            resolver(result.success)
        } else {
            rejecter("failure", result.errorDescription ?? "", nil)
        }
    }

    @objc public func showNotice(_ resolver: @escaping RCTPromiseResolveBlock,
                                 rejecter: @escaping RCTPromiseRejectBlock) {
        guard let pluginInstance = self.pluginInstance else {
            rejecter("failure", "plugin not available", nil)
            return
        }

        let result = pluginInstance.showNotice()

        if result.success {
            resolver(result.success)
        } else {
            rejecter("failure", result.errorDescription ?? "", nil)
        }
    }
}
