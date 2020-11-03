//
//  ZPAppleVideoSubscriptionRegistration.swift
//  ZappAppleVideoSubscriptionRegistration
//
//  Created by Alex Zchut on 05/02/2020.
//  Copyright © 2020 Applicaster Ltd. All rights reserved.
//

import VideoSubscriberAccount
import ZappCore

class ZPAppleVideoSubscriptionRegistration: NSObject {
    public var configurationJSON: NSDictionary?
    public var model: ZPPluginModel?

    public required init(pluginModel: ZPPluginModel) {
        model = pluginModel
        configurationJSON = model?.configurationJSON
    }
    
    lazy var isInfoPlistSupportEnabled: Bool = {
        guard let bundleDict = Bundle.main.infoDictionary,
            let bundleID = bundleDict["UISupportsTVApp"] as? Bool else {
            return false
        }
        return true
    }()

    lazy var hasNeededEntitlements: Bool = {
        guard isInfoPlistSupportEnabled == true else {
            return false
        }

        return true
    }()

    /// Plugin configuration keys
    struct PluginKeys {
        static let billingIdentifier = "billing_identifier"
        static let tierIdentifiers = "tier_identifiers"
        static let accessLevel = "access_level"
    }

    lazy var billingIdentifier: String = {
        guard let value = self.configurationJSON?[PluginKeys.billingIdentifier] as? String
        else {
            return ""
        }
        return value
    }()

    lazy var tierIdentifiers: [String] = {
        guard let value = self.configurationJSON?[PluginKeys.tierIdentifiers] as? String
        else {
            return []
        }
        return value.components(separatedBy: ",")

    }()

    lazy var accessLevel: VSSubscriptionAccessLevel = {
        guard let value = self.configurationJSON?[PluginKeys.accessLevel] as? String,
            let intValue = Int(value), intValue > 0,
            let accessLevel = VSSubscriptionAccessLevel(rawValue: intValue)
        else {
            return .unknown
        }
        return accessLevel
    }()
    
    func activateSubscriptionfIfNeeded() -> Bool {
        var retValue = false
        if hasNeededEntitlements,
            accessLevel != .unknown {
            let subscription = VSSubscription()
            subscription.expirationDate = Date.distantFuture
            subscription.accessLevel = accessLevel
            if tierIdentifiers.count > 0 {
                subscription.tierIdentifiers = tierIdentifiers
            }
            if #available(iOS 11.3, tvOS 11.3, *) {
                if !billingIdentifier.isEmpty {
                    subscription.billingIdentifier = billingIdentifier
                }
            } else {
                // not activated for earlier versions
            }
            let registrationCenter = VSSubscriptionRegistrationCenter.default()
            registrationCenter.setCurrentSubscription(subscription)

            retValue = true
        }
        return retValue
    }
}

extension ZPAppleVideoSubscriptionRegistration: GeneralProviderProtocol {
    public var providerName: String {
        return "Apple Video Subscription Registration"
    }

    public func prepareProvider(_ defaultParams: [String: Any],
                                completion: ((_ isReady: Bool) -> Void)?) {
        let result = activateSubscriptionfIfNeeded()
        if result {
            addNotificationsObserver()
        }
        completion?(result)
    }

    public func disable(completion: ((Bool) -> Void)?) {
        let registrationCenter = VSSubscriptionRegistrationCenter.default()
        registrationCenter.setCurrentSubscription(nil)
        removeNotificationsObserver()
        completion?(true)
    }
}

extension ZPAppleVideoSubscriptionRegistration {
    func addNotificationsObserver() {
        let defaultCenter = NotificationCenter.default

        defaultCenter.addObserver(self,
                                  selector: #selector(didBecomeActiveNotification(notification:)),
                                  name: UIApplication.didBecomeActiveNotification,
                                  object: nil)
    }

    func removeNotificationsObserver() {
        let defaultCenter = NotificationCenter.default
        defaultCenter.removeObserver(self,
                                     name: UIApplication.didBecomeActiveNotification,
                                     object: nil)
    }

    @objc func didBecomeActiveNotification(notification: Notification) {
        _ = activateSubscriptionfIfNeeded()
    }
}
