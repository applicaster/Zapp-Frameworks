//
//  FacadeConnectorStorageProtocol.swift
//  ZappPlugins
//
//  Created by Anton Kononenko on 10/8/19.
//  Copyright © 2019 Applicaster LTD. All rights reserved.
//

import Foundation

@objc public protocol FacadeConnectorStorageProtocol {
    @objc func sessionStorageValue(for key: String, namespace: String?) -> String?
    @objc func sessionStorageSetValue(for key: String, value: String, namespace: String?) -> Bool
    @objc func sessionStorageAllValues(namespace: String?) -> String?

    @objc func localStorageValue(for key: String, namespace: String?) -> String?
    @objc func localStorageSetValue(for key: String, value: String, namespace: String?) -> Bool
    @objc func localStorageAllValues(namespace: String?) -> String?
}
