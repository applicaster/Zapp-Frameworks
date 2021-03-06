//
//  SegmentAnalytics+AnalyticsProviderProtocol.swift
//  SegmentAnalytics
//
//  Created by Alex Zchut on 10/03/2021.
//  Copyright © 2021 Applicaster Ltd. All rights reserved.
//

import Analytics
import Foundation
import ZappCore

extension SegmentAnalytics: AnalyticsProviderProtocol {
    public func sendEvent(_ eventName: String,
                          parameters: [String: Any]?) {
        var parametersToPass: [String: NSObject] = [:]
        if let parameters = parameters as? [String: NSObject] {
            parametersToPass = parameters
        }
        trackEvent(eventName,
                   parameters: parametersToPass)
    }

    public func sendScreenEvent(_ screenName: String,
                                parameters: [String: Any]?) {
        var parametersToPass: [String: NSObject] = [:]
        if let parameters = parameters as? [String: NSObject] {
            parametersToPass = parameters
        }
        trackScreenView(screenName,
                        parameters: parametersToPass)
    }

    @objc public func startObserveTimedEvent(_ eventName: String,
                                             parameters: [String: Any]?) {
        trackEvent(eventName,
                   timed: true)
    }

    @objc public func stopObserveTimedEvent(_ eventName: String,
                                            parameters: [String: Any]?) {
        var parametersToPass: [String: NSObject] = [:]
        if let parameters = parameters as? [String: NSObject] {
            parametersToPass = parameters
        }
        endTimedEvent(eventName,
                      parameters: parametersToPass)
    }

    public func trackEvent(_ eventName: String, parameters: [String: NSObject]) {
        // Check for a valid segment key
        guard isDisabled == false else {
            return
        }

        guard shoudIgnoreEvent(eventName) == false else {
            return
        }
        // Add extra params to align with the Android plugin code
        var newParameters = parameters
        newParameters["name"] = eventName as NSObject
        newParameters["timestamp"] = getTimestamp() as NSObject

        // Pass the event to Segement server
        SEGAnalytics.shared()?.track(eventName, properties: newParameters)
    }

    func trackEvent(_ eventName: String, timed: Bool) {
        trackEvent(eventName, parameters: [:], timed: timed)
    }

    func trackEvent(_ eventName: String, parameters: [String: NSObject], timed: Bool) {
        trackEvent(eventName, parameters: parameters)
    }

    func trackScreenView(_ screenName: String, parameters: [String: NSObject]) {
        trackEvent(screenName, parameters: parameters)
    }

    func endTimedEvent(_ eventName: String, parameters: [String: NSObject]) {
        trackEvent(eventName, parameters: parameters)
    }
}
