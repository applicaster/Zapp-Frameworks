//
//  ZappSessionStorageBridge.swift
//  QuickBrickApple
//
//  Created by Anton Kononenko on 5/9/19.
//  Copyright © 2019 Applicaster LTD. All rights reserved.
//

import Foundation
import React
import ZappCore

public struct StorageErrorCallback {
    public static let errorCode = "SessionStorageError"
    public static let errorMessageSet = "Session values could not be saved"
    public static let errorMessageGet = "Session values could not be retrieved"
    public static let errorMessageRemove = "Session values could not be removed"
}

@objc(SessionStorage)
class SessionStorageBridge: NSObject, RCTBridgeModule {
    var bridge: RCTBridge!

    static func moduleName() -> String! {
        return "SessionStorage"
    }

    public class func requiresMainQueueSetup() -> Bool {
        return true
    }

    // MARK: RC extern methods

    /// Store a stringified object in SessionStorage
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
                rejecter(StorageErrorCallback.errorCode, StorageErrorCallback.errorMessageSet, nil)
                return
            }

            if storage.sessionStorageSetValue(for: key,
                                              value: value,
                                              namespace: namespace) == true {
                resolver(true)
            } else {
                rejecter(StorageErrorCallback.errorCode, StorageErrorCallback.errorMessageSet, nil)
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
    @objc public func getItem(_ key: String?, namespace: String?,
                              resolver: @escaping RCTPromiseResolveBlock,
                              rejecter: @escaping RCTPromiseRejectBlock) {
        DispatchQueue.main.async {
            guard let key = key,
                  let storage = FacadeConnector.connector?.storage else {
                rejecter(StorageErrorCallback.errorCode, StorageErrorCallback.errorMessageGet, nil)
                return
            }

            let retVal = storage.sessionStorageValue(for: key, namespace: namespace)
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
                rejecter(LocalErrorCallBack.errorCode, StorageErrorCallback.errorMessageRemove, nil)
                return
            }

            let retVal = storage.sessionStorageRemoveValue(for: key,
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
                rejecter(StorageErrorCallback.errorCode, StorageErrorCallback.errorMessageGet, nil)
                return
            }
            let retVal = storage.sessionStorageAllValues(namespace: namespace)
            resolver(retVal)
        }
    }
}
