//
//  PluginsLoader.swift
//  ZappApple
//
//  Created by Anton Kononenko on 11/26/18.
//  Copyright © 2018 Anton Kononenko. All rights reserved.
//

import Foundation
import ZappCore
import XrayLogger

public class PluginsManager: NSObject {
    lazy var logger = Logger.getLogger(for: PluginsManagerLogs.subsystem)
    lazy var loggerControlFlow = Logger.getLogger(for: PluginsManagerControlFlowLogs.subsystem)
    lazy var loggerHookHandler = Logger.getLogger(for: PluginsManagerHookHandlerLogs.subsystem)

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
        logger?.debugLog(template: PluginsManagerLogs.pluginsInitialization)
        
        pluginLoaderCompletion = completion
        pluginsStateMachine = LoadingStateMachine(dataSource: self,
                                                  withStates: preapareLoadingPluginStates())
        pluginsStateMachine.startStatesInvocation()
    }

    func loadPluginsGroup(_ successHandler: @escaping StateCallBack,
                          _ failHandler: @escaping StateCallBack) {
        logger?.debugLog(template: PluginsManagerLogs.loadingPluginsConfiguration)

        let loadingManager = LoadingManager()
        loadingManager.loadFile(type: .plugins) { success in
            success ? successHandler() : failHandler()
        }
    }

    // If will not be used remove in future
    func crashLogs(_ successHandler: @escaping StateCallBack,
                   _ failHandler: @escaping StateCallBack) {
        logger?.debugLog(template: PluginsManagerLogs.preparingCrashlogPlugins)

//        crashlogs.prepareManager { success in
//            success ? successHandler() : failHandler()
//        }
    }

    func prepareAnalyticsPlugins(_ successHandler: @escaping StateCallBack,
                                 _ failHandler: @escaping StateCallBack) {
        logger?.debugLog(template: PluginsManagerLogs.preparingAnalyticsPlugins)
        
        analytics.prepareManager { success in
            success ? successHandler() : failHandler()
        }
    }

    func preparePushPlugins(_ successHandler: @escaping StateCallBack,
                            _ failHandler: @escaping StateCallBack) {
        logger?.debugLog(template: PluginsManagerLogs.preparingPushPlugins)

        push.prepareManager { success in
            success ? successHandler() : failHandler()
        }
    }

    func prepareGeneralPlugins(_ successHandler: @escaping StateCallBack,
                               _ failHandler: @escaping StateCallBack) {
        logger?.debugLog(template: PluginsManagerLogs.preparingGeneralPlugins)
        
        general.prepareManager { success in
            success ? successHandler() : failHandler()
        }
    }

    func updatePluginSessionStorageData(_ successHandler: @escaping StateCallBack,
                                        _ failHandler: @escaping StateCallBack) {
        logger?.debugLog(template: PluginsManagerLogs.savingPluginConfigurationToSessionStorage)

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
        logger?.debugLog(template: PluginsManagerLogs.preparingHookPlugins)

        createLaunchHooksPlugins { [weak self] in
            self?.hookOnLaunch(hooksPlugins: nil) {
                successHandler()
            }
        }
    }
}
