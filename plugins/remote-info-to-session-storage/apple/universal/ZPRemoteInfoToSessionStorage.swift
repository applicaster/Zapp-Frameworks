//
//  ZPRemoteInfoToSessionStorage.swift
//  ZappRemoteInfoToSessionStorage
//
//  Created by Alex Zchut on 14/02/2021.
//  Copyright © 2021 Applicaster Ltd. All rights reserved.
//

import XrayLogger
import ZappCore

@objc public class ZPRemoteInfoToSessionStorage: NSObject, GeneralProviderProtocol {
    public var model: ZPPluginModel?
    public var configurationJSON: NSDictionary?
    lazy var logger = Logger.getLogger(for: "\(kNativeSubsystemPath)/ZappRemoteInfoToSessionStorage")

    enum RemoteInfoError: String, Error {
        case NoDataReturnedFromServer = "Error: no data"
        case JsonParsingFailed = "Error: conversion from JSON failed"
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
        fetchRemoteInfo(completion)
    }

    public func disable(completion: ((Bool) -> Void)?) {
        completion?(true)
    }

    public func fetchRemoteInfo(_ completion: ((_ success: Bool) -> Void)?) {
        guard let urlString = configurationJSON?["remote_url"] as? String,
              !urlString.isEmpty,
              let url = URL(string: urlString) else {
            logger?.errorLog(message: "Remote Url not defined")
            return
        }

        guard let namespace = configurationJSON?["namespace"] as? String,
              !namespace.isEmpty else {
            logger?.errorLog(message: "Namespace not defined")
            return
        }

        URLSession.shared.dataTask(with: url) { data, _, error in
            DispatchQueue.main.async {
                do {
                    guard let data = data else {
                        throw RemoteInfoError.NoDataReturnedFromServer
                    }

                    guard let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] else {
                        throw RemoteInfoError.JsonParsingFailed
                    }

                    for (key, value) in json {
                        var valueToSave: String = ""
                        if let stringValue = value as? String {
                            valueToSave = stringValue
                        } else if let numberValue = value as? NSNumber {
                            valueToSave = numberValue.stringValue
                        } else if let valueDict = value as? [String: Any],
                                  let jsonString = self.jsonStringFrom(valueDict) {
                            valueToSave = jsonString
                        }

                        _ = FacadeConnector.connector?.storage?.sessionStorageSetValue(for: key,
                                                                                       value: valueToSave,
                                                                                       namespace: namespace)
                    }

                } catch let error as RemoteInfoError {
                    self.logger?.errorLog(message: "Remote info error",
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

extension ZPRemoteInfoToSessionStorage {
    /// Retrieve JSON string from Dictionary
    ///
    /// - Parameter dictionary: item to convert to JSON string
    /// - Returns: JSON String if can be created, otherwise nil
    public func jsonStringFrom(_ dictionary: [String: Any]) -> String? {
        let jsonData = try? JSONSerialization.data(withJSONObject: dictionary, options: [])
        guard let jsonString = String(data: jsonData!, encoding: .utf8) else {
            return nil
        }
        return jsonString
    }
}
