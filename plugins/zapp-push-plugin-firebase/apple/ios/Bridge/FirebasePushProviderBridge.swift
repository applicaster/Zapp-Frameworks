//
//  FirebasePushProviderBridge.swift
//  ZappPushPluginFirebase
//
//  Created by Alex Zchut on 05/01/2021.
//  Copyright © 2021 Applicaster Ltd. All rights reserved.
//

import Foundation
import React
import ZappCore
import MediaPlayer
import XrayLogger

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
    
    lazy var providerInstance:APPushProviderFirebase? = {
        return FacadeConnector.connector?.pluginManager?.getProviderInstance(identifier: pluginIdentifier) as? APPushProviderFirebase
    }()

    @objc public func subscribeToTopic(_ topic: NSString) {
        providerInstance?.subscribeToTopic(with: topic as String)
    }
    
    @objc public func subscribeToTopics(_ topics: NSArray) {
        guard let topics = topics as? [String] else {
            return
        }
        providerInstance?.subscribeToTopics(with: topics)
    }
    
    @objc public func unsubscribeFromTopic(_ topic: NSString) {
        providerInstance?.unsubscribeFromTopic(with: topic as String)
    }
    
    @objc public func unsubscribeFromTopics(_ topics: NSArray) {
        guard let topics = topics as? [String] else {
            return
        }
        providerInstance?.unsubscribeFromTopics(with: topics)
    }
    

}
