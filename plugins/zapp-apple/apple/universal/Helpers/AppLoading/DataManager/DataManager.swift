//
//  DataManager.swift
//  ZappApple
//
//  Created by Anton Kononenko on 11/14/18.
//  Copyright © 2018 Anton Kononenko. All rights reserved.
//

import Foundation
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
        var videoPath = AssetsKeys.splashVideoKey

        #if os(iOS)
            videoPath = LocalSplashHelper.localSplashVideoNameForScreenSize()
        #endif

        return Bundle.main.path(forResource: videoPath,
                                ofType: DataKeysExtensions.mp4)
    }

    class func zappStylesPath() -> String? {
        return Bundle.main.path(forResource: DataManager.stylesFileName,
                                ofType: DataKeysExtensions.json)
    }
}
