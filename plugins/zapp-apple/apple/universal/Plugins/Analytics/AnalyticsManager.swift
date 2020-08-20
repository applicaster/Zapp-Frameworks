//
//  AnalyticsManager.swift
//  ZappAnalyticsPluginsSDK
//
//  Created by Anton Kononenko on 11/22/18.
//  Copyright © 2018 Applicaster. All rights reserved.
//

import UIKit
import ZappCore
import XrayLogger

public typealias AnalyticManagerPreparationCompletion = () -> Void
public typealias ProviderSendAnalyticsCompletion = (_ provider: AnalyticsProviderProtocol,
                                                    _ success: Bool) -> Void
public class AnalyticsManager: PluginManagerBase {
    lazy var logger = Logger.getLogger(for: AnalyticsPluginsManagerLogs.subsystem)

    typealias pluginTypeProtocol = AnalyticsProviderProtocol
    var _providers: [AnalyticsProviderProtocol] {
        let providersArray = providers.map { $0.value }
        return providersArray as! [AnalyticsProviderProtocol]
    }

    public required init() {
        super.init()
        pluginType = .Analytics
    }

    @objc public private(set) var currentScreenViewTitle: String?

    public override func providerCreated(provider: PluginAdapterProtocol,
                                         completion: PluginManagerCompletion) {
        provider.prepareProvider(defaultParams()) { succeed in
            completion?(succeed)
        }
        // Must be implemented on subclass if needed
    }

    func defaultParams() -> [String: Any] {
        var defaultParams: [String: Any] = [:]

        let sessionStorage = SessionStorage.sharedInstance
        if let uuid = sessionStorage.get(key: ZappStorageKeys.uuid,
                                         namespace: nil),
            String.isNotEmptyOrWhitespace(uuid) {
            defaultParams["uuid"] = uuid
            // Add this key to support backward compatibility
            defaultParams["identity_client_device_id"] = uuid
        }

        if let versionName = sessionStorage.get(key: ZappStorageKeys.versionName,
                                                namespace: nil),
            String.isNotEmptyOrWhitespace(versionName) {
            defaultParams["Version Name"] = versionName
        }

        if let buildVersion = sessionStorage.get(key: ZappStorageKeys.buildVersion,
                                                 namespace: nil),
            String.isNotEmptyOrWhitespace(buildVersion) {
            defaultParams["Bundle Version"] = buildVersion
        }

        if let riversConfigurationId = sessionStorage.get(key: ZappStorageKeys.riversConfigurationId,
                                                          namespace: nil),
            String.isNotEmptyOrWhitespace(riversConfigurationId) {
            defaultParams["Rivers Configuration ID"] = riversConfigurationId
        }
        defaultParams["Morpheus Version"] = "2.0"

        return defaultParams
    }

    public func sendEvent(name: String,
                          parameters: [String: Any]?) {
        let parameters = parameters ?? [:]
        logger?.verboseLog(template: AnalyticsPluginsManagerLogs.sendEvent,
                           data: ["name": name,
                                  "parameters": parameters])
        
        for provider in _providers {
            if isProviderEnabled(provider: provider) {
                provider.sendEvent(name,
                                   parameters: parameters)
            }
        }
    }

    public func startObserveTimedEvent(name: String,
                                       parameters: Dictionary<String, Any>?) {
        let parameters = parameters ?? [:]
        logger?.verboseLog(template: AnalyticsPluginsManagerLogs.startObserveTimedEvent,
                           data: ["name": name,
                                  "parameters": parameters])
        
        for provider in _providers {
            if isProviderEnabled(provider: provider) {
                provider.startObserveTimedEvent?(name,
                                                 parameters: parameters)
            }
        }
    }

    @objc open func stopObserveTimedEvent(_ eventName: String,
                                          parameters: [String: Any]?) {
        let parameters = parameters ?? [:]
        logger?.verboseLog(template: AnalyticsPluginsManagerLogs.stopObserveTimedEvent,
                           data: ["name": eventName,
                                  "parameters": parameters])
        
        for provider in _providers {
            if isProviderEnabled(provider: provider) {
                provider.stopObserveTimedEvent?(eventName,
                                                parameters: parameters)
            }
        }
    }

    public func sendScreenEvent(screenTitle: String,
                                parameters: [String: Any]?) {
        if currentScreenViewTitle != screenTitle {
            var parameters = parameters as? [String: NSObject] ?? [:]
            parameters["Trigger"] = NSString(string: screenTitle)
            logger?.verboseLog(template: AnalyticsPluginsManagerLogs.sendScreenEvent,
                               data: ["screenTitle": screenTitle,
                                      "parameters": parameters])
            
            for provider in _providers {
                if isProviderEnabled(provider: provider) {
                    provider.sendScreenEvent(screenTitle, parameters: parameters)
                }
            }
            currentScreenViewTitle = screenTitle
        }
    }

    public func trackURL(url: URL?) {
        guard let url = url as NSURL? else {
            return
        }
        
        logger?.verboseLog(template: AnalyticsPluginsManagerLogs.trackCampaignParamsFromUrl,
                           data: ["url": url])
        
        for provider in _providers {
            if isProviderEnabled(provider: provider) {
                provider.trackCampaignParamsFromUrl?(url)
            }
        }
    }
}
