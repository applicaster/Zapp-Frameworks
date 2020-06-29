//
//  StoragesConsts.swift
//  ZappApple
//
//  Created by Anton Kononenko on 5/9/19.
//  Copyright © 2019 Anton Kononenko. All rights reserved.
//

import Foundation

public let zappLocalStorageName = "zapp_local_storage"

public struct ZappStorageKeys {
    public static let applicationName = "app_name"
    public static let bucketId = "bucket_id"
    public static let versionId = "version_id"
    public static let versionName = "version_name"
    public static let buildVersion = "build_version"
    public static let accountId = "zapp_account_id"
    public static let accountsAccountId = "accountsAccountID"
    public static let apiSecretKey = "apiSecretKey"
    public static let appFamilyId = "app_family_id"
    public static let broadcasterExtensions = "broadcasterExtensions"
    public static let broadcasterId = "broadcasterId"
    public static let bundleIdentifier = "bundleIdentifier"
    public static let languageCode = "languageCode"
    public static let locale = "locale"
    public static let platform = "platform"
    public static let store = "store"
    public static let regionCode = "regionCode"
    public static let uuid = "uuid"
    public static let tvOS = "tvOS"
    public static let iOS = "iOS"
    public static let idfa = "idfa"
    public static let advertisingIdentifier = "advertisingIdentifier"
    public static let deviceType = "deviceType"
    public static let deviceWidth = "deviceWidth"
    public static let deviceHeight = "deviceHeight"
    public static let deviceModel = "device_model"
    public static let deviceMake = "device_make"
    public static let applicaster = "applicaster"
    public static let applicasterVersion = "applicaster2"
    public static let zapp = "zapp"
    public static let applicasterNamespace = "applicaster.v2"
    
    public static let reactNativePackagerRoot = "react_native_package_root"
    public static let riversConfigurationId = "rivers_configuration_id"
    public static let sdkVersion = "sdk_version"
    public static let isRtl = "is_rtl"

    public static let assetsUrl = "asset_url"
    public static let stylesUrl = "styles_url"
    public static let remoteConfigurationUrl = "remote_configuration_url"
    public static let pluginConfigurationUrl = "plugin_configuration_url"
    public static let riversUrl = "rivers_url"
}

//Example of the expected json
/*
 {
     zapp : {
        applicaster.v2 : {
            "applicaster_account: 123
        },
        my_plugin_namespace : {
            credentials: "123"
        }
     }
 }
*/
