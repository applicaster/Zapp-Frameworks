//
//  PlayerDependantPluginProtocol.swift
//  ZappPlugins
//
//  Created by Anton Kononenko on 7/17/19.
//  Copyright © 2019 Anton Kononenko. All rights reserved.
//

import Foundation

/// This protocol must be implemented by all plugins that want to be plater dependent and needs player data
@objc public protocol PlayerDependantPluginProtocol: PluginAdapterProtocol {
    /// Player plugin that dependant plugins will be used with
    var playerPlugin: PlayerProtocol? { set get }
}
