//
//  APAnalyticsProviderComScore.swift
//  ZappAnalyticsPluginComScore
//
//  Created by Alex Zchut on 20/07/2018.
//  Copyright © 2018 Applicaster. All rights reserved.
//

import ComScore
import ZappAnalyticsPluginsSDK
import ZappPlugins

open class APAnalyticsProviderComScore: ZPAnalyticsProvider, PlayerDependantPluginProtocol {
    public var playerPlugin: PlayerProtocol?
    var playbackStalled: Bool = false

    let kCustomerC2Key = "customer_c2"
    let kPublisherSecretKey = "publisher_secret"
    let kAppNameKey = "app_name"
    let kNsSiteKey = "ns_site"
    let kStreamSenseKey = "stream_sense"
    let kPublisherName = "ns_st_pu"
    let kC3 = "c3"

    override open func getKey() -> String {
        return "comscore"
    }

    override open func configureProvider() -> Bool {
        var retValue = false

        var customerC2: String?
        if let value = providerProperties[kCustomerC2Key] as? String {
            customerC2 = value
        }

        var publishSecret: String?
        if let value = providerProperties[kPublisherSecretKey] as? String {
            publishSecret = value
        }

        if publishSecret != nil && customerC2 != nil {
            var appName: String?
            if let value = providerProperties[kAppNameKey] as? String {
                appName = value
            } else {
                appName = Bundle.main.infoDictionary?["CFBundleDisplayName"] as? String
            }

            var nsSite: String?
            if let value = providerProperties[kNsSiteKey] as? String {
                nsSite = value
            }

//            var streamSense: String = ""
//            if let value = providerProperties[kStreamSenseKey] as? String {
//                streamSense = value
//            }

            let publisherConfig = SCORPublisherConfiguration(builderBlock: { builder in
                if let builder = builder {
                    builder.publisherId = customerC2
                    builder.publisherSecret = publishSecret
                    builder.applicationName = appName
                }
            })
            SCORAnalytics.configuration().addClient(with: publisherConfig)
            SCORAnalytics.configuration().keepAliveMeasurement = true

            if nsSite != nil {
                SCORAnalytics.configuration().setPersistentLabelWithName(kNsSiteKey, value: nsSite)
            } else {
                SCORAnalytics.configuration().setPersistentLabelWithName(kNsSiteKey, value: "app-" + appName!)
            }

            SCORAnalytics.start()

            APStreamSenseManager.setProviderProperties(providerProperties)
            APStreamSenseManager.setDelegate(self)
            APStreamSenseManager.start()

            retValue = true
        }

        return retValue
    }
}

extension APAnalyticsProviderComScore: APStreamSenseManagerDelegate {
    public func getCurrentPlayerInstance() -> AVPlayer? {
        return playerPlugin?.playerObject as? AVPlayer
    }
}
 