//
//  ZPDiManager.swift
//  ZappDiManager
//
//  Created by Alex Zchut on 14/01/2021.
//  Copyright © 2021 Applicaster Ltd. All rights reserved.
//

import AdSupport
import ZappCore
import XrayLogger

@objc public class ZPDiManager: NSObject, GeneralProviderProtocol {
    public var model: ZPPluginModel?
    public var configurationJSON: NSDictionary?
    lazy var logger = Logger.getLogger(for: "\(kNativeSubsystemPath)/ZappDiManager")

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
}

extension ZPDiManager: AppLoadingHookProtocol {
    enum JSONError: String, Error {
        case NoData = "Error: no data"
        case ConversionFailed = "Error: conversion from JSON failed"
        case NoJWTvalue = "Error: JWT param can not be fetched"
    }
    
    struct Params {
        static let jwtJsonKey = "jwt"
        static let jwtStorageKey = "signedDeviceInfoToken"

    }
    
    public func executeOnApplicationReady(displayViewController: UIViewController?, completion: (() -> Void)?) {
        
        guard let urlString = configurationJSON?["di_server_url"] as? String,
              let url = URL(string: urlString) else {
            self.logger?.errorLog(message: "Server Url not defined")
            completion?()
            return
        }
        
        URLSession.shared.dataTask(with: url) { (data, response, error) in
            do {
                guard let data = data else {
                    throw JSONError.NoData
                }
                
                guard let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] else {
                    throw JSONError.ConversionFailed
                }
                
                guard let jwt = json[Params.jwtJsonKey] as? String else {
                    throw JSONError.NoJWTvalue
                }
                _ = FacadeConnector.connector?.storage?.sessionStorageSetValue(for: Params.jwtStorageKey,
                                                                               value: jwt,
                                                                               namespace: nil)
                
            } catch let error as JSONError {
                self.logger?.errorLog(message: "DI Server error",
                                 data: ["url": urlString,
                                        "error": error.localizedDescription])
            } catch let error as NSError {
                self.logger?.errorLog(message: "DI Server error",
                                 data: ["url": urlString,
                                        "error": error.localizedDescription])
            }
            
            completion?()

        }.resume()
    }
}
