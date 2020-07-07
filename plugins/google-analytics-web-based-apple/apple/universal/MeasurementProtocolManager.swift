//
//  MeasurementProtocolManager.swift.swift
//  ZappAnalyticsPluginGAtvOS
//
//  Created by Anton Kononenko on 1/11/19.
//  Copyright © 2019 Applicaster. All rights reserved.
//

import Foundation
import ZappCore

public class MeasurementProtocolManager {
    let dataNotAvailible = "N/A"

    /// Google Analytic tracking ID
    private(set) var trackingID: String

    /// Create unique user identifier and save it to UserDefaules, in case was generated, retrive from UserDefaules
    lazy var clientID: String = {
        let defaults = UserDefaults.standard
        guard let identifier = defaults.string(forKey: MeasurementProtocolKeys.All.clientID) else {
            let newIdentifier = NSUUID().uuidString
            defaults.setValue(newIdentifier,
                              forKey: MeasurementProtocolKeys.All.clientID)
            defaults.synchronize()
            return newIdentifier
        }
        return identifier
    }()

    /// Contains array of the general params, that relevant for every hit event
    lazy var generalParams: [String] = {
        var retVal: [String] = []
        retVal.append(urlParam(with: MeasurementProtocolKeys.All.trackingID,
                               value: trackingID))
        retVal.append(urlParam(with: MeasurementProtocolKeys.All.protocolVersion,
                               value: mesurementProtocolVersion))
        retVal.append(urlParam(with: MeasurementProtocolKeys.All.dataSource,
                               value: dataSourceKey))
        retVal.append(urlParam(with: MeasurementProtocolKeys.All.clientID,
                               value: clientID))
        retVal.append(urlParam(with: MeasurementProtocolKeys.All.screenResolution,
                               value: screenSize))
        retVal.append(urlParam(with: MeasurementProtocolKeys.AppTracking.applicationName,
                               value: bundleName))
        retVal.append(urlParam(with: MeasurementProtocolKeys.AppTracking.applicationVersion,
                               value: applicationVersion))

        if let languageCode = userLanguage {
            retVal.append(urlParam(with: MeasurementProtocolKeys.All.userLanguage,
                                   value: languageCode))
        }

        if let bundleIdentifier = bundleIdentifier {
            retVal.append(urlParam(with: MeasurementProtocolKeys.AppTracking.bundleIdentifier,
                                   value: bundleIdentifier))
        }

        return retVal
    }()

    /// Retrieve current device resolution in format "`width`x`height`"
    lazy var screenSize: String = {
        "\(Int(UIScreen.main.nativeBounds.size.width))x\(Int(UIScreen.main.nativeBounds.size.height))"
    }()

    /// Retrieve current device language
    lazy var userLanguage: String? = {
        Locale.current.languageCode
    }()

    /// Retrieve application bundle identifier
    lazy var bundleIdentifier: String? = {
        Bundle.main.bundleIdentifier
    }()

    /// Retrieve application bundle name
    lazy var bundleName: String = {
        guard let applicationData = FacadeConnector.connector?.applicationData else {
            return dataNotAvailible
        }
        return applicationData.bundleName()
    }()

    /// Retrieve application version
    lazy var applicationVersion: String = {
        guard let applicationData = FacadeConnector.connector?.applicationData else {
            return dataNotAvailible
        }
        return applicationData.appVersion()
    }()

    /// Initialize application with Google Tracking ID
    ///
    /// - Parameter trackingID: Identifier to send Google Analytics events
    init(trackingID: String) {
        self.trackingID = trackingID
    }

    /// Send event with Hit Type and custom parameters
    ///
    /// - Parameters:
    ///   - hitType: string of the hit type
    ///   - customParameters: event custom parameters
    func send(hitType: String,
              customParameters: [String: String]? = nil) {
        if let url = hitURL(for: hitType,
                            customParameters: customParameters) {
            sendRequest(with: url)
        }
    }

    ///  Send event with Screen Hit Type and custom parameters
    ///
    /// - Parameters:
    ///   - screenName: name of the screen
    ///   - customParameters: event custom parameters
    func screenView(screenName: String,
                    customParameters: [String: String]? = nil) {
        var newCustomParameters = customParameters ?? [:]
        newCustomParameters[MeasurementProtocolKeys.ScreenView.screenName] = screenName

        send(hitType: MeasurementProtocolKeys.All.HitType.screenView,
             customParameters: newCustomParameters)
    }

    ///  Send event with Event Hit Type and custom parameters
    ///
    /// - Parameters:
    ///   - category: mandatory parameter category
    ///   - action: mandatory parameter action
    ///   - label: mandatory parameter label
    ///   - customParameters: event custom parameters
    func event(category: String,
               action: String,
               label: String?,
               customParameters: [String: String]? = nil) {
        var newCustomParameters = customParameters ?? [:]
        newCustomParameters[MeasurementProtocolKeys.EventTracking.category] = category
        newCustomParameters[MeasurementProtocolKeys.EventTracking.action] = action
        newCustomParameters[MeasurementProtocolKeys.EventTracking.label] = label

        send(hitType: MeasurementProtocolKeys.All.HitType.event,
             customParameters: newCustomParameters)
    }

