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
    }

    struct Params {
        static let jwtJsonKey = "jwt"
        static let jwtStorageKey = "signedDeviceInfoToken"
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
        makeDiServerCall()
        completion?(true)
    }

    public func disable(completion: ((Bool) -> Void)?) {
        _ = FacadeConnector.connector?.storage?.localStorageRemoveValue(for: Params.jwtStorageKey,
                                                                        namespace: nil)
        completion?(true)
    }

    public func makeDiServerCall() {
        guard let urlString = configurationJSON?["di_server_url"] as? String,
              let url = URL(string: urlString) else {
            logger?.errorLog(message: "Server Url not defined")
            return
        }

        URLSession.shared.dataTask(with: url) { data, _, error in
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
                _ = FacadeConnector.connector?.storage?.localStorageSetValue(for: Params.jwtStorageKey,
                                                                             value: jwt,
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

        }.resume()
    }
}
