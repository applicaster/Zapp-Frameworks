//
//  RootController+FacadeConnectorStorageProtocol.swift
//  ZappApple
//
//  Created by Anton Kononenko on 10/8/19.
//  Copyright © 2019 Applicaster LTD. All rights reserved.
//

import Foundation
import ZappCore

extension RootController: FacadeConnectorStorageProtocol {
    public func sessionStorageValue(for key: String, namespace: String?) -> String? {
        return SessionStorage.sharedInstance.get(key: key,
                                                 namespace: namespace)
    }

    public func sessionStorageSetValue(for key: String, value: String?, namespace: String?) -> Bool {
        return SessionStorage.sharedInstance.set(key: key,
                                                 value: value,
                                                 namespace: namespace)
    }

    public func sessionStorageRemoveValue(for key: String, namespace: String?) -> Bool {
        return SessionStorage.sharedInstance.removeItem(key: key,
                                                        namespace: namespace)
    }

    public func sessionStorageAllValues(namespace: String? = nil) -> String? {
        return SessionStorage.sharedInstance.getAll(namespace: namespace)
    }

    public func localStorageValue(for key: String, namespace: String?) -> String? {
        return LocalStorage.sharedInstance.get(key: key,
                                               namespace: namespace)
    }

    public func localStorageSetValue(for key: String, value: String?, namespace: String?) -> Bool {
        return LocalStorage.sharedInstance.set(key: key,
                                               value: value,
                                               namespace: namespace)
    }

    public func localStorageRemoveValue(for key: String, namespace: String?) -> Bool {
        return LocalStorage.sharedInstance.removeItem(key: key, namespace: namespace)
    }

    public func localStorageAllValues(namespace: String? = nil) -> String? {
        return LocalStorage.sharedInstance.getAll(namespace: namespace)
    }

    public func keychainStorageValue(for key: String, namespace: String?) -> String? {
        return LocalStorage.sharedInstance.getKeychain(key: key,
                                                       namespace: namespace)
    }

    public func keychainStorageSetValue(for key: String, value: String?, namespace: String?) -> Bool {
        return LocalStorage.sharedInstance.setKeychain(key: key,
                                                       value: value,
                                                       namespace: namespace)
    }

    public func keychainStorageRemoveValue(for key: String, namespace: String?) -> Bool {
        return LocalStorage.sharedInstance.removeKeychainItem(key: key,
                                                              namespace: namespace)
    }
}
