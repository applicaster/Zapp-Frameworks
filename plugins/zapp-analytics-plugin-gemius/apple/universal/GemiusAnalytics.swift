//
//  GemiusAnalytics.swift
//  GemiusAnalytics
//
//  Created by Alex Zchut on 29/03/2021.
//  Copyright © 2021 Applicaster Ltd. All rights reserved.
//

import GemiusSDK
import AVFoundation
import Foundation
import ZappCore

class GemiusAnalytics: NSObject, PluginAdapterProtocol {
    open var providerProperties: [String: NSObject] = [:]
    open var configurationJSON: NSDictionary?

    struct Params {
        static let apiKey = "gemius_identifier"
        static let jsPreferencesKey = "javaScriptForWebView"
        static let pluginIdentifier = "applicaster-cmp-didomi"
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
    var objcHelper: GemiusAnalyticsHelper?
    var playerRateObserverPointerString: UInt?
    
    
    lazy var ignoredEvents: [String] = {
        guard let eventsListString = model?.configurationValue(for: "blacklisted_events_list") as? String,
              eventsListString.isEmpty == false else {
            return []
        }
        return eventsListString.components(separatedBy: ",").map { $0.lowercased() }
    }()

    /*
         track lets you record the actions your users perform.
         Every action triggers what we call an “event”, which can also have associated properties.

         To get started, our SDK can automatically track a few key common events with our Native Mobile Spec,
         such as the Application Installed, Application Updated and Application Opened. Simply enable this option during initialization.

         You’ll also want to track events that are indicators of success for your mobile app,
         like Signed Up, Item Purchased or Article Bookmarked.
         We recommend tracking just a few important events. You can always add more later!
     */

    public required init(pluginModel: ZPPluginModel) {
        model = pluginModel
        configurationJSON = model?.configurationJSON
        providerProperties = model?.configurationJSON as? [String: NSObject] ?? [:]
    }

    public func prepareProvider(_ defaultParams: [String: Any], completion: ((Bool) -> Void)?) {
        if let gemiusKey = model?.configurationValue(for: Params.apiKey) as? String,
           gemiusKey.isEmpty == false {
            let configuration = SEGAnalyticsConfiguration(writeKey: gemiusKey)
            configuration.trackApplicationLifecycleEvents = true
            configuration.recordScreenViews = false

            SEGAnalytics.setup(with: configuration)
            objcHelper = GemiusAnalyticsHelper(providerProperties: providerProperties,
                                                delegate: self)
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

    func shoudIgnoreEvent(_ eventName: String) -> Bool {
        return ignoredEvents.contains(eventName.lowercased())
    }
}

extension GemiusAnalytics {
    @objc public func login(with identity: String,
                            traits: [String: Any]?,
                            options: [String: Any]?) {
        SEGAnalytics.shared()?.identify(identity,
                                        traits: traits,
                                        options: options)
    }
}
