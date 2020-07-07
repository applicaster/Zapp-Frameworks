//
//  LocalStorage.swift
//  ZappApple
//
//  Created by Anton Kononenko on 5/9/19.
//  Copyright © 2019 Anton Kononenko. All rights reserved.
//

import Foundation

@objc public class LocalStorage: NSObject, ZappStorageProtocol {
    public static let sharedInstance = LocalStorage()

    let userDefaults = UserDefaults.standard

    public var storage: [String: Any] {
        if let localStorage = userDefaults.object(forKey: zappLocalStorageName) as? [String: Any] {
            return localStorage
        } else {
            let retVal = StorageHelper.createEmptyZappStorage()
            saveToUserDefaults(storage: retVal)
            return retVal
        }
    }

    func saveToUserDefaults(storage: [String: Any]) {
        userDefaults.setValue(storage, forKey: zappLocalStorageName)
        userDefaults.synchronize()
    }

    // MARK: ZappStorageProtocol

    @discardableResult public func set(key: String, value: String, namespace: String?) -> Bool {
        let setResult = StorageHelper.setZappData(inStorageDict: storage,
                                                  key: key,
                                                  value: value,
                                                  namespace: namespace)
        saveToUserDefaults(storage: setResult.storageDict)
        return setResult.succeed
    }

    public func get(key: String, namespace: String?) -> String? {
        return StorageHelper.getZappData(inStorageDict: storage,
                                         key: key,
                                         namespace: namespace)
    }

    public func getAll(namespace: String?) -> String? {
        return StorageHelper.getAll(inStorageDict: storage,
                                    namespace: namespace)
    }
}
