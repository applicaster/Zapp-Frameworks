//
//  RootController+ZAAppDelegateConnectorGenericProtocol.swift
//  ZappApple
//
//  Created by Anton Kononenko on 11/14/18.
//  Copyright © 2018 Applicaster LTD. All rights reserved.
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
    
    public func appBuild() -> String {
        return UIApplication.appBuild()
    }

    public func pluginsURLPath() -> URL? {
        return LoadingManager().file(type: .plugins)?.localURLPath()
    }

    public func bundleIdentifier() -> String {
        return SessionStorage.sharedInstance.get(key: ZappStorageKeys.bundleIdentifier,
                                                 namespace: nil) ?? ""
    }

    public func isDebugEnvironment() -> Bool {
        return FeaturesCustomization.isDebugEnvironment()
    }
    
    public func launchOptions() -> [UIApplication.LaunchOptionsKey: Any]? {
        return self.appDelegate?.launchOptions
    }
}
