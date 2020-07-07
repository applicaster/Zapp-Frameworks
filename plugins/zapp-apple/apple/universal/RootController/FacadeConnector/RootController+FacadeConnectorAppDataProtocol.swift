//
//  RootController+ZAAppDelegateConnectorGenericProtocol.swift
//  ZappApple
//
//  Created by Anton Kononenko on 11/14/18.
//  Copyright © 2018 Anton Kononenko. All rights reserved.
//

import Foundation
import ZappCore

extension RootController: FacadeConnectorAppDataProtocol {
    public func bundleName() -> String {
        return UIApplication.bundleName()
    }

    public func appVersion() -> String {
        return UIApplication.appVersion()
    }

    public func pluginsURLPath() -> URL? {
        return LoadingManager().file(type: .plugins)?.localURLPath()
    }

    public func bundleIdentifier() -> String {
        return SessionStorage.sharedInstance.get(key: ZappStorageKeys.bundleIdentifier,
                                                 namespace: nil) ?? ""
    }
}
