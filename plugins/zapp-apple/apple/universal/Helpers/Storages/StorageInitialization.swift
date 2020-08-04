//
//  StorageInitialization.swift
//  ZappApple
//
//  Created by Anton Kononenko on 5/9/19.
//  Copyright © 2019 Anton Kononenko. All rights reserved.
//

import Foundation
import XrayLogger

public class StorageInitialization {
    public class func initializeDefaultValues(sessionStorage: [String: String] = [:],
                                              localStorage: [String: String] = [:]) {
        let loggerSessionStorage = Logger.getLogger(for: SessionStorageLogs.subsystem)
        let loggerLocalStorage = Logger.getLogger(for: LocalStorageLogs.subsystem)

        // Local storage default params
        setDefaultValues(for: LocalStorage.sharedInstance,
                         defaultValues: localStorage)

        // Session storage default params
        setDefaultValues(for: SessionStorage.sharedInstance,
                         defaultValues: sessionStorage)

        loggerSessionStorage?.verboseLog(template: SessionStorageLogs.storageInitialized,
                                         data: sessionStorage)
        loggerLocalStorage?.verboseLog(template: LocalStorageLogs.storageInitialized,
                                       data: localStorage)
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
