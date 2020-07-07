//
//  ZappStorageProtocol.swift
//  ZappTvOS
//
//  Created by Anton Kononenko on 5/9/19.
//  Copyright © 2019 Anton Kononenko. All rights reserved.
//

import Foundation

/// This prtocol represents public API for Zapp Storage
@objc public protocol ZappStorageProtocol {
    
    /// Save to storage item for specific key
    ///
    /// - Parameters:
    ///   - key: The key with which to associate the value.
    ///   - value: The object to store in storage.
    ///   - namespace: Namespace that will be used for save item
    /// - Returns: true if saving succeed
    func set(key: String,
             value: String,
             namespace: String?) -> Bool
    
    /// Retrieve value from the storage
    ///
    /// - Parameters:
    ///   - key: The key with which to associate the value.
    ///   - namespace: Namespace that where value will be searched
    /// - Returns: String Value represantation of the JSON if item was founded outherwise nil
    func get(key: String, namespace: String?) -> String?
    
    /// Get all items for current storage
    ///   - namespace: Namespace that where value will be searched
    /// - Returns: String Value represantation of the JSON of all items that stores in the storage, in case namespace not nil All items for defined namespace
    func getAll(namespace: String?) -> String?
}
