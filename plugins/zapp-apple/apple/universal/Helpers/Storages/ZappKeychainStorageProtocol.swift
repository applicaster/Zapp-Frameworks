//
//  ZappKeychainStorageProtocol.swift
//  ZappApple
//
//  Created by Anton Kononenko on 14/1/21.
//  Copyright © 2021 Applicaster LTD. All rights reserved.
//

import Foundation

/// This prtocol represents public API for Zapp Keychain Storage
@objc public protocol ZappKeychainStorageProtocol {
    /// Save to keychain storage item for specific key
    ///
    /// - Parameters:
    ///   - key: The key with which to associate the value.
    ///   - value: The object to store in storage.
    ///   - namespace: Namespace that will be used for save item
    /// - Returns: true if saving succeed
    func setKeychain(key: String,
                     value: String?,
                     namespace: String?) -> Bool

    /// Retrieve value from the keychain storage
    ///
    /// - Parameters:
    ///   - key: The key with which to associate the value.
    ///   - namespace: Namespace that where value will be searched
    /// - Returns: String Value represantation of the JSON if item was founded outherwise nil
    func getKeychain(key: String,
                     namespace: String?) -> String?

    /// Remove the key from the keychain storage
    ///
    /// - Parameters:
    ///   - key: The key with which to associate the value.
    ///   - namespace: Namespace that where value will be searched
    /// - Returns: true if removing succeed
    func removeKeychainItem(key: String,
                            namespace: String?) -> Bool
}
