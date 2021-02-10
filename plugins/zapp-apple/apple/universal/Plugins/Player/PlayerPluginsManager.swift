//
//  GeneralPluginsManager.swift
//  ZappApple
//
//  Created by Anton Kononenko on 10/02/2020.
//  Copyright © 2021 Applicaster. All rights reserved.
//

import UIKit
import XrayLogger
import ZappCore

public typealias PlayerManagerPreparationCompletion = () -> Void

public class PlayerPluginsManager: PluginManagerBase {
    typealias pluginTypeProtocol = PluginAdapterProtocol
    var _providers: [String: PluginAdapterProtocol] {
        return providers
    }

    public required init() {
        super.init()
        pluginType = .VideoPlayer
        logger = Logger.getLogger(for: PlayerPluginManagerLogs.subsystem)
    }
}
