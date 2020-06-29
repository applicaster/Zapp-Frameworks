//
//  StorageHelper.swift
//  ZappApple
//
//  Created by Anton Kononenko on 5/9/19.
//  Copyright © 2019 Anton Kononenko. All rights reserved.
//

import Foundation

public class StorageHelper {
    /// Create empty object that conforms Zapp storage API
    ///
    /// - Returns: Instance of the dictionary
    public class func createEmptyZappStorage() -> [String: Any] {
        let sessionData: [String: Any] = [String: Any]()
        let namespaceDict: [String: Any] = [ZappStorageKeys.applicasterNamespace: sessionData]
        let emptyZappStorage: [String: Any] = [ZappStorageKeys.zapp: namespaceDict]
        return emptyZappStorage
    }

    /// Set value to Zapp storage dict for key in namespace domain
    ///
    /// - Parameters:
    ///   - storageDict: Dictionary where should be samve
    ///   - key: The key with which to associate the value.
    ///   - value: The object to store in storage.
    ///   - namespace: Namespace that will be used for save item
    /// - Returns: Zapp storage dictionary with updated values
    public class func setZappData(inStorageDict storageDict: [String: Any],
                                  key: String,
                                  value: String,
                                  namespace: String?) -> (storageDict: [String: Any], succeed: Bool) {
        var sessionData: [String: Any] = [String: Any]()
        var namespaceToUse = ZappStorageKeys.applicasterNamespace
               if let namespace = namespace,
                   namespace.isEmpty == false {
                   namespaceToUse = namespace
               }

        guard var namespaceDict = storageDict[ZappStorageKeys.zapp] as? [String: Any] else { return (storageDict: storageDict, succeed: false) }

        if let currentNamespaceSessionData = namespaceDict[namespaceToUse] as? [String: Any] {
            sessionData = currentNamespaceSessionData
        }

        sessionData[key] = value
        namespaceDict[namespaceToUse] = sessionData

        return (storageDict: [ZappStorageKeys.zapp: namespaceDict], succeed: true)
    }

    /// Retrieve data from Zapp storage dict for key in namespace domain
    ///
    /// - Parameters:
    ///   - storageDict: Dictionary where should be samve
    ///   - key: The key with which to associate the value.
    ///   - namespace: Namespace that will be used for save item
    /// - Returns: String Value represantation of the JSON if item was founded outherwise nil
    public class func getZappData(inStorageDict storageDict: [String: Any],
                                  key: String,
                                  namespace: String?) -> String? {
        var namespaceToUse = ZappStorageKeys.applicasterNamespace
        if let namespace = namespace,
            namespace.isEmpty == false {
            namespaceToUse = namespace
        }
        
        guard let namespaceDicts = storageDict[ZappStorageKeys.zapp] as? [String: Any],
            let currentNamespaceSessionData = namespaceDicts[namespaceToUse] as? [String: Any] else { return nil }

        if let retVal = currentNamespaceSessionData[key] as? String {
            return retVal
        } else if let retVal = currentNamespaceSessionData[key] as? [String: Any] {
            return getJSONStringFrom(dictionary: retVal)
        }
        return nil
    }

    /// Retrieve All Items from storage for namespace domain

    ///
    /// - Parameters:
    ///   - storageDict: Dictionary where should be samve
    ///   - namespace: Namespace that will be used for save item
    /// - Returns: String Value represantation of the JSON. If namespace not nil will return all items for namespace domain, otherwise all storage items
    public class func getAll(inStorageDict storageDict: [String: Any],
                             namespace: String?) -> String? {
      var namespaceToUse = ZappStorageKeys.applicasterNamespace
        if let namespace = namespace,
            namespace.isEmpty == false {
            namespaceToUse = namespace
        }

        guard let namespaceDicts = storageDict[ZappStorageKeys.zapp] as? [String: Any],
            let currentNamespaceSessionData = namespaceDicts[namespaceToUse] as? [String: Any] else { return nil }

        return getJSONStringFrom(dictionary: currentNamespaceSessionData)
    }

    /// Retrieve JSON string from Dictionary
    ///
    /// - Parameter dictionary: item to convert to JSON string
    /// - Returns: JSON String if can be created, otherwise nil
    public class func getJSONStringFrom(dictionary: [String: Any]) -> String? {
        let jsonData = try? JSONSerialization.data(withJSONObject: dictionary, options: [])
        guard let jsonString = String(data: jsonData!, encoding: .utf8) else {
            return nil
        }
        return jsonString
    }
    
}
