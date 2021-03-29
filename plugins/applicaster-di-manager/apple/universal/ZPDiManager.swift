//
//  ZPDiManager.swift
//  ZappDiManager
//
//  Created by Alex Zchut on 14/01/2021.
//  Copyright © 2021 Applicaster Ltd. All rights reserved.
//

import AdSupport
import XrayLogger
import ZappCore

@objc public class ZPDiManager: NSObject, GeneralProviderProtocol {
    public var model: ZPPluginModel?
    public var configurationJSON: NSDictionary?
    lazy var logger = Logger.getLogger(for: "\(kNativeSubsystemPath)/ZappDiManager")

    enum DiError: String, Error {
        case NoDataReturnedFromServer = "Error: no data"
        case JsonParsingFailed = "Error: conversion from JSON failed"
        case NoJWTvalue = "Error: JWT param can not be fetched"
        case NoCountryCodevalue = "Error: Country code param can not be fetched"
    }

    struct Params {
        static let jwtJsonKey = "jwt"
        static let countryCodeKey = "country-code"
        static let jwtStorageKey = "signedDeviceInfoToken"
        static let countryCodeStorageKey = "country_code"
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
        makeDiServerCall(completion)
    }

    public func disable(completion: ((Bool) -> Void)?) {
        _ = FacadeConnector.connector?.storage?.sessionStorageRemoveValue(for: Params.jwtStorageKey,
                                                                        namespace: nil)
        completion?(true)
    }

    public func makeDiServerCall(_ completion: ((_ success: Bool) -> Void)?) {
        guard let urlString = configurationJSON?["di_server_url"] as? String,
              let url = URL(string: urlString) else {
            logger?.errorLog(message: "Server Url not defined")
            return
        }

        URLSession.shared.dataTask(with: url) { data, _, error in
            DispatchQueue.main.async {
                do {
                    guard let data = data else {
                        throw DiError.NoDataReturnedFromServer
                    }

                    guard let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] else {
                        throw DiError.JsonParsingFailed
                    }

                    guard let jwt = json[Params.jwtJsonKey] as? String else {
                        throw DiError.NoJWTvalue
                    }
                    _ = FacadeConnector.connector?.storage?.sessionStorageSetValue(for: Params.jwtStorageKey,
                                                                                   value: jwt,
                                                                                   namespace: nil)

                    guard let countryCode = json[Params.countryCodeKey] as? String else {
                        throw DiError.NoCountryCodevalue
                    }
                    _ = FacadeConnector.connector?.storage?.sessionStorageSetValue(for: Params.countryCodeStorageKey,
                                                                                   value: countryCode,
                                                                                   namespace: nil)
                } catch let error as DiError {
                    self.logger?.errorLog(message: "DI Server error",
                                          data: ["url": urlString,
                                                 "error": error.localizedDescription])
                } catch let error as NSError {
                    self.logger?.errorLog(message: "DI Server error",
                                          data: ["url": urlString,
                                                 "error": error.localizedDescription])
                }
            }

            if self.shouldWaitForCompletion {
                completion?(true)
            }

        }.resume()

        if shouldWaitForCompletion == false {
            completion?(true)
        }
    }

    lazy var shouldWaitForCompletion: Bool = {
        var retValue: Bool = true

        guard let value = configurationJSON?["wait_for_completion"] else {
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
}
