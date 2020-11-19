//
//  APAnalyticsProviderAkamai.swift
//  ZappAnalyticsPluginAkamai
//
//  Created by Alex Zchut on 13/07/2016.
//  Copyright © 2016 Applicaster. All rights reserved.
//

import ZappAnalyticsPluginsSDK
import ZappCore

open class APAnalyticsProviderAkamai: ZPAnalyticsProvider, PlayerDependantPluginProtocol {
    let kVodBeaconsKey = "vod_beacons"
    let kLiveBeaconsKey = "live_beacons"
    let kAPIdentityClientDeviceIDKey = "identity_client_device_id"
    public var playerPlugin: PlayerProtocol?
    var akamaiClient: APAkamaiClient?

    override open func getKey() -> String {
        return "akamai"
    }

    override open func configureProvider() -> Bool {
        guard let configUrlVOD = providerProperties[kVodBeaconsKey] as? String,
            configUrlVOD.isNotEmptyOrWhiteSpaces(),
            let deviceID = baseProperties[kAPIdentityClientDeviceIDKey] as? String else {
            return false
        }

        if let configUrlLive = providerProperties[kLiveBeaconsKey] as? String,
            configUrlLive.isNotEmptyOrWhiteSpaces() {
            akamaiClient = APAkamaiClient(configURL: configUrlVOD, liveOverrideConfigURL: configUrlLive, andDeviceID: deviceID)
        } else {
            akamaiClient = APAkamaiClient(configURL: configUrlVOD, andDeviceID: deviceID)
        }

        return true
    }
}
 