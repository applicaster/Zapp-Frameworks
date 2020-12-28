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
    class func layerAdapter(launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> UserInterfaceLayerProtocol? {
        let logger = Logger.getLogger(for: UserInterfaceLayerMangerLogs.subsystem)

        guard let UserInterfaceLayer = NSClassFromString("QuickBrickApple.ReactNativeManager") as? UserInterfaceLayerProtocol.Type else {
            logger?.errorLog(template: UserInterfaceLayerMangerLogs.canNotCreateUserInterfaceLayer)
            return nil
        }

        let sessionStorage = SessionStorage.sharedInstance
        let bundleIndentifier = sessionStorage.get(key: ZappStorageKeys.bundleIdentifier,
                                                   namespace: nil)
        let accountsAccountId = sessionStorage.get(key: ZappStorageKeys.accountsAccountId,
                                                   namespace: nil)
        let deviceType = sessionStorage.get(key: ZappStorageKeys.deviceType,
                                            namespace: nil)
        let reactNativePackagerRoot = sessionStorage.get(key: ZappStorageKeys.reactNativePackagerRoot,
                                                         namespace: nil)
        let applicationData = [
            "bundleIdentifier": bundleIndentifier as Any,
            "accountsAccountId": accountsAccountId as Any,
            "os_type": "ios" as Any,
            "uuid": UUIDManager.deviceID as Any,
            "languageLocale": NSLocale.current.languageCode as Any,
            "countryLocale": NSLocale.current.regionCode as Any,
            "platform": deviceType as Any,
            "reactNativePackagerRoot": reactNativePackagerRoot as Any,
            "isTabletPortrait": FeaturesCustomization.isTabletPortrait()
        ]
        
        logger?.debugLog(template: UserInterfaceLayerMangerLogs.canNotCreateUserInterfaceLayer,
                         data: applicationData)
        // TODO: In case we will have more plugins this implamentation must be rewritten to get first layer plugin not quick brick
        return UserInterfaceLayer.init(launchOptions: launchOptions,
                                  applicationData: applicationData)
    }
}
