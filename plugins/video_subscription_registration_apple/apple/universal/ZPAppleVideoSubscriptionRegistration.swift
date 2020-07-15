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
        return true
    }()

    /// Plugin configuration keys
    struct PluginKeys {
        static let billingIdentifier = "billing_identifier"
        static let tierIdentifiers = "tier_identifiers"
        static let accessLevel = "access_leval"
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

        if self.hasNeededEntitlements,
            self.accessLevel != .unknown {
            
            let subscription = VSSubscription()
            subscription.expirationDate = Date.distantFuture
            subscription.accessLevel = self.accessLevel
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
        guard let value = self.configurationJSON?[PluginKeys.billingIdentifier] as? String
            else {
            return ""
        }
        return value
    }()

    lazy var tierIdentifiers:[String] = {
        guard let value = self.configurationJSON?[PluginKeys.tierIdentifiers] as? String
            else {
            return []
        }
        return value.components(separatedBy: ",")

    }()
    
    lazy var accessLevel:VSSubscriptionAccessLevel = {
        guard let value = self.configurationJSON?[PluginKeys.accessLevel] as? String,
            let intValue = Int(value), intValue > 0,
            let accessLevel = VSSubscriptionAccessLevel(rawValue: intValue)
            else {
            return .unknown
        }
        return accessLevel
    }()
}
