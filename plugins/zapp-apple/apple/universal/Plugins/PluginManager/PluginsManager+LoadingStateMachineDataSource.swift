//
//  PluginManager+LoadingStateMachineDataSource.swift
//  ZappApple
//
//  Created by Anton Kononenko on 11/18/19.
//  Copyright © 2019 Applicaster LTD. All rights reserved.
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

        let player = LoadingState()
        player.stateHandler = preparePlayerPlugins
        player.dependantStates = [onLaunchHook.name]
        player.readableName = "<plugins-state-machine> Prepare Player Plugins"
        
        let pluginsSessionStorageData = LoadingState()
        pluginsSessionStorageData.stateHandler = updatePluginSessionStorageData
        pluginsSessionStorageData.readableName = "<plugins-state-machine> Plugins Session Storage"
        pluginsSessionStorageData.dependantStates = [onLaunchHook.name]

        return [loadPlugins,
                onLaunchHook,
                analytics,
                push,
                general,
                player,
                pluginsSessionStorageData]
    }

    public func stateMachineFinishedWork(with state: LoadingStateTypes) {
        pluginLoaderCompletion?(state == .success)
        pluginLoaderCompletion = nil
    }
}
