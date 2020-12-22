//
//  LocalStorage.swift
//  ZappApple
//
//  Created by Anton Kononenko on 5/9/19.
//  Copyright © 2019 Applicaster LTD. All rights reserved.
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
        userDefaults.setValue(storage,
                              forKey: zappLocalStorageName)
        userDefaults.synchronize()
    }

    // MARK: ZappStorageProtocol

    @discardableResult public func set(key: String, value: String?, namespace: String?) -> Bool {
        guard get(key: key, namespace: namespace) != value else {
            return true
        }

        let setResult = StorageHelper.setZappData(inStorageDict: storage,
                                                  key: key,
                                                  value: value,
                                                  namespace: namespace,
                                                  storageType: .local)

        saveToUserDefaults(storage: setResult.storageDict)
        return setResult.succeed
    }

    public func get(key: String, namespace: String?) -> String? {
        return StorageHelper.getZappData(inStorageDict: storage,
                                         key: key,
                                         namespace: namespace)
    }

    public func removeItem(key: String,
                           namespace: String?) -> Bool {
        let removeResult = StorageHelper.removeItem(inStorageDict: storage,
                                                    key: key,
                                                    namespace: namespace)

        saveToUserDefaults(storage: removeResult.storageDict)
        return removeResult.succeed
    }

    public func getAll(namespace: String?) -> String? {
        return StorageHelper.getAll(inStorageDict: storage,
                                    namespace: namespace)
    }
}
