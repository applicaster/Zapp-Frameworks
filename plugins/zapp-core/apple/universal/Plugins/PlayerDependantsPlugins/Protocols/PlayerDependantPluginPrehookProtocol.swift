//
//  PlayerDependantPluginProtocol.swift
//  ZappPlugins
//
//  Created by Anton Kononenko on 7/17/19.
//  Copyright © 2019 Anton Kononenko. All rights reserved.
//

import Foundation

/// This protocol must be implemented by all plugins that want to be plater dependent and act as prehook for player presentation
@objc public protocol PlayerDependantPluginPrehookProtocol: PlayerDependantPluginProtocol {
    /// Perform operation will execute prior to player resentation and player will continue on successful completion
    func performPrehook(_ completion: @escaping (_ success: Bool) -> Void)
}
