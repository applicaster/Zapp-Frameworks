//
//  GoogleAnalyticsPluginAdapter.swift
//  ZappAnalyticsPluginGAtvOS
//
//  Created by Anton Kononenko on 10/17/19.
//  Copyright © 2019 Applicaster. All rights reserved.
//

import Foundation
import ZappCore

@objc open class GoogleAnalyticsPluginAdapter: NSObject, PluginAdapterProtocol {
    public var configurationJSON: NSDictionary?
    public var model: ZPPluginModel?
    var isDisabled: Bool = false

    public required init(pluginModel: ZPPluginModel) {
        model = pluginModel
        configurationJSON = model?.configurationJSON
    }

    // used for optional support for timed events implementation
    var timedEventsDictionary: [String: APTimedEvent] = [:]

    /// Plugin configuration keys
    struct PluginKeys {
        static let trackingID = "tracker_id"
        static let screenViewsEsnabled = "screen_views_enabled"
    }

    /// Google Analytics Manager
    var manager: MeasurementProtocolManager?

    /// Define if screen view enabled in plugin
    var isScreenViewsEnabled: Bool = false

    var defaultEventParameters: [String: Any] = [:]

    public func disable(completion: ((Bool) -> Void)?) {
        isDisabled = true
    }

    public var providerName: String {
        return "GoogleAnalytics"
    }

    public func prepareProvider(_ defaultParams: [String: Any],
                                completion: ((_ isReady: Bool) -> Void)?) {
        guard let trackingID = self.configurationJSON?[PluginKeys.trackingID] as? String else {
            completion?(false)
            return
        }

        if let enableScreenViews = self.configurationJSON?[PluginKeys.screenViewsEsnabled] as? Bool {
            isScreenViewsEnabled = enableScreenViews
        }
        defaultEventParameters = defaultParams
        manager = MeasurementProtocolManager(trackingID: trackingID)
        completion?(true)
    }

    /// Devide event name on category and label
    ///
    /// - Parameter value: value to devide
    /// - Returns: Return array of devided title
    func separatedEvents(forEventString value: String) -> [String] {
        var result: [String] = []

        guard String.isNotEmptyOrWhitespace(value) else {
            return result
        }

        var eventSeparated = value.components(separatedBy: ":")
        if eventSeparated.count == 1 {
            eventSeparated = value.components(separatedBy: "-")
        }

        if eventSeparated.count == 2 {
            for eventValue in eventSeparated.prefix(2) {
                if let trimmedValue = trimmString(string: eventValue) {
                    result.append(trimmedValue)
                }
            }
        } else if let trimmedValue = trimmString(string: value) {
            result.append(trimmedValue)
        }

        return result
    }

    /// Trimm whitespaces from string
    ///
    /// - Parameter string: string to trimm
    /// - Returns: if string not empty return trimmed string otherwise nil
    func trimmString(string: String) -> String? {
        let trimmedString = string.trimmingCharacters(in: .whitespaces)
        return String.isNotEmptyOrWhitespace(trimmedString) ? trimmedString : nil
    }

    /// Create label for analytics event
    ///
    /// - Parameter params: parameters to combine
    /// - Returns: label string
    func analyticsString(fromParams params: [String: Any]) -> String {
        var mergedParams = ""
        let sortedParams = Array(params.keys).sorted()
        for (index, paramName) in sortedParams.enumerated() {
            if let paramValue = params[paramName] {
                let paramValueString = String(describing: paramValue)
                mergedParams = mergedParams.appendingFormat("%@=%@",
                                                            paramName,
                                                            paramValueString)
                if index < sortedParams.count - 1 {
                    mergedParams += "; "
                }
            }
        }

        return mergedParams.count > 0 ? mergedParams : ""
    }

    public func registerTimedEvent(_ eventName: String, parameters: [String: Any]?) {
        if let currentEvent = self.timedEventsDictionary[eventName] {
            processEndTimedEvent(currentEvent.eventName, parameters: currentEvent.parameters)
        }
        var parametersToPass: [String: NSObject] = [:]
        if let parameters = parameters as? [String: NSObject] {
            parametersToPass = parameters
        }

        let timedEvent = APTimedEvent(eventName: eventName,
                                      parameters: parametersToPass,
                                      startTime: Date())
        timedEventsDictionary[eventName] = timedEvent
    }

    public func processEndTimedEvent(_ eventName: String, parameters: [String: Any]?) {
        if let timedEvent = self.timedEventsDictionary[eventName] {
            // Handle merging parameters with the later ones overriding the earlier ones if needed
            let parameters = parameters ?? [:] as [String: Any]
            let timedEventParameters = timedEvent.parameters ?? [:] as [String: Any]
            var mergedParameters = timedEventParameters.merge(parameters)
            mergedParameters["Event Duration"] = "\(Int(abs(timedEvent.startTime.timeIntervalSinceNow)))" as Any

            var parametersToPass: [String: NSObject] = [:]
            if let mergedParameters = mergedParameters as? [String: NSObject] {
                parametersToPass = mergedParameters
            }

            timedEvent.parameters = parametersToPass
            sendEvent(timedEvent.eventName,
                      parameters: mergedParameters)
            timedEventsDictionary.removeValue(forKey: eventName)
        }
    }
}

extension GoogleAnalyticsPluginAdapter: AnalyticsProviderProtocol {
    @objc public func sendEvent(_ eventName: String,
                                parameters: [String: Any]?) {
        guard isDisabled == false else {
            return
        }

        let events = separatedEvents(forEventString: eventName)
        let combinedProperties = combineProperties(combinedWithEventParams: parameters)
        let eventLabel = analyticsString(fromParams: combinedProperties)
        let customParameters = CustomDemensionMappingHelper.paramsForCustomDemensions(customParamenters: combinedProperties)
        manager?.event(category: events.first ?? "",
                       action: events.last ?? "",
                       label: eventLabel,
                       customParameters: customParameters)
    }

    @objc public func sendScreenEvent(_ screenName: String,
                                      parameters: [String: Any]?) {
        guard isDisabled == false else {
            return
        }
        guard isScreenViewsEnabled else {
            return
        }
        manager?.screenView(screenName: screenName)
    }

    @objc public func startObserveTimedEvent(_ eventName: String,
                                             parameters: [String: Any]?) {
        guard isDisabled == false else {
            return
        }
        registerTimedEvent(eventName,
                           parameters: parameters)
    }

    @objc public func stopObserveTimedEvent(_ eventName: String,
                                            parameters: [String: Any]?) {
        guard isDisabled == false else {
            return
        }
        processEndTimedEvent(eventName,
                             parameters: parameters)
    }

    @objc public func combineProperties(combinedWithEventParams eventParams: [String: Any]?) -> [String: Any] {
        var properties: [String: Any] = [:]
        if let eventParams = eventParams {
            properties = eventParams
        }

        // return merging gathered properties with default properties
        return properties.merge(defaultEventParameters)
    }
}
