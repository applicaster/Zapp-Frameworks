//
//  ZPAppleVideoSubscriberSSOBridge.swift
//  ZappAppleVideoSubscriberSSO
//
//  Created by Alex Zchut on 20/03/2020.
//  Copyright © 2020 Applicaster Ltd. All rights reserved.
//

import Foundation
import React
import ZappCore

@objc(AppleVideoSubscriberSSO)
class ZPAppleVideoSubscriberSSOBridge: NSObject, RCTBridgeModule {
    let pluginIdentifier = "video_subscriber_sso_apple"
    var bridge: RCTBridge!

    static func moduleName() -> String! {
        return "AppleVideoSubscriberSSO"
    }

    public class func requiresMainQueueSetup() -> Bool {
        return true
    }

    @objc public func requestSso(_ resolver: @escaping RCTPromiseResolveBlock,
                                 rejecter: @escaping RCTPromiseRejectBlock) {
        DispatchQueue.main.async {
            FacadeConnector.connector?.pluginManager?.enablePlugin(identifier: self.pluginIdentifier,
                                                                   completion: { success in
                                                                       if success {
                                                                           resolver(true)
                                                                       } else {
                                                                           rejecter("0", "Not Authorized", nil)
                                                                       }
            })
        }
    }
}
