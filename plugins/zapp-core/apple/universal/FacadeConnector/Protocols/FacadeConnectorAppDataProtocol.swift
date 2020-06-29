//
//  FacadeConnectorAppDataProtocol.swift
//  ZappPlugins
//
//  Created by Anton Kononenko on 9/23/19.
//  Copyright © 2019 Applicaster LTD. All rights reserved.
//

import Foundation

@objc public protocol FacadeConnectorAppDataProtocol {
    /// Retrun plugin json url Path
    @objc func pluginsURLPath() -> URL?

    /// Retrieve application app identifier
    @objc func bundleIdentifier() -> String
    @objc func bundleName() -> String
    @objc func appVersion() -> String
}
