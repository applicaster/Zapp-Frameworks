//
//  RootController+FacadeConnectorStorageProtocol.swift
//  ZappApple
//
//  Created by Anton Kononenko on 10/8/19.
//  Copyright © 2019 Anton Kononenko. All rights reserved.
//

import Foundation
import ZappCore

extension RootController: FacadeConnectorStorageProtocol {
    public func sessionStorageValue(for key: String, namespace: String?) -> String? {
        return SessionStorage.sharedInstance.get(key: key,
                                                 namespace: namespace)
    }

    public func sessionStorageSetValue(for key: String, value: String, namespace: String?) -> Bool {
        return SessionStorage.sharedInstance.set(key: key,
                                                 value: value,
                                                 namespace: namespace)
    }

    public func sessionStorageAllValues(namespace: String? = nil) -> String? {
        return SessionStorage.sharedInstance.getAll(namespace: namespace)
    }

    public func localStorageValue(for key: String, namespace: String?) -> String? {
        return LocalStorage.sharedInstance.get(key: key,
                                               namespace: namespace)
    }

    public func localStorageSetValue(for key: String, value: String, namespace: String?) -> Bool {
        return LocalStorage.sharedInstance.set(key: key,
                                               value: value,
                                               namespace: namespace)
    }

    @objc public func localStorageAllValues(namespace: String? = nil) -> String? {
        return LocalStorage.sharedInstance.getAll(namespace: namespace)
    }
}
