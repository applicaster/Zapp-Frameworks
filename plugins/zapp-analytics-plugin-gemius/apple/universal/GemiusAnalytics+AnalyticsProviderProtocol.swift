//
//  GemiusAnalytics+AnalyticsProviderProtocol.swift
//  GemiusAnalytics
//
//  Created by Alex Zchut on 29/03/2021.
//  Copyright © 2021 Applicaster Ltd. All rights reserved.
//

import Foundation
import GemiusSDK
import ZappCore

extension GemiusAnalytics: AnalyticsProviderProtocol {
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
        let updatedEventName = "\(eventName).start"

        var parametersToPass: [String: NSObject] = [:]
        if let parameters = parameters as? [String: NSObject] {
            parametersToPass = parameters
        }
        trackEvent(updatedEventName,
                   parameters: parametersToPass,
                   timed: true)
    }

    @objc public func stopObserveTimedEvent(_ eventName: String,
                                            parameters: [String: Any]?) {
        let updatedEventName = "\(eventName).end"

        var parametersToPass: [String: NSObject] = [:]
        if let parameters = parameters as? [String: NSObject] {
            parametersToPass = parameters
        }

        endTimedEvent(updatedEventName,
                      parameters: parametersToPass)
    }

    public func trackEvent(_ eventName: String, parameters: [String: NSObject]) {
        // Check for a valid gemius key
        guard isDisabled == false else {
            return
        }

        guard !shouldHandlePlayerEvents(for: eventName, parameters: parameters),
              !shouldHandleAdEvents(for: eventName, parameters: parameters),
              !shouldHandleScreenEvents(for: eventName, parameters: parameters) else {
            return
        }

        // ignore other events
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

extension GemiusAnalytics {
    func getCurrentPlayerPosition(from parameters: [String: NSObject]) -> Double {
        return parameters["offset"] as? Double ?? 0.00
    }
}
