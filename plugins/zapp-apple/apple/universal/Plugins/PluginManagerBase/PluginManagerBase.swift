//
//  PluginManagerBase.swift
//  ZappApple
//
//  Created by Anton Kononenko on 1/24/20.
//

import Foundation
import XrayLogger
import ZappCore

public class PluginManagerBase: PluginManagerProtocol, PluginManagerControlFlowProtocol {
    open var pluginType: ZPPluginType
    open var logger: Logger?
    required init() {
        pluginType = .Unknown
    }

    open var pluginProtocol: PluginAdapterProtocol.Protocol {
        return pluginTypeProtocol.self
    }

    public typealias pluginTypeProtocol = PluginAdapterProtocol

    open var providers: [String: pluginTypeProtocol] = [:]

    public func prepareManager(completion: PluginManagerCompletion) {
        createProviders(completion: completion)
    }

    public func providerCreated(provider: PluginAdapterProtocol,
                                completion: PluginManagerCompletion) {
        provider.prepareProvider([:]) { succeed in
            completion?(succeed)
        }
        // Must be implemented on subclass if needed
    }

    public func createProviders(forceEnable: Bool = false,
                                completion: PluginManagerCompletion) {
        let pluginModels = PluginsManager.pluginModels()?.filter {
            $0.pluginType == pluginType
        }

        if let pluginModels = pluginModels {
            var counter = pluginModels.count

            guard counter > 0 else {
                completion?(true)
                return
            }

            for pluginModel in pluginModels {
                createProvider(pluginModel: pluginModel,
                               forceEnable: forceEnable) { _ in
                    counter -= 1

                    if counter == 0 {
                        completion?(true)
                    }
                }
            }
        } else {
            completion?(false)
        }
    }

    public func createProvider(identifier: String,
                               forceEnable: Bool = false,
                               completion: PluginManagerCompletion) {
        guard let pluginModel = PluginsManager.pluginModelById(identifier) else {
            completion?(false)
            return
        }
        createProvider(pluginModel: pluginModel,
                       forceEnable: forceEnable,
                       completion: completion)
    }

    public func createProvider(pluginModel: ZPPluginModel,
                               forceEnable: Bool = false,
                               completion: PluginManagerCompletion) {
        var createProviderCompletion = completion

        // In case plugin not support override logic, return false, since "forceEnable" true only when we trying to override
        if forceEnable == true,
           isProviderSupportToggleOnOff(pluginModel: pluginModel) == false {
            completion?(false)
            return
        }

        if let adapterClass = PluginsManager.adapterClass(pluginModel),
           adapterClass.conforms(to: pluginProtocol),
           let classType = adapterClass as? PluginAdapterProtocol.Type,
           isEnabled(pluginModel: pluginModel,
                     forceEnable: forceEnable) {
            let provider = classType.init(pluginModel: pluginModel)

            providers[pluginModel.identifier] = provider

            if forceEnable {
                _ = FacadeConnector.connector?.storage?.localStorageSetValue(for: pluginModel.identifier,
                                                                             value: kPluginEnabledValue,
                                                                             namespace: kPluginEnabledNamespace)
            }

            let timer = TimeoutTimer {
                self.logger?.errorLog(message: "\(type(of: provider)) execution timeout",
                                      data: provider.model?.object as? [String: Any])
                createProviderCompletion = nil
                completion?(false)
            }
            providerCreated(provider: provider) { success in
                timer.cancel()
                createProviderCompletion?(success)
            }
        } else {
            completion?(true)
        }
    }

    public func disableProvider(identifier: String,
                                completion: PluginManagerCompletion) {
        guard let provider = providers[identifier],
              let pluginModel = provider.model else {
            completion?(false)
            return
        }

        guard isProviderSupportToggleOnOff(pluginModel: pluginModel) == true else {
            completion?(false)
            return
        }

        provider.disable(completion: completion)
        _ = FacadeConnector.connector?.storage?.localStorageSetValue(for: pluginModel.identifier,
                                                                     value: kPluginDisabledValue,
                                                                     namespace: kPluginEnabledNamespace)
    }

