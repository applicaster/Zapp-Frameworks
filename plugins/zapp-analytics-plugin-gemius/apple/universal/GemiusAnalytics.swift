//
//  GemiusAnalytics.swift
//  GemiusAnalytics
//
//  Created by Alex Zchut on 29/03/2021.
//  Copyright © 2021 Applicaster Ltd. All rights reserved.
//

import AVFoundation
import Foundation
import GemiusSDK
import ZappCore

class GemiusAnalytics: NSObject, PluginAdapterProtocol {
    open var providerProperties: [String: NSObject] = [:]
    open var configurationJSON: NSDictionary?

    struct Params {
        static let scriptIdentifier = "script_identifier"
        static let hitCollectorHost = "hit_collector_host"
        static let pluginIdentifier = "applicaster-cmp-gemius"
    }

    public var model: ZPPluginModel?
    public var providerName: String {
        return getKey()
    }

    public func getKey() -> String {
        return "GemiusAnalytics"
    }

    var isDisabled = false
    var playbackStalled: Bool = false
    public var playerPlugin: PlayerProtocol?
    var playerRateObserverPointerString: UInt?

    lazy var scriptIdentifier: String = {
        guard let scriptIdentifier = model?.configurationValue(for: Params.scriptIdentifier) as? String else {
            return ""
        }
        return scriptIdentifier
    }()
    
    lazy var hitCollectorHost: String = {
        guard let hitCollectorHost = model?.configurationValue(for: Params.hitCollectorHost) as? String else {
            return ""
        }
        return hitCollectorHost
    }()
    
    var gemiusPlayerObject: GSMPlayer?
    var lastProgramID: String?
    var lastProceededPlayerEvent: String?
    var lastProceededAdEvent: String?

    public required init(pluginModel: ZPPluginModel) {
        model = pluginModel
        configurationJSON = model?.configurationJSON
        providerProperties = model?.configurationJSON as? [String: NSObject] ?? [:]
    }

    public func prepareProvider(_ defaultParams: [String: Any], completion: ((Bool) -> Void)?) {
        if scriptIdentifier.isEmpty == false,
           hitCollectorHost.isEmpty == false {
            GEMAudienceConfig.sharedInstance()?.hitcollectorHost = hitCollectorHost
            GEMAudienceConfig.sharedInstance()?.scriptIdentifier = scriptIdentifier
            GEMConfig.sharedInstance()?.loggingEnabled = isDebug()

            if let appName = FacadeConnector.connector?.applicationData?.bundleName(),
               appName.isEmpty == false,
               let appVersion = FacadeConnector.connector?.storage?.sessionStorageValue(for: "version_name", namespace: nil),
               appVersion.isEmpty == false {
                GEMConfig.sharedInstance()?.setAppInfo(appName, version: appVersion)
            }
            
            completion?(true)
        } else {
            disable(completion: completion)
        }
    }

    public func disable(completion: ((Bool) -> Void)?) {
        disable()
        completion?(true)
    }

    fileprivate func disable() {
        isDisabled = true
    }

    func getTimestamp() -> String {
        // UTC: '2019-03-29T14:50:23.971Z’
        let dateFormatter = ISO8601DateFormatter()
        let dateString = dateFormatter.string(from: Date())

        return "\(dateString)"
    }
    
    func isDebug() -> Bool {
        guard let value = FacadeConnector.connector?.applicationData?.isDebugEnvironment() else {
            return false
        }

        return Bool(value)
    }
}
