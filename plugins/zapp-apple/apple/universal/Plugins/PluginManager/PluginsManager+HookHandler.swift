//
//  PluginManager+LoadingStateMachineDataSource.swift
//  ZappApple
//
//  Created by Anton Kononenko on 11/18/19.
//  Copyright © 2019 Anton Kononenko. All rights reserved.
//

import Foundation
import ZappCore

extension PluginsManager {
    func createLaunchHooksPlugins(completion: @escaping (() -> Void)) {
        let plugins = PluginsManager.getHookPlugins()
        var counter = plugins.count
        guard counter > 0 else {
            completion()
            return
        }
        for plugin in plugins {
            guard let pluginManager = pluginManager(identifier: plugin.identifier) else {
                counter -= 1
                return
            }

            pluginManager.createProvider(identifier: plugin.identifier,
                                         forceEnable: false,
                                         completion: { _ in
                                             counter -= 1
                                             if counter == 0 {
                                                 completion()
                                             }

            })
        }
    }

    func retrieveHooksPlugins() -> [AppLoadingHookProtocol] {
        var retVal = analytics.hooksProviders()
        retVal += push.hooksProviders()
        retVal += general.hooksProviders()
        retVal += crashlogs.hooksProviders()

        return retVal
    }
}

// MARK: ExecuteOnLaunch

extension PluginsManager {
    func hookOnLaunch(hooksPlugins: [AppLoadingHookProtocol]?,
                      completion: @escaping (() -> Void)) {
        var plugins = hooksPlugins ?? retrieveHooksPlugins()
        guard plugins.count > 0 else {
            completion()
            return
        }
        let adapter = plugins.removeFirst()
        hookAdapterOnLaunch(adapter: adapter) { [weak self] in
            self?.hookOnLaunch(hooksPlugins: plugins,
                               completion: completion)
        }
    }

    func hookAdapterOnLaunch(adapter: AppLoadingHookProtocol,
                             completion: @escaping (() -> Void)) {
        guard let executeOnLaunch = adapter.executeOnLaunch else {
            completion()
            return
        }
        executeOnLaunch(completion)
    }
}

// MARK: ExecuteOnFailedLoading

extension PluginsManager {
    func hookFailedLoading(hooksPlugins: [AppLoadingHookProtocol]?,
                           completion: @escaping (() -> Void)) {
        var plugins = hooksPlugins ?? retrieveHooksPlugins()
        guard plugins.count > 0 else {
            completion()
            return
        }
        let adapter = plugins.removeFirst()
        hookAdapterOnFailedLoading(adapter: adapter) { [weak self] in
            self?.hookFailedLoading(hooksPlugins: plugins,
                                    completion: completion)
        }
    }

    func hookAdapterOnFailedLoading(adapter: AppLoadingHookProtocol,
                                    completion: @escaping (() -> Void)) {
        guard let executeOnFailedLoading = adapter.executeOnFailedLoading else {
            completion()
            return
        }
        executeOnFailedLoading(completion)
    }
}

// MARK: ExecuteOnApplicationReady

extension PluginsManager {
    func hookOnApplicationReady(displayViewController: UIViewController?,
                                hooksPlugins: [AppLoadingHookProtocol]?,
                                completion: @escaping (() -> Void)) {
        var plugins = hooksPlugins ?? retrieveHooksPlugins()
        guard plugins.count > 0 else {
            completion()
            return
        }
        let adapter = plugins.removeFirst()
        hookAdapterOnApplicationReady(displayViewController: displayViewController,
                                      adapter: adapter) { [weak self] in
            self?.hookOnApplicationReady(displayViewController: displayViewController,
                                         hooksPlugins: plugins,
                                         completion: completion)
        }
    }

    func hookAdapterOnApplicationReady(displayViewController: UIViewController?,
                                       adapter: AppLoadingHookProtocol,
                                       completion: @escaping (() -> Void)) {
        guard let executeOnApplicationReady = adapter.executeOnApplicationReady else {
            completion()
            return
        }
        executeOnApplicationReady(displayViewController,
                                  completion)
    }
}

// MARK: ExecuteAfterAppRootPresentation

extension PluginsManager {
    func hookAfterAppRootPresentation(hooksPlugins: [AppLoadingHookProtocol]?,
                                      completion: @escaping (() -> Void)) {
        var plugins = hooksPlugins ?? retrieveHooksPlugins()
        guard plugins.count > 0 else {
            completion()
            return
        }
        let adapter = plugins.removeFirst()
        hookAdapterAfterAppRootPresentation(adapter: adapter) { [weak self] in
            self?.hookAfterAppRootPresentation(hooksPlugins: plugins,
                                               completion: completion)
        }
    }

    func hookAdapterAfterAppRootPresentation(adapter: AppLoadingHookProtocol,
                                             completion: @escaping (() -> Void)) {
        guard let executeAfterAppRootPresentation = adapter.executeAfterAppRootPresentation else {
            completion()
            return
        }
        executeAfterAppRootPresentation(nil,
                                        completion)
    }
}

// MARK: ExecuteOnContinuingUserActivity

// TODO: This hook does not implemented on call
extension PluginsManager {
    public func hookOnContinuingUserActivity(userActivity: NSUserActivity,
                                             hooksPlugins: [AppLoadingHookProtocol]?,
                                             completion: @escaping (() -> Void)) {
        var plugins = hooksPlugins ?? retrieveHooksPlugins()
        guard plugins.count > 0 else {
            completion()
            return
        }
        let adapter = plugins.removeFirst()
        hookAdapterOnContinuingUserActivity(userActivity: userActivity,
                                            adapter: adapter) { [weak self] in
            self?.hookOnContinuingUserActivity(userActivity: userActivity,
                                               hooksPlugins: plugins,
                                               completion: completion)
        }
    }

    func hookAdapterOnContinuingUserActivity(userActivity: NSUserActivity,
                                             adapter: AppLoadingHookProtocol,
                                             completion: @escaping (() -> Void)) {
        guard let executeOnContinuingUserActivity = adapter.executeOnContinuingUserActivity else {
            completion()
            return
        }
        executeOnContinuingUserActivity(userActivity,
                                        completion)
    }

    public func hasHooksForContinuingUserActivity() -> Bool {
        let plugins = retrieveHooksPlugins().filter { (adapter) -> Bool in
            guard let _ = adapter.executeOnContinuingUserActivity else {
                return false
            }
            return true
        }
        return plugins.count > 0
    }
}
