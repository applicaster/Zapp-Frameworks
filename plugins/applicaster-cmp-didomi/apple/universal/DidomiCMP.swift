//
//  DidomiCMP.swift
//  ConsentManagementDidomi
//
//  Created by Alex Zchut on 24/03/2021.
//  Copyright © 2021 Applicaster Ltd. All rights reserved.
//

import Didomi
import XrayLogger
import ZappCore

public class DidomiCMP: NSObject, GeneralProviderProtocol {
    public var model: ZPPluginModel?
    public var configurationJSON: NSDictionary?
    lazy var logger = Logger.getLogger(for: "\(kNativeSubsystemPath)/DidomiConsentManagement")

    struct Params {
        static let apiKey = "api_key"
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

        Didomi.shared.initialize(
            apiKey: apiKey,
            localConfigurationPath: nil,
            remoteConfigurationURL: nil,
            providerId: nil,
            disableDidomiRemoteConfig: false
        )

        Didomi.shared.onError(callback: { event in
            self.logger?.errorLog(message: "Intialization failed",
                                  data: ["error": event.descriptionText])
        })

        Didomi.shared.onReady {
            self.logger?.verboseLog(message: "Intialization completed successfully")
        }

        requestTrackingAuthorizationWhenApplicable()

        completion?(true)
    }

    public func disable(completion: ((Bool) -> Void)?) {
        completion?(true)
    }

    func requestTrackingAuthorizationWhenApplicable() {
        let didomiEventListener = EventListener()
        Didomi.shared.addEventListener(listener: didomiEventListener)

        didomiEventListener.onNoticeClickAgree = { _ in
            // Click on Agree in the notice
            // Request tracking permission from the user
            self.requestTrackingAuthorization { status in
                switch status {
                case .authorized:
                    Didomi.shared.setUserAgreeToAll()
                case .denied:
                    Didomi.shared.setUserDisagreeToAll()
                case .restricted:
                    Didomi.shared.setUserDisagreeToAll()
                case .notDetermined:
                    break
                }
            }
        }

        didomiEventListener.onPreferencesClickAgreeToAll = { _ in
            // Click on Agree to all in the Preferences popup
            // Request tracking permission from the user
            self.requestTrackingAuthorization { status in
                switch status {
                case .authorized:
                    Didomi.shared.setUserAgreeToAll()
                case .denied:
                    Didomi.shared.setUserDisagreeToAll()
                case .restricted:
                    Didomi.shared.setUserDisagreeToAll()
                case .notDetermined:
                    break
                }
            }
        }
    }
}

public enum AuthorizationStatus: UInt {
    case notDetermined = 0
    case restricted = 1
    case denied = 2
    case authorized = 3
}
