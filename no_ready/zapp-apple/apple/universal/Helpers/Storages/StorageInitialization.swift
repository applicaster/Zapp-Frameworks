//
//  StorageInitialization.swift
//  ZappApple
//
//  Created by Anton Kononenko on 5/9/19.
//  Copyright © 2019 Anton Kononenko. All rights reserved.
//

import Foundation

public class StorageInitialization {
    public class func initializeDefaultValues(sessionStorage: [String: String] = [:],
                                              localStorage: [String: String] = [:]) {
        // Local storage default params
        setDefaultValues(for: LocalStorage.sharedInstance,
                         defaultValues: localStorage)

        // Session storage default params
        setDefaultValues(for: SessionStorage.sharedInstance,
                         defaultValues: sessionStorage)
    }

    public class func setDefaultValues(for storageManager: ZappStorageProtocol,
                                       defaultValues: [String: String] = [:]) {
        defaultValues.forEach { arg in

            let (key, value) = arg
            _ = storageManager.set(key: key,
                                   value: value,
                                   namespace: nil)
        }
    }
}
