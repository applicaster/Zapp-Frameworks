//
//  DidomiBridge.swift
//  ConsentManagementDidomi
//
//  Created by Alex Zchut on 29/03/2021.
//  Copyright © 2021 Applicaster Ltd. All rights reserved.
//

import React
import ZappCore

@objc(DidomiBridge)
class DidomiBridge: NSObject, RCTBridgeModule {
    fileprivate let pluginIdentifier = "applicaster-cmp-didomi"
    var bridge: RCTBridge!

    static func moduleName() -> String! {
        return "DidomiBridge"
    }

    public class func requiresMainQueueSetup() -> Bool {
        return true
    }

    /// prefered thread on which to run this native module
    @objc public var methodQueue: DispatchQueue {
        return DispatchQueue.main
    }

    var pluginInstance: DidomiCMP? {
        guard let provider = FacadeConnector.connector?.pluginManager?.getProviderInstance(identifier: pluginIdentifier) as? DidomiCMP else {
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