    ///  Send event with Exception Hit Type and custom parameters
    ///
    /// - Parameters:
    ///   - description: fail explanation
    ///   - isFatal: is error fatal
    ///   - customParameters: event custom parameters
    func exception(description: String,
                   isFatal: Bool,
                   customParameters: [String: String]? = nil) {
        var newCustomParameters = customParameters ?? [:]
        newCustomParameters[MeasurementProtocolKeys.ExceptionsTracking.exceptionFatal] = isFatal == true ? "1" : "0"
        newCustomParameters[MeasurementProtocolKeys.ExceptionsTracking.exceptionDescription] = description

        send(hitType: MeasurementProtocolKeys.All.HitType.exception,
             customParameters: newCustomParameters)
    }

    /// Transfer analytics parameters in dictianary to format url format to prepare analytics Url request
    ///
    /// - Parameter customParameters: Analytics parameters in dictionary
    /// - Returns: Array of string in format "`key=value`"
    func transferDictParamsToUrlParams(customParameters: [String: String]) -> [String] {
        var retVal: [String] = []

        for (key, value) in customParameters {
            retVal.append(urlParam(with: key,
                                   value: value))
        }
        return retVal
    }

    /// Returns parameter for future URL String
    ///
    /// - Parameters:
    ///   - key: String that will be used as key for param
    ///   - value: String that will be used as value for param
    /// - Returns: Returns URL parameter in format `"key=value"`
    func urlParam(with key: String,
                  value: String) -> String {
        return "\(key)=\(value)"
    }

    /// Send request with hit event to Google Analytics
    ///
    /// - Parameter url: URL of the hit event
    func sendRequest(with url: URL) {
        URLSession.shared.dataTask(with: url as URL) { (_, _, _) -> Void in }.resume()
    }

    /// Creates url for hit type event
    ///
    /// - Parameters:
    ///   - hitType: hit type Event
    ///   - customParameters: additional parameters that must be passed with url
    /// - Returns: URL instance if url can be created otherwise nil
    func hitURL(for hitType: String,
                customParameters: [String: String]?) -> URL? {
        guard isAllowedHitType(hitType: hitType) else {
            return nil
        }

        var urlParams: [String] = generalParams
        if let customParameters = customParameters {
            let customParams = transferDictParamsToUrlParams(customParameters: customParameters)
            urlParams.append(contentsOf: customParams)
        }

        urlParams.append(urlParam(with: MeasurementProtocolKeys.All.hitType,
                                  value: hitType))

        guard let urlParamsTemplate = urlParamsString(from: urlParams),
            let url = stringToURLWithEncoding(with: urlParamsTemplate) else {
            return nil
        }

        return url
    }

    /// Check if hit type string is api correct
    ///
    /// - Parameter hitType: string representation of hit event type
    /// - Returns: true if hit event exist otherwise false
    func isAllowedHitType(hitType: String) -> Bool {
        if hitType == MeasurementProtocolKeys.All.HitType.pageView ||
            hitType == MeasurementProtocolKeys.All.HitType.screenView ||
            hitType == MeasurementProtocolKeys.All.HitType.event ||
            hitType == MeasurementProtocolKeys.All.HitType.transaction ||
            hitType == MeasurementProtocolKeys.All.HitType.item ||
            hitType == MeasurementProtocolKeys.All.HitType.social ||
            hitType == MeasurementProtocolKeys.All.HitType.exception ||
            hitType == MeasurementProtocolKeys.All.HitType.timing {
            return true
        }
        return false
    }

    /// Combine url params array to one string
    ///
    /// - Parameter urlParams: array of url params in format `["a=1", "b=2"]`
    /// - Returns: Return cobined string in format "`a=1&b=2`"
    func urlParamsString(from urlParams: [String]) -> String? {
        var urlStringTemplate = ""
        urlParams.forEach { currentParam in
            if String.isNotEmptyOrWhitespace(currentParam) {
                urlStringTemplate += urlStringTemplate.count > 0 ? "&" : ""
                urlStringTemplate += currentParam
            }
        }

        return String.isNotEmptyOrWhitespace(urlStringTemplate) ? urlStringTemplate : nil
    }

    /// Convert url string with url params string to url with encoding `CharacterSet.urlHostAllowed`
    ///
    /// - Parameter urlParamsString: string of url params in format "`a=1&b=2`"
    /// - Returns: URL instance in case can be created otherwise nil
    func stringToURLWithEncoding(with urlParamsString: String) -> URL? {
        guard String.isNotEmptyOrWhitespace(urlParamsString),
            let urlStringParamsEncoded = urlParamsString.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlHostAllowed),
            let url = URL(string: baseURL + urlStringParamsEncoded) else {
            return nil
        }
        return url
    }
}
