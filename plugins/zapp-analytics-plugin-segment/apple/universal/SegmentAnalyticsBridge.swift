//
//  SegmentAnalyticsBridge.swift
//  SegmentAnalytics
//
//  Created by Alex Zchut on 10/03/2021.
//  Copyright © 2021 Applicaster Ltd. All rights reserved.
//

import React
import ZappCore

@objc(SegmentAPI)
class SegmentAnalyticsBridge: NSObject, RCTBridgeModule {
    fileprivate let pluginIdentifier = "segment_analytics"
    var bridge: RCTBridge!

    static func moduleName() -> String! {
        return "SegmentAPI"
    }

    public class func requiresMainQueueSetup() -> Bool {
        return true
    }

    /// prefered thread on which to run this native module
    @objc public var methodQueue: DispatchQueue {
        return DispatchQueue.main
    }

    @objc public func identifyUser(_ userID: String,
                                   traits: NSDictionary?,
                                   options: NSDictionary?) {
        guard let provider = FacadeConnector.connector?.pluginManager?.getProviderInstance(identifier: pluginIdentifier) as? SegmentAnalytics,
              let traits = traits as? [String: Any],
              let options = options as? [String: Any] else {
            return
        }

        provider.login(with: userID,
                       traits: traits,
                       options: options)
    }
}
