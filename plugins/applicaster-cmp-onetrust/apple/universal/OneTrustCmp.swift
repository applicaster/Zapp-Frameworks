//
//  OneTrustCmp.swift
//  ZappCmpOneTrust
//
//  Created by Alex Zchut on 13/06/2021.
//  Copyright © 2021 Applicaster Ltd. All rights reserved.
//

#if os(tvOS) && canImport(OTPublishersHeadlessSDKtvOS)
    import OTPublishersHeadlessSDKtvOS
#elseif os(iOS) && canImport(OTPublishersHeadlessSDK)
    import OTPublishersHeadlessSDK
#endif
import XrayLogger
import ZappCore

public class OneTrustCmp: NSObject, GeneralProviderProtocol {
    public var model: ZPPluginModel?
    public var configurationJSON: NSDictionary?
    lazy var logger = Logger.getLogger(for: "\(kNativeSubsystemPath)/OneTrustConsentManagement")
    var presentationCompletion: (() -> Void)?
    public var cmpInitStatus: OneTrustInitializationStatus = .undefined
    public var cmpAcceptanceStatus: OneTrustAcceptanceStatus = .notCollected {
        didSet {
            updateAnalyticsProvidersIfNeeded()
        }
    }

    struct Params {
        static let domainIdentifier = "domain_identifier"
        static let storageLocation = "storage_location"

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

    lazy var domainIdentifier: String? = {
        configurationJSON?[Params.domainIdentifier] as? String
    }()

    lazy var storageLocation: String? = {
        configurationJSON?[Params.storageLocation] as? String
    }()

    var languageCode: String = {
        var retValue = "en"
        guard let appLanguageCode = FacadeConnector.connector?.storage?.sessionStorageValue(for: "languageCode", namespace: nil) else {
            return retValue
        }
        return appLanguageCode
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
        guard let domainIdentifier = domainIdentifier else {
            logger?.errorLog(message: "Api Identifier not defined")
            completion?(true)
            return
        }

        guard let storageLocation = storageLocation else {
            logger?.errorLog(message: "Storage location not defined")
            completion?(true)
            return
        }

        subscribeToEventListeners()
        let sdkParams = OTSdkParams(countryCode: nil, regionCode: nil)
        OTPublishersHeadlessSDK.shared.startSDK(
            storageLocation: storageLocation,
            domainIdentifier: domainIdentifier,
            languageCode: languageCode,
            params: sdkParams
        ) { response in

            if response.status {
                self.cmpInitStatus = .ready
            } else if let _ = response.error {
                self.cmpInitStatus = .error
            }

            let status = response.responseString != nil
            let error = response.error
            self.logger?.debugLog(message: "Initialized with status: \(status) and error \(error?.localizedDescription ?? "No error available").)")
        }

        completion?(true)
    }

    public func disable(completion: ((Bool) -> Void)?) {
        completion?(true)
    }

    func updateAnalyticsProvidersIfNeeded() {
        switch cmpAcceptanceStatus {
        case .given:
            _ = FacadeConnector.connector?.pluginManager?.enableAllPlugins(pluginType: ZPPluginType.Analytics.rawValue, completion: nil)
        case .notGiven:
            _ = FacadeConnector.connector?.pluginManager?.disableAllPlugins(pluginType: ZPPluginType.Analytics.rawValue, completion: nil)
        default:
            break
        }
    }
}

public enum OTAuthorizationStatus: UInt {
    case notDetermined = 0
    case restricted = 1
    case denied = 2
    case authorized = 3
}

public enum OneTrustInitializationStatus {
    case undefined
    case ready
    case error
}

public enum OneTrustAcceptanceStatus: Int {
    case given = 1
    case notGiven = 0
    case notCollected = -1
}
