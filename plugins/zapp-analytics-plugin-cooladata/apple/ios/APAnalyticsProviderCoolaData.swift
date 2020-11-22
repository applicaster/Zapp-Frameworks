//
//  APAnalyticsProviderCoolaData.swift
//  ZappAnalyticsPluginCoolaData
//
//  Created by Alex Zchut on 22/11/2020.
//  Copyright © 2020 Applicaster. All rights reserved.
//

import ZappAnalyticsPluginsSDK
import ZappCore

open class APAnalyticsProviderCoolaData: ZPAnalyticsProvider, PlayerDependantPluginProtocol {
    let kDebugAppId = "mobile_app_account_id"
    let kProductionAddId = "mobile_app_account_id_production"
    public var playerPlugin: PlayerProtocol?
    var cooladataAnalytics: CoolaDataAnalytics?
    var playbackStalled: Bool = false

    override open func getKey() -> String {
        return "cooladata"
    }

    override open func configureProvider() -> Bool {
        guard let debugAppId = providerProperties[kDebugAppId] as? String,
              debugAppId.isNotEmptyOrWhiteSpaces(),
              let productionAddId = providerProperties[kProductionAddId] as? String,
              productionAddId.isNotEmptyOrWhiteSpaces() else {
            return false
        }

        cooladataAnalytics = CoolaDataAnalytics(providerProperties: providerProperties,
                                        delegate: self)

        return true
    }

    override open func trackEvent(_ eventName: String, timed: Bool) {
        super.trackEvent(eventName, timed: timed)
        cooladataAnalytics?.trackEvent(eventName, timed: timed)
    }

    override open func trackEvent(_ eventName: String) {
        super.trackEvent(eventName)
        cooladataAnalytics?.trackEvent(eventName)
    }

    override open func trackEvent(_ eventName: String, parameters: [String: NSObject]) {
        super.trackEvent(eventName, parameters: parameters)
        cooladataAnalytics?.trackEvent(eventName, parameters: parameters)
    }

    override open func trackScreenView(_ screenName: String, parameters: [String: NSObject]) {
        super.trackScreenView(screenName, parameters: parameters)
        cooladataAnalytics?.trackScreenView(screenName, parameters: parameters)
    }
}


