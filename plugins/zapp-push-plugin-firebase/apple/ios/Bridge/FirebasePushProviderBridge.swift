//
//  FirebasePushProviderBridge.swift
//  ZappPushPluginFirebase
//
//  Created by Alex Zchut on 05/01/2021.
//  Copyright © 2021 Applicaster Ltd. All rights reserved.
//

import Foundation
import MediaPlayer
import React
import XrayLogger
import ZappCore

@objc(FirebasePushProviderBridge)
class FirebasePushProviderBridge: NSObject, RCTBridgeModule {
    lazy var logger = Logger.getLogger(for: "\(kNativeSubsystemPath)/ZappPushPluginFirebase")

    let pluginIdentifier = "ZappPushPluginFirebase"
    var bridge: RCTBridge!
    var userActivity: NSUserActivity!
    static func moduleName() -> String! {
        return "FirebasePushProviderBridge"
    }

    public class func requiresMainQueueSetup() -> Bool {
        return true
    }

    lazy var providerInstance: APPushProviderFirebase? = {
        FacadeConnector.connector?.pluginManager?.getProviderInstance(identifier: pluginIdentifier) as? APPushProviderFirebase
    }()

    @objc public func subscribeToTopic(_ topic: NSString,
                                       resolver: @escaping RCTPromiseResolveBlock,
                                       rejecter: @escaping RCTPromiseRejectBlock) {
        DispatchQueue.main.async {
            self.providerInstance?.subscribeToTopic(with: topic as String, completion: { success in
                if success {
                    resolver(1)
                } else {
                    rejecter("0", "unable to subscribe to topic", nil)
                }
            })
        }
    }

    @objc public func unsubscribeFromTopic(_ topic: NSString,
                                           resolver: @escaping RCTPromiseResolveBlock,
                                           rejecter: @escaping RCTPromiseRejectBlock) {
        DispatchQueue.main.async {
            self.providerInstance?.unsubscribeFromTopic(with: topic as String, completion: { success in
                if success {
                    resolver(1)
                } else {
                    rejecter("0", "unable to unsubscribe from topic", nil)
                }
            })
        }
    }
}
