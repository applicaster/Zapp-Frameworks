//
//  UserInterfaceLayerManager.swift
//  QuickBrick
//
//  Created by Anton Kononenko on 9/25/19.
//  Copyright © 2019 Applicaster LTD. All rights reserved.
//

import Foundation
import XrayLogger
import ZappCore

class UserInterfaceLayerManager {
    static let adapterClass = "QuickBrickApple.ReactNativeManager"
    
    class func interfaceLayerAdapterClass(from className: String) -> UserInterfaceLayerProtocol.Type? {
        guard let userInterfaceLayer = NSClassFromString(adapterClass) as? UserInterfaceLayerProtocol.Type else {
            return nil
        }
        return userInterfaceLayer
    }
    
    class func canCreate() -> Bool {
        let logger = Logger.getLogger(for: UserInterfaceLayerMangerLogs.subsystem)

        guard let _ = interfaceLayerAdapterClass(from: adapterClass) else {
            logger?.errorLog(template: UserInterfaceLayerMangerLogs.canNotCreateUserInterfaceLayer)
            return false
        }
        return true
    }
    
    class func layerAdapter(launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> UserInterfaceLayerProtocol? {
        let logger = Logger.getLogger(for: UserInterfaceLayerMangerLogs.subsystem)

        guard let userInterfaceLayer = interfaceLayerAdapterClass(from: adapterClass) else {
            return nil
        }

        let sessionStorage = SessionStorage.sharedInstance
        let bundleIndentifier = sessionStorage.get(key: ZappStorageKeys.bundleIdentifier,
                                                   namespace: nil)
        let accountId = sessionStorage.get(key: ZappStorageKeys.accountId,
                                           namespace: nil)
        let accountsAccountId = sessionStorage.get(key: ZappStorageKeys.accountsAccountId,
                                                   namespace: nil)
        let broadcasterId = sessionStorage.get(key: ZappStorageKeys.broadcasterId,
                                               namespace: nil)
        let apiSecretKey = sessionStorage.get(key: ZappStorageKeys.apiSecretKey,
                                              namespace: nil)
        let deviceType = sessionStorage.get(key: ZappStorageKeys.deviceType,
                                            namespace: nil)
        let reactNativePackagerRoot = sessionStorage.get(key: ZappStorageKeys.reactNativePackagerRoot,
                                                         namespace: nil)
        
        let languageCode = sessionStorage.get(key: ZappStorageKeys.languageCode,
                                                         namespace: nil)
        let applicationData = [
            "bundleIdentifier": bundleIndentifier as Any,
            "accountId": accountId as Any,
            "accountsAccountId": accountsAccountId as Any,
            "broadcasterId": broadcasterId as Any,
            "apiSecretKey": apiSecretKey as Any,
            "os_type": "ios" as Any,
            "uuid": UUIDManager.deviceID as Any,
            "languageLocale": languageCode as Any,
            "countryLocale": NSLocale.current.regionCode as Any,
            "platform": deviceType as Any,
            "reactNativePackagerRoot": reactNativePackagerRoot as Any,
            "isTabletPortrait": FeaturesCustomization.isTabletPortrait(),
        ]

        logger?.debugLog(template: UserInterfaceLayerMangerLogs.canNotCreateUserInterfaceLayer,
                         data: applicationData)
        // TODO: In case we will have more plugins this implamentation must be rewritten to get first layer plugin not quick brick
        return userInterfaceLayer.init(launchOptions: launchOptions,
                                  applicationData: applicationData)
    }
}
