//
//  PluginManager+LoadingStateMachineDataSource.swift
//  ZappApple
//
//  Created by Anton Kononenko on 11/18/19.
//  Copyright © 2019 Anton Kononenko. All rights reserved.
//

import Foundation

extension PluginsManager: LoadingStateMachineDataSource {
    func preapareLoadingPluginStates() -> [LoadingState] {
        let loadPlugins = LoadingState()
        loadPlugins.stateHandler = loadPluginsGroup
        loadPlugins.readableName = "<plugins-state-machine> Load General Plugins JSON"

        let onLaunchHook = LoadingState()
        onLaunchHook.stateHandler = hookOnLaunch
        onLaunchHook.readableName = "<plugins-state-machine> Execute Hook Plugin On Launch"
        onLaunchHook.dependantStates = [loadPlugins.name]

        let crashlogs = LoadingState()
        crashlogs.stateHandler = crashLogs
        crashlogs.dependantStates = [onLaunchHook.name]
        crashlogs.readableName = "<plugins-state-machine> CrashLogs Crashlogs Plugins"

        let analytics = LoadingState()
        analytics.stateHandler = prepareAnalyticsPlugins
        analytics.dependantStates = [onLaunchHook.name]
        analytics.readableName = "<plugins-state-machine> Prepare Analytics Plugins"

        let push = LoadingState()
        push.stateHandler = preparePushPlugins
        push.dependantStates = [onLaunchHook.name]
        push.readableName = "<plugins-state-machine> Prepare Push Plugins"

        let general = LoadingState()
        general.stateHandler = prepareGeneralPlugins
        general.dependantStates = [onLaunchHook.name]
        general.readableName = "<plugins-state-machine> Prepare General Plugins"

        let pluginsSessionStorageData = LoadingState()
        pluginsSessionStorageData.stateHandler = updatePluginSessionStorageData
        pluginsSessionStorageData.readableName = "<plugins-state-machine> Plugins Session Storage"
        pluginsSessionStorageData.dependantStates = [onLaunchHook.name]

        return [loadPlugins,
                onLaunchHook,
                crashlogs,
                analytics,
                push,
                general,
                pluginsSessionStorageData]
    }

    public func stateMachineFinishedWork(with state: LoadingStateTypes) {
        pluginLoaderCompletion?(state == .success)
        pluginLoaderCompletion = nil
    }
}
