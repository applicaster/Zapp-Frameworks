//
//  OptaBridge.swift
//  OptaStats
//
//  Created by Alex Zchut on 11/04/2021.
//  Copyright © 2021 Applicaster Ltd. All rights reserved.
//

import React
import ZappCore

@objc(OptaBridge)
class OptaBridge: NSObject, RCTBridgeModule {
    fileprivate let pluginIdentifier = "quick-brick-opta-stats"
    var bridge: RCTBridge!

    static func moduleName() -> String! {
        return String(describing: Self.self)
    }

    public class func requiresMainQueueSetup() -> Bool {
        return true
    }

    /// prefered thread on which to run this native module
    @objc public var methodQueue: DispatchQueue {
        return DispatchQueue.main
    }

    lazy var pluginInstance: OptaStats? = {
        FacadeConnector.connector?.pluginManager?.getProviderInstance(identifier: pluginIdentifier) as? OptaStats
    }()
    
    @objc public func showScreen(_ screenArguments: NSDictionary,
                                        resolver: @escaping RCTPromiseResolveBlock,
                                        rejecter: @escaping RCTPromiseRejectBlock) {
        guard let pluginInstance = self.pluginInstance else {
            rejecter("failure", "plugin not available", nil)
            return
        }

        pluginInstance.showScreen(with: screenArguments) { (success) in
            if success {
                resolver(true)
            } else {
                rejecter("0", "Unable to present screen", nil)
            }
        }
    }
}
