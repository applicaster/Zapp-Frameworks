//
//  ZPAppleVideoSubscriptionRegistration.swift
//  ZappAppleVideoSubscriptionRegistration
//
//  Created by Alex Zchut on 05/02/2020.
//  Copyright © 2020 Applicaster Ltd. All rights reserved.
//

import ZappCore
import VideoSubscriberAccount

class ZPAppleVideoSubscriptionRegistration: NSObject, GeneralProviderProtocol {
    public var configurationJSON: NSDictionary?
    public var model: ZPPluginModel?

    lazy var isInfoPlistSupportEnabled:Bool = {
        guard let bundleDict = Bundle.main.infoDictionary,
            let bundleID = bundleDict["UISupportsTVApp"] as? Bool else {
                return false
        }
        return true
    }()

    lazy var hasNeededEntitlements:Bool = {
        guard isInfoPlistSupportEnabled == true else {
            return false
        }
        #if DEBUG
        return false
        #else
        return true
        #endif
    }()

    /// Plugin configuration keys
    struct PluginKeys {
        static let billingIdentifier = "billing_identifier"
        static let tierIdentifiers = "tier_identifiers"
    }

    public required init(pluginModel: ZPPluginModel) {
        model = pluginModel
        configurationJSON = model?.configurationJSON
    }

    public var providerName: String {
        return "Apple Video Subscription Registration"
    }

    public func prepareProvider(_ defaultParams: [String: Any],
                                completion: ((_ isReady: Bool) -> Void)?) {

        if self.hasNeededEntitlements {
            let subscription = VSSubscription()
            subscription.expirationDate = Date.distantFuture
            subscription.accessLevel = .paid
            if #available(iOS 11.3, tvOS 11.3, *) {
              if !billingIdentifier.isEmpty {
                  subscription.billingIdentifier = billingIdentifier
                  subscription.tierIdentifiers = tierIdentifiers
              }
            } else {
              // not activated for earlier versions
            }
            let registrationCenter = VSSubscriptionRegistrationCenter.default()
            registrationCenter.setCurrentSubscription(subscription)

            completion?(true)
        }
        else {
            completion?(false)
        }
    }

    public func disable(completion: ((Bool) -> Void)?) {
        let registrationCenter = VSSubscriptionRegistrationCenter.default()
        registrationCenter.setCurrentSubscription(nil)
        completion?(true)
    }


    lazy var billingIdentifier:String = {
        if let value = self.configurationJSON?[PluginKeys.billingIdentifier] as? String {
            return value
        }
        else {
            return ""
        }
    }()

    lazy var tierIdentifiers:[String] = {
        if let value = self.configurationJSON?[PluginKeys.tierIdentifiers] as? String {
            return value.components(separatedBy: ",")
        }
        else {
            return []
        }
    }()
}
