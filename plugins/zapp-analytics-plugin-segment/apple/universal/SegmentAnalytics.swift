//
//  SegmentAnalyticsPlugin.swift
//  SegmentAnalyticsPlugin
//
//  Created by Roman Karpievich on 7/1/20.
//  Copyright © 2020 Applicaster Ltd. All rights reserved.
//

import Analytics
import AVFoundation
import Foundation
import ZappCore

import ZappAnalyticsPluginsSDK
import ZappCore
import ZappPlugins
/*
 For more infomration check the Segment API docs:
 https://segment.com/docs/connections/sources/catalog/libraries/mobile/ios/
 */
class SegmentAnalyticsPlugin: ZPAnalyticsProvider {
    override public func getKey() -> String {
        return "SegmentAnalyticsPlugin"
    }

    private var isDisabled = false

    /*
         track lets you record the actions your users perform.
         Every action triggers what we call an “event”, which can also have associated properties.

         To get started, our SDK can automatically track a few key common events with our Native Mobile Spec,
         such as the Application Installed, Application Updated and Application Opened. Simply enable this option during initialization.

         You’ll also want to track events that are indicators of success for your mobile app,
         like Signed Up, Item Purchased or Article Bookmarked.
         We recommend tracking just a few important events. You can always add more later!
     */

    override func trackEvent(_ eventName: String, parameters: [String: NSObject]) {
        // Check for a valid segment key
        guard isDisabled == false else {
            return
        }

        // Add extra params to align with the Android plugin code
        var newParameters = parameters
        newParameters["name"] = eventName as NSObject
        newParameters["timestamp"] = getTimestamp() as NSObject

        // Pass the event to Segement server
        SEGAnalytics.shared()?.track(eventName, properties: newParameters)
    }

    override func prepareProvider(_ defaultParams: [String: Any], completion: ((Bool) -> Void)?) {
        if let segmentKey = model?.configurationValue(for: "segment_write_key") as? String,
           segmentKey.isEmpty == false {
            let configuration = SEGAnalyticsConfiguration(writeKey: segmentKey)
            configuration.trackApplicationLifecycleEvents = true
            configuration.recordScreenViews = true

            SEGAnalytics.setup(with: configuration)
            completion?(true)
        } else {
            disable(completion: completion)
        }
    }

    override func disable(completion: ((Bool) -> Void)?) {
        disable()
        completion?(true)
    }

    fileprivate func disable() {
        isDisabled = true
    }

    fileprivate func getTimestamp() -> String {
        // UTC: '2019-03-29T14:50:23.971Z’
        let dateFormatter = ISO8601DateFormatter()
        let dateString = dateFormatter.string(from: Date())

        return "\(dateString)"
    }
}
