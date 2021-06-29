//
//  SegmentAnalytics.swift
//  SegmentAnalytics
//
//  Created by Roman Karpievich on 7/1/20.
//  Updated by Alex Zchut on 10/03/2021.
//  Copyright © 2021 Applicaster Ltd. All rights reserved.
//

import Analytics
import AVFoundation
import Foundation
import ZappCore

/*
 For more infomration check the Segment API docs:
 https://segment.com/docs/connections/sources/catalog/libraries/mobile/ios/
 */
class SegmentAnalytics: NSObject, PluginAdapterProtocol {
    open var providerProperties: [String: NSObject] = [:]
    open var configurationJSON: NSDictionary?

    public var model: ZPPluginModel?
    public var providerName: String {
        return getKey()
    }

    public func getKey() -> String {
        return Params.pluginKey
    }

    struct Params {
        static let pluginKey = "SegmentAnalytics"
        static let pluginIdentifier = "segment_analytics"
        static let identityStorageKey = "identity"
    }

    var isDisabled = false
    var playbackStalled: Bool = false
    public var playerPlugin: PlayerProtocol?
    var objcHelper: SegmentAnalyticsHelper?
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
        if let segmentKey = model?.configurationValue(for: "segment_write_key") as? String,
           segmentKey.isEmpty == false {
            let configuration = SEGAnalyticsConfiguration(writeKey: segmentKey)
            configuration.trackApplicationLifecycleEvents = true
            configuration.recordScreenViews = false

            SEGAnalytics.setup(with: configuration)
            objcHelper = SegmentAnalyticsHelper(providerProperties: providerProperties,
                                                delegate: self)

            sendLoginInformationIfAvailable()
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

extension SegmentAnalytics {
    @objc public func login(with identity: String,
                            traits: [String: Any]?,
                            options: [String: Any]?) {
        // check if the plugin is enabled
        guard isDisabled == false else {
            storeLoginData(with: identity,
                           traits: traits,
                           options: options)
            return
        }

        SEGAnalytics.shared()?.identify(identity,
                                        traits: traits,
                                        options: options)
    }

    func storeLoginData(with identity: String,
                        traits: [String: Any]?,
                        options: [String: Any]?) {
        let object = IdentityObject(identity: identity,
                                    traits: traits,
                                    options: options)

        DispatchQueue.main.async {
            _ = FacadeConnector.connector?.storage?.sessionStorageSetValue(for: Params.identityStorageKey,
                                                                           value: object.toJsonString(),
                                                                           namespace: Params.pluginIdentifier)
        }
    }

    func fetchLoginData() -> IdentityObject? {
            guard let storageValue = FacadeConnector.connector?.storage?.sessionStorageValue(for: Params.identityStorageKey,

                                                                                             namespace: Params.pluginIdentifier) else {
                return nil
            }

            // remove the content
            _ = FacadeConnector.connector?.storage?.sessionStorageRemoveValue(for: Params.identityStorageKey,
                                                                              namespace: Params.pluginIdentifier)
            return IdentityObject(jsonString: storageValue)
    }

    func sendLoginInformationIfAvailable() {
            guard let identityObject = fetchLoginData() else {
                return
            }

            login(with: identityObject.identity,
                       traits: identityObject.traits,
                       options: identityObject.options)

    }
}

struct IdentityObject {
    var identity: String
    var traits: [String: Any]?
    var options: [String: Any]?

    private enum CodingKeys: String {
        case identity, traits, options
    }

    init(identity: String,
         traits: [String: Any]?,
         options: [String: Any]?) {
        self.identity = identity
        self.traits = traits
        self.options = options
    }

    init?(jsonString: String) {
        guard let object = IdentityObject.fromJsonString(jsonString) else {
            return nil
        }
        
        identity = object.identity
        traits = object.traits
        options = object.options
    }

    private init(dictionary: [String: Any]?) {
        identity = dictionary?[CodingKeys.identity.rawValue] as? String ?? ""
        traits = dictionary?[CodingKeys.traits.rawValue] as? [String: Any]
        options = dictionary?[CodingKeys.options.rawValue] as? [String: Any]
    }

    private var dictionary: [String: Any] {
        return [
            CodingKeys.identity.rawValue: identity,
            CodingKeys.traits.rawValue: traits ?? [:],
            CodingKeys.options.rawValue: options ?? [:],
        ]
    }

    func toJsonString(_ options: JSONSerialization.WritingOptions = .prettyPrinted) -> String? {
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: dictionary,
                                                      options: options)
            let jsonString = String(data: jsonData,
                                    encoding: .utf8)
            return jsonString
        } catch {
            return nil
        }
    }

    static func fromJsonString(_ jsonString: String) -> IdentityObject? {
        var retValue: IdentityObject?
        guard let data = jsonString.data(using: String.Encoding.utf8) else {
            return retValue
        }

        do {
            let dictionary = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? [String: Any]
            retValue = IdentityObject(dictionary: dictionary)
        } catch {
            print("unable to parse the identity object")
        }
        return retValue
    }
}
