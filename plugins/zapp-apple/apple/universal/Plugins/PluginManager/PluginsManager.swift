//
//  PluginsLoader.swift
//  ZappApple
//
//  Created by Anton Kononenko on 11/26/18.
//  Copyright © 2018 Anton Kononenko. All rights reserved.
//

import Foundation
import ZappCore

public class PluginsManager: NSObject {
    public lazy var analytics = AnalyticsManager()
    public lazy var playerDependants = PlayerDependantPluginsManager()
    public lazy var push = PushPluginsManager()
    public lazy var general = GeneralPluginsManager()
    public lazy var crashlogs = CrashlogsPluginsManager()

    public lazy var localNotificationManager: FacadeConnectorLocalNotificationProtocol? = {
        let retVal = general.providers.first(where: { ($0.value as? FacadeConnectorLocalNotificationProtocol) != nil })
        return retVal?.value as? FacadeConnectorLocalNotificationProtocol
    }()

    var pluginsStateMachine: LoadingStateMachine!
    var pluginLoaderCompletion: ((_ success: Bool) -> Void)?

    func intializePlugins(completion: @escaping (_ success: Bool) -> Void) {
        pluginLoaderCompletion = completion
        pluginsStateMachine = LoadingStateMachine(dataSource: self,
                                                  withStates: preapareLoadingPluginStates())
        pluginsStateMachine.startStatesInvocation()
    }

    func loadPluginsGroup(_ successHandler: @escaping StateCallBack,
                          _ failHandler: @escaping StateCallBack) {
        let loadingManager = LoadingManager()
        loadingManager.loadFile(type: .plugins) { success in
            success ? successHandler() : failHandler()
        }
    }

    func crashLogs(_ successHandler: @escaping StateCallBack,
                   _ failHandler: @escaping StateCallBack) {
        crashlogs.prepareManager { success in
            success ? successHandler() : failHandler()
        }
    }

    func prepareAnalyticsPlugins(_ successHandler: @escaping StateCallBack,
                                 _ failHandler: @escaping StateCallBack) {
        analytics.prepareManager { success in
            success ? successHandler() : failHandler()
        }
    }

    func preparePushPlugins(_ successHandler: @escaping StateCallBack,
                            _ failHandler: @escaping StateCallBack) {
        push.prepareManager { success in
            success ? successHandler() : failHandler()
        }
    }

    func prepareGeneralPlugins(_ successHandler: @escaping StateCallBack,
                               _ failHandler: @escaping StateCallBack) {
        general.prepareManager { success in
            success ? successHandler() : failHandler()
        }
    }

    func updatePluginSessionStorageData(_ successHandler: @escaping StateCallBack,
                                        _ failHandler: @escaping StateCallBack) {
        func sendConfigurationToSessionStorage(pluginModel: ZPPluginModel) {
            guard let configationJSON = pluginModel.configurationJSON as? [String: String] else {
                return
            }

            configationJSON.forEach { arg in
                let (key, value) = arg
                _ = FacadeConnector.connector?.storage?.sessionStorageSetValue(for: key,
                                                                               value: value,
                                                                               namespace: pluginModel.identifier)
            }
        }

        guard let allPluginModels = PluginsManager.allPluginModels else {
            successHandler()
            return
        }

        allPluginModels.forEach { model in
            sendConfigurationToSessionStorage(pluginModel: model)
        }
        successHandler()
    }

    func hookOnLaunch(_ successHandler: @escaping StateCallBack,
                      _ failHandler: @escaping StateCallBack) {
        createLaunchHooksPlugins { [weak self] in
            self?.hookOnLaunch(hooksPlugins: nil) {
                successHandler()
            }
        }
    }
}
