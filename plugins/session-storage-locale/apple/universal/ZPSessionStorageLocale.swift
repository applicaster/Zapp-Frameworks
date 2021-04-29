//
//  ZPSessionStorageLocale.swift
//  ZappSessionStorageLocale
//
//  Created by Alex Zchut on 01/12/2020.
//  Copyright © 2020 Applicaster Ltd. All rights reserved.
//

import XrayLogger
import ZappCore

@objc public class ZPSessionStorageLocale: NSObject, GeneralProviderProtocol {
    public var model: ZPPluginModel?
    public var configurationJSON: NSDictionary?
    lazy var logger = Logger.getLogger(for: "\(kNativeSubsystemPath)/ZappSessionStorageLocale")

    fileprivate struct Params {
        static let defaultLanguage = "default_language"
        static let supportedLanguages = "supported_languages"
    }

    public required init(pluginModel: ZPPluginModel) {
        model = pluginModel
        configurationJSON = model?.configurationJSON
    }

    public var providerName: String {
        return String(describing: Self.self)
    }

    public func prepareProvider(_ defaultParams: [String: Any],
                                completion: ((_ isReady: Bool) -> Void)?) {
        completion?(true)
    }

    public func disable(completion: ((Bool) -> Void)?) {
        completion?(true)
    }

    lazy var defaultLanguage: String = {
        guard let value = configurationJSON?[Params.defaultLanguage] as? String else {
            logger?.errorLog(message: "Default language is not configured, using `en`")
            return "en"
        }
        return value
    }()

    lazy var supportedLanguages: [String] = {
        guard let value = configurationJSON?[Params.supportedLanguages] as? String else {
            logger?.errorLog(message: "Supported languages are not configured")
            return []
        }
        return value.components(separatedBy: ",")
    }()
}

extension ZPSessionStorageLocale: AppLoadingHookProtocol {
    public func executeOnApplicationReady(displayViewController: UIViewController?, completion: (() -> Void)?) {
        print(Locale.preferredLanguageCode)
//        _ = FacadeConnector.connector?.storage?.sessionStorageSetValue(for: "advertisingIdentifier",
//                                                                       value: idfaString,
//                                                                       namespace: nil)

        completion?()
    }
}

extension Locale {
    static var preferredLanguageCode: String {
        let defaultLanguage = "en"
        let preferredLanguage = preferredLanguages.first ?? defaultLanguage
        return Locale(identifier: preferredLanguage).languageCode ?? defaultLanguage
    }

    static var preferredLanguageCodes: [String] {
        return Locale.preferredLanguages.compactMap({ Locale(identifier: $0).languageCode })
    }
}