    public func disableProviders(completion: PluginManagerCompletion) {
        guard providers.count > 0 else {
            completion?(true)
            return
        }

        var counter = providers.count
        providers.forEach { element in
            if let identifier = element.value.model?.identifier {
                disableProvider(identifier: identifier) { _ in
                    counter -= 1
                    if counter == 0 {
                        completion?(true)
                    }
                }
            } else {
                counter -= 1
                if counter == 0 {
                    completion?(true)
                }
            }
        }
    }

    func getProviderInstance(identifier: String) -> PluginAdapterProtocol? {
        guard let provider = providers[identifier] else {
            return nil
        }
        return provider
    }

    func getProviderInstance(condition: (Any) -> Any?) -> PluginAdapterProtocol? {
        guard let provider = providers.first(where: { (_, value) -> Bool in
            condition(value) != nil
        }) else {
            return nil
        }
        return provider.value
    }

    public func isEnabled(pluginModel: ZPPluginModel,
                          forceEnable: Bool) -> Bool {
        var retVal = true

        // Forcing enabled cause when plugin enabled from Control Flow
        // Control Flow API reenable plugin
        guard forceEnable == false else {
            return retVal
        }

        // In case plugin not forcing enable, but plugin was already created
        // Probably plugin was created for Launch hook
        guard providers[pluginModel.identifier] == nil else {
            return false
        }

        retVal = isProviderEnabled(pluginModel: pluginModel)

        return retVal
    }

    func hooksProviders() -> [AppLoadingHookProtocol] {
        var retVal: [AppLoadingHookProtocol] = []
        providers.forEach { _, provider in
            if let model = provider.model,
               model.pluginRequireStartupExecution == true,
               let hookProvider = provider as? AppLoadingHookProtocol {
                retVal.append(hookProvider)
            }
        }

        return retVal
    }

    func isProviderEnabled(provider: PluginAdapterProtocol) -> Bool {
        guard let model = provider.model else {
            return true
        }
        return isProviderEnabled(pluginModel: model)
    }

    func isProviderEnabled(pluginModel: ZPPluginModel) -> Bool {
        var retVal = true

        // Check if configruration JSON exist
        // If no we want initialize screen in any casee
        guard let configurationJSON = pluginModel.configurationJSON,
              let pluginEnabled = configurationJSON[kPluginEnabled] else {
            return retVal
        }

        /// Check if plugin was already info in local storage
        if let pluginEnabled = LocalStorage.sharedInstance.get(key: pluginModel.identifier,
                                                               namespace: kPluginEnabledNamespace),
            let enabledBool = Bool(pluginEnabled) {
            return enabledBool
        }

        // Check if value bool or string
        if let pluginEnabled = pluginEnabled as? String {
            if let pluginEnabledBool = Bool(pluginEnabled) {
                retVal = pluginEnabledBool
            } else if let pluginEnabledInt = Int(pluginEnabled) {
                retVal = Bool(truncating: pluginEnabledInt as NSNumber)
            }
        } else if let pluginEnabled = pluginEnabled as? Bool {
            retVal = pluginEnabled
        }
        return retVal
    }

    /// Checks if plugin provider can handle enable/disable logic
    ///  Plugin to able to enable/disable logic must has a key in cofiguration json "enabled"
    /// - Parameter pluginModel: Plugin model instance
    /// - Returns: true in case can be enabled or disabled on fly, otherwise false
    func isProviderSupportToggleOnOff(pluginModel: ZPPluginModel) -> Bool {
        guard let configurationJSON = pluginModel.configurationJSON,
              configurationJSON[kPluginEnabled] != nil else {
            return false
        }
        return true
    }
}
