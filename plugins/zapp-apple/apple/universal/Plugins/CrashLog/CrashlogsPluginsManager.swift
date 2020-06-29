//
//  CrashlogsPluginsManager.swift
//  CrashlogsPluginsManager
//
//  Created by Anton Kononenko on 12/25/18.
//  Copyright © 2019 Applicaster. All rights reserved.
//

import ZappCore

public class CrashlogsPluginsManager: PluginManagerBase {
    typealias pluginTypeProtocol = CrashlogsPluginProtocol
    var _providers: [String: CrashlogsPluginProtocol] {
        return providers as? [String: CrashlogsPluginProtocol] ?? [:]
    }

    required init() {
        super.init()
        pluginType = .Crashlogs
    }
}

