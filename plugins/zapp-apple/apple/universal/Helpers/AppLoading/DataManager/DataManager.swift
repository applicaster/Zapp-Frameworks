//
//  DataManager.swift
//  ZappApple
//
//  Created by Anton Kononenko on 11/14/18.
//  Copyright © 2018 Applicaster LTD. All rights reserved.
//

import Foundation
import XrayLogger

let stateMachineLogCategory = "State Machine"

class DataManager {
    static var stylesFileName = "ZappStyles"

    struct ApplicationFiles {
        static let featureCustomization = "FeaturesCustomization"
    }

    struct DataKeysExtensions {
        static let mp4 = "mp4"
        static let json = "json"
        static let plist = "plist"
    }

    class func splashVideoPath() -> String? {
        let logger = Logger.getLogger(for: SplashViewControllerDataManagerLogs.subsystem)

        var videoPath = AssetsKeys.splashVideoKey

        #if os(iOS)
            videoPath = LocalSplashHelper.localSplashVideoNameForScreenSize()
        #endif
        let retVal = Bundle.main.path(forResource: videoPath,
                                      ofType: DataKeysExtensions.mp4)
        logger?.debugLog(template: SplashViewControllerDataManagerLogs.splashVideoPath,
                         data: ["url": videoPath,
                                "item_exist": retVal != nil])

        return retVal
    }

    class func zappStylesPath() -> String? {
        let logger = Logger.getLogger(for: SplashViewControllerDataManagerLogs.subsystem)
        let retVal = Bundle.main.path(forResource: DataManager.stylesFileName,
                                      ofType: DataKeysExtensions.json)
        logger?.debugLog(template: SplashViewControllerDataManagerLogs.stylePath,
                         data: ["url": "\(DataManager.stylesFileName).\(DataKeysExtensions.json)",
                                "item_exist": retVal != nil])
        return retVal
    }
}
