//
//  GeneralPluginsManager.swift
//  ZappApple
//
//  Created by Alex Zchut on 05/02/2020.
//  Copyright © 2020 Applicaster. All rights reserved.
//

import UIKit
import ZappCore

public typealias GeneralManagerPreparationCompletion = () -> Void

public class GeneralPluginsManager: PluginManagerBase {
    typealias pluginTypeProtocol = GeneralProviderProtocol
    var _providers: [String: GeneralProviderProtocol] {
        return providers as? [String: GeneralProviderProtocol] ?? [:]
    }

    public required init() {
        super.init()
        pluginType = .General
    }
}
