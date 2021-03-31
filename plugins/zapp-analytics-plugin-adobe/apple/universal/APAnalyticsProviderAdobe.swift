//
//  APAnalyticsProviderAdobe.swift
//  ZappAnalyticsPluginAdobe
//
//  Created by Alex Zchut on 22/11/2020.
//  Copyright © 2020 Applicaster. All rights reserved.
//

import ACPAnalytics
import ACPCore
import ZappAnalyticsPluginsSDK
import ZappCore

#if canImport(ACPUserProfile)
    import ACPUserProfile
#endif

open class APAnalyticsProviderAdobe: ZPAnalyticsProvider, PlayerDependantPluginProtocol {
    let kDebugAppId = "mobile_app_account_id"
    let kProductionAddId = "mobile_app_account_id_production"
    public var playerPlugin: PlayerProtocol?
    var adobeAnalyticsObjc: AdobeAnalytics?
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

        adobeAnalyticsObjc = AdobeAnalytics(providerProperties: providerProperties,
                                            delegate: self)

        subscribeToEventsBusTopics()

        let logLevel: ACPMobileLogLevel = isDebug() ? .debug : .error
        let appID = isDebug() ? debugAppId : productionAddId

        ACPCore.setLogLevel(logLevel)
        ACPCore.configure(withAppId: appID)
        ACPAnalytics.registerExtension()
        #if canImport(ACPUserProfile)
            ACPUserProfile.registerExtension()
        #endif
        ACPIdentity.registerExtension()
        ACPLifecycle.registerExtension()
        ACPSignal.registerExtension()
        ACPCore.start {
            ACPCore.lifecycleStart(nil)
        }

        return true
    }

    override open func trackEvent(_ eventName: String, timed: Bool) {
        super.trackEvent(eventName, timed: timed)
        trackEvent(eventName, parameters: [:])
    }

    override open func trackEvent(_ eventName: String) {
        super.trackEvent(eventName)
        trackEvent(eventName, parameters: [:])
    }

    override open func trackEvent(_ eventName: String, parameters: [String: NSObject], timed: Bool) {
        super.trackEvent(eventName, parameters: parameters, timed: timed)
        trackEvent(eventName, parameters: parameters)
    }

    override open func trackEvent(_ eventName: String, parameters: [String: NSObject]) {
        super.trackEvent(eventName, parameters: parameters)
        adobeAnalyticsObjc?.prepareTrackEvent(eventName, parameters: parameters, completion: { parameters in
            let trackParameters = parameters as? [String: String] ?? [:]
            ACPCore.trackAction(eventName, data: trackParameters)
        })
    }

    override open func trackScreenView(_ screenName: String, parameters: [String: NSObject]) {
        super.trackScreenView(screenName, parameters: parameters)

        adobeAnalyticsObjc?.prepareTrackScreenView(screenName, parameters: parameters, completion: { parameters in
            let trackParameters = parameters as? [String: String] ?? [:]
            ACPCore.trackState(screenName, data: trackParameters)
        })
    }

    override open func setUserProfile(genericUserProperties dictGenericUserProperties: [String: NSObject], piiUserProperties dictPiiUserProperties: [String: NSObject]) {
        super.setUserProfile(genericUserProperties: dictGenericUserProperties, piiUserProperties: dictGenericUserProperties)

        guard let dictPiiUserProperties = dictPiiUserProperties as? [String: String] else {
            return
        }
        ACPCore.collectPii(dictPiiUserProperties)
    }
}
