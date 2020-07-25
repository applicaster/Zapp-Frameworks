//
//  LoggerSinksManager.swift
//  ZappApple
//
//  Created by Alex Zchut on 23/07/2020.
//

import ZappCore
import XrayLogger

public class LoggerSinksManager: PluginManagerBase {
    typealias pluginTypeProtocol = LoggerSinkPluginProtocol
    var _providers: [String: LoggerSinkPluginProtocol] {
        return providers as? [String: LoggerSinkPluginProtocol] ?? [:]
    }

    required init() {
        super.init()
        pluginType = .General
        
        XrayLogger.sharedInstance.addSink(identifier: "console",
        sink: Console(logType: .print))
    }
}
