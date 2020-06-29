//
//  SessionStorage.swift
//  ZappApple
//
//  Created by Anton Kononenko on 5/9/19.
//  Copyright © 2019 Anton Kononenko. All rights reserved.
//

import Foundation

@objc public class SessionStorage: NSObject, ZappStorageProtocol {
    public static let sharedInstance = SessionStorage()
    
    /// Dictionary that used as Zapp Session Storage
    public private(set) var storage: [String: Any]
    
    public override init() {
        self.storage = StorageHelper.createEmptyZappStorage()
        super.init()
    }
    
    //MARK: ZappStorageProtocol
    
    @discardableResult public func set(key: String, value: String, namespace: String?) -> Bool {
        let setResult = StorageHelper.setZappData(inStorageDict: storage,
                                                  key: key,
                                                  value: value,
                                                  namespace: namespace)
        storage = setResult.storageDict
        return setResult.succeed
    }
    
    public func get(key: String, namespace: String?) -> String? {
        return StorageHelper.getZappData(inStorageDict: storage,
                                         key: key,
                                         namespace: namespace)
    }
    
    public func getAll(namespace:String?) -> String? {
        return StorageHelper.getAll(inStorageDict:
            storage, namespace: namespace)
    }
    
}
