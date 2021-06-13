//
//  OneTrustCmp.swift
//  ZappCmpOneTrust
//
//  Created by Alex Zchut on 13/06/2021.
//  Copyright © 2021 Applicaster Ltd. All rights reserved.
//

import OneTrust
import XrayLogger
import ZappCore

public class OneTrustCmp: NSObject, GeneralProviderProtocol {
    public var model: ZPPluginModel?
    public var configurationJSON: NSDictionary?
    lazy var logger = Logger.getLogger(for: "\(kNativeSubsystemPath)/OneTrustConsentManagement")
    var presentationCompletion: (() -> Void)?
    public var cmpStatus: OneTrustCmpStatus = .undefined
    
    struct Params {
        static let apiKey = "api_key"
        static let jsPreferencesKey = "javaScriptForWebView"
        static let pluginIdentifier = "applicaster-cmp-onetrust"
        static let onetrustGDPRApplies = "IABTCF_gdprApplies"
        static let onetrustIABConsent = "IABTCF_TCString"

    }

    public required init(pluginModel: ZPPluginModel) {
        model = pluginModel
        configurationJSON = model?.configurationJSON
    }

    public var providerName: String {
        return String(describing: Self.self)
    }

    lazy var apiKey: String? = {
        configurationJSON?["api_key"] as? String
    }()

    lazy var shouldPresentOnStartup: Bool = {
        var retValue: Bool = true

        guard let value = configurationJSON?["present_on_startup"] else {
            return retValue
        }

        // Check if value bool or string
        if let stringValue = value as? String {
            if let boolValue = Bool(stringValue) {
                retValue = boolValue
            } else if let intValue = Int(stringValue) {
                retValue = Bool(truncating: intValue as NSNumber)
            }
        } else if let boolValue = value as? Bool {
            retValue = boolValue
        }
        return retValue
    }()

    public func prepareProvider(_ defaultParams: [String: Any],
                                completion: ((_ isReady: Bool) -> Void)?) {
        guard let apiKey = apiKey else {
            logger?.errorLog(message: "Api Key not defined")
            completion?(true)
            return
        }

        OneTrust.shared.initialize(
            apiKey: apiKey,
            localConfigurationPath: nil,
            remoteConfigurationURL: nil,
            providerId: nil,
            disableOneTrustRemoteConfig: false
        )

        OneTrust.shared.onError(callback: { event in
            self.logger?.errorLog(message: "Intialization failed",
                                  data: ["error": event.descriptionText])
            self.cmpStatus = .error
        })
        OneTrust.shared.onReady {
            self.logger?.verboseLog(message: "Intialization completed successfully")
            self.saveParamsToSessionStorageIfExists()
            self.cmpStatus = .ready
        }

        subscribeToEventListeners()
        

        completion?(true)
    }

    public func disable(completion: ((Bool) -> Void)?) {
        completion?(true)
    }
}



public enum AuthorizationStatus: UInt {
    case notDetermined = 0
    case restricted = 1
    case denied = 2
    case authorized = 3
}

public enum OneTrustCmpStatus {
    case undefined
    case ready
    case error
}
