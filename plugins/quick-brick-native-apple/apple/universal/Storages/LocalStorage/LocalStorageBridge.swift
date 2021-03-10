//
//  LocalStorageBridge.swift
//  QuickBrickApple
//
//  Created by Anton Kononenko on 5/9/19.
//  Copyright © 2019 Applicaster LTD. All rights reserved.
//

import Foundation
import React
import ZappCore

public struct LocalErrorCallBack {
    public static let errorCode = "LocalStorageError"
    public static let errorMessageSet = "Local values could not be saved"
    public static let errorMessageGet = "Local values could not be retrieved"
    public static let errorMessageRemove = "Local values could not be removed"
}

@objc(LocalStorage)
class LocalStorageBridge: NSObject, RCTBridgeModule {
    var bridge: RCTBridge!

    static func moduleName() -> String! {
        return "LocalStorage"
    }

    public class func requiresMainQueueSetup() -> Bool {
        return true
    }

    // MARK: RC extern methods

    /// Store a stringified object in LocalStorage
    ///
    /// - Parameters:
    ///   - key: key name for value
    ///   - value: stringified value
    ///   - namespace: namespace to use when saving values to avoid collisions
    ///   - resolver: resolver when value is saved successfully
    ///   - rejecter: rejecter when something fails
    @objc public func setItem(_ key: String?, value: String?, namespace: String?,
                              resolver: @escaping RCTPromiseResolveBlock,
                              rejecter: @escaping RCTPromiseRejectBlock) {
        DispatchQueue.main.async {
            guard let key = key,
                  let value = value,
                  let storage = FacadeConnector.connector?.storage else {
                rejecter(LocalErrorCallBack.errorCode, LocalErrorCallBack.errorMessageSet, nil)
                return
            }

            if storage.localStorageSetValue(for: key,
                                            value: value,
                                            namespace: namespace) == true {
                resolver(true)
            } else {
                rejecter(LocalErrorCallBack.errorCode, LocalErrorCallBack.errorMessageSet, nil)
            }
        }
    }

    /// Get previously saved session value by key
    ///
    /// - Parameters:
    ///   - key: key to use for value retrieval
    ///   - namespace: namespace used when saving values
    ///   - resolver: resolver when everything succeed
    ///   - rejecter: rejecter when something fails
    @objc public func getItem(_ key: String?,
                              namespace: String?,
                              resolver: @escaping RCTPromiseResolveBlock,
                              rejecter: @escaping RCTPromiseRejectBlock) {
        DispatchQueue.main.async {
            guard let key = key,
                  let storage = FacadeConnector.connector?.storage else {
                rejecter(LocalErrorCallBack.errorCode, LocalErrorCallBack.errorMessageGet, nil)
                return
            }

            let retVal = storage.localStorageValue(for: key, namespace: namespace)
            resolver(retVal)
        }
    }

    /// Remove previously saved session value by key
    ///
    /// - Parameters:
    ///   - key: key to remove for value retrieval
    ///   - namespace: namespace used when saving values
    ///   - resolver: resolver when everything succeed
    ///   - rejecter: rejecter when something fails
    @objc public func removeItem(_ key: String?,
                                 namespace: String?,
                                 resolver: @escaping RCTPromiseResolveBlock,
                                 rejecter: @escaping RCTPromiseRejectBlock) {
        DispatchQueue.main.async {
            guard let key = key,
                  let storage = FacadeConnector.connector?.storage else {
                rejecter(LocalErrorCallBack.errorCode, LocalErrorCallBack.errorMessageRemove, nil)
                return
            }

            let retVal = storage.localStorageRemoveValue(for: key,
                                                         namespace: namespace)
            resolver(retVal)
        }
    }

    /// Get ALL previously saved session values
    ///
    /// - Parameters:
    ///   - namespace: namespace used when saving values
    ///   - resolver: resolver when everything succeed
    ///   - rejecter: rejecter when something fails
    @objc public func getAllItems(_ namespace: String?,
                                  resolver: @escaping RCTPromiseResolveBlock,
                                  rejecter: @escaping RCTPromiseRejectBlock) {
        DispatchQueue.main.async {
            guard let storage = FacadeConnector.connector?.storage else {
                rejecter(LocalErrorCallBack.errorCode, LocalErrorCallBack.errorMessageGet, nil)
                return
            }

            let retVal = storage.localStorageAllValues(namespace: namespace)
            resolver(retVal)
        }
    }

    /// Store a stringified object in Keychain
    ///
    /// - Parameters:
    ///   - key: key name for value
    ///   - value: stringified value
    ///   - namespace: namespace to use when saving values to avoid collisions
    ///   - resolver: resolver when value is saved successfully
    ///   - rejecter: rejecter when something fails
    @objc public func setKeychainItem(_ key: String?,
                                      value: String?,
                                      namespace: String?,
                                      resolver: @escaping RCTPromiseResolveBlock,
                                      rejecter: @escaping RCTPromiseRejectBlock) {
        DispatchQueue.main.async {
            guard let key = key,
                  let value = value,
                  let storage = FacadeConnector.connector?.storage else {
                rejecter(LocalErrorCallBack.errorCode, LocalErrorCallBack.errorMessageSet, nil)
                return
            }

            if storage.keychainStorageSetValue(for: key,
                                               value: value,
                                               namespace: namespace) == true {
                resolver(true)
            } else {
                rejecter(LocalErrorCallBack.errorCode, LocalErrorCallBack.errorMessageSet, nil)
            }
        }
    }

    /// Get previously saved Keychain value by key
    ///
    /// - Parameters:
    ///   - key: key to use for value retrieval
    ///   - namespace: namespace used when saving values
    ///   - resolver: resolver when everything succeed
    ///   - rejecter: rejecter when something fails
    @objc public func getKeychainItem(_ key: String?,
                                      namespace: String?,
                                      resolver: @escaping RCTPromiseResolveBlock,
                                      rejecter: @escaping RCTPromiseRejectBlock) {
        DispatchQueue.main.async {
            guard let key = key,
                  let storage = FacadeConnector.connector?.storage else {
                rejecter(LocalErrorCallBack.errorCode, LocalErrorCallBack.errorMessageGet, nil)
                return
            }

            let retVal = storage.keychainStorageValue(for: key, namespace: namespace)
            resolver(retVal)
        }
    }

    /// Remove previously saved Keychain value by key
    ///
    /// - Parameters:
    ///   - key: key to remove for value retrieval
    ///   - namespace: namespace used when saving values
    ///   - resolver: resolver when everything succeed
    ///   - rejecter: rejecter when something fails
    @objc public func removeKeychainItem(_ key: String?,
                                         namespace: String?,
                                         resolver: @escaping RCTPromiseResolveBlock,
                                         rejecter: @escaping RCTPromiseRejectBlock) {
        DispatchQueue.main.async {
            guard let key = key,
                  let storage = FacadeConnector.connector?.storage else {
                rejecter(LocalErrorCallBack.errorCode, LocalErrorCallBack.errorMessageRemove, nil)
                return
            }

            let retVal = storage.keychainStorageRemoveValue(for: key,
                                                            namespace: namespace)
            resolver(retVal)
        }
    }
}
