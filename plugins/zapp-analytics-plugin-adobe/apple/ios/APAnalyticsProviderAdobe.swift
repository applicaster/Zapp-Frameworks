//
//  APAnalyticsProviderAdobe.swift
//  ZappAnalyticsPluginAdobe
//
//  Created by Alex Zchut on 22/11/2020.
//  Copyright © 2020 Applicaster. All rights reserved.
//

import ZappAnalyticsPluginsSDK
import ZappCore

open class APAnalyticsProviderAdobe: ZPAnalyticsProvider, PlayerDependantPluginProtocol {
    let kDebugAppId = "mobile_app_account_id"
    let kProductionAddId = "mobile_app_account_id_production"
    public var playerPlugin: PlayerProtocol?
    var adobeAnalytics: AdobeAnalytics?
    var playbackStalled: Bool = false

    override open func getKey() -> String {
        return "adobe"
    }

    override open func configureProvider() -> Bool {
        guard let debugAppId = providerProperties[kDebugAppId] as? String,
              debugAppId.isNotEmptyOrWhiteSpaces(),
              let productionAddId = providerProperties[kProductionAddId] as? String,
              productionAddId.isNotEmptyOrWhiteSpaces() else {
            return false
        }

        adobeAnalytics = AdobeAnalytics(providerProperties: providerProperties,
                                        delegate: self)

        return true
    }

    override open func trackEvent(_ eventName: String, timed: Bool) {
        super.trackEvent(eventName, timed: timed)
        adobeAnalytics?.trackEvent(eventName, timed: timed)
    }

    override open func trackEvent(_ eventName: String) {
        super.trackEvent(eventName)
        adobeAnalytics?.trackEvent(eventName)
    }

    override open func trackEvent(_ eventName: String, parameters: [String: NSObject]) {
        super.trackEvent(eventName, parameters: parameters)
        adobeAnalytics?.trackEvent(eventName, parameters: parameters)
    }

    override open func trackScreenView(_ screenName: String, parameters: [String: NSObject]) {
        super.trackScreenView(screenName, parameters: parameters)
        adobeAnalytics?.trackScreenView(screenName, parameters: parameters)
    }
    
    open override func setUserProfile(genericUserProperties dictGenericUserProperties: [String : NSObject], piiUserProperties dictPiiUserProperties: [String : NSObject]) {
        super.setUserProfile(genericUserProperties: dictGenericUserProperties, piiUserProperties: dictGenericUserProperties)
        adobeAnalytics?.setUserProfileWithGenericUserProperties(dictGenericUserProperties,
                                                                piiUserProperties: dictGenericUserProperties)
    }
}


