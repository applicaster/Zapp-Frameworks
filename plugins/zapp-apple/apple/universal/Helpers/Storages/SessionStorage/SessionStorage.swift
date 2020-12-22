//
//  SessionStorage.swift
//  ZappApple
//
//  Created by Anton Kononenko on 5/9/19.
//  Copyright © 2019 Applicaster LTD. All rights reserved.
//

import Foundation

@objc public class SessionStorage: NSObject, ZappStorageProtocol {
    public static let sharedInstance = SessionStorage()

    /// Dictionary that used as Zapp Session Storage
    public private(set) var storage: [String: Any]

    override public init() {
        storage = StorageHelper.createEmptyZappStorage()
        super.init()
    }

    // MARK: ZappStorageProtocol

    @discardableResult public func set(key: String, value: String?, namespace: String?) -> Bool {
        let setResult = StorageHelper.setZappData(inStorageDict: storage,
                                                  key: key,
                                                  value: value,
                                                  namespace: namespace,
                                                  storageType: .session)
        storage = setResult.storageDict
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
        storage = removeResult.storageDict
        return removeResult.succeed
    }

    public func getAll(namespace: String?) -> String? {
        return StorageHelper.getAll(inStorageDict:
            storage, namespace: namespace)
    }
}
