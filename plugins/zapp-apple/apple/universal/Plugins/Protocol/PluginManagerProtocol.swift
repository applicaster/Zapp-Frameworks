//
//  PluginManagerProtocol.swift
//  ZappApple
//
//  Created by Anton Kononenko on 1/24/20.
//

import Foundation
import ZappCore

public typealias PluginManagerCompletion = ((_ success: Bool) -> Void)?

protocol PluginManagerControlFlowProtocol {
    func disableProvider(identifier: String,
                         completion: PluginManagerCompletion)
    func disableProviders(completion: PluginManagerCompletion)
    func createProvider(identifier: String,
                        forceEnable: Bool,
                        completion: PluginManagerCompletion)
    func createProviders(forceEnable: Bool,
                         completion: PluginManagerCompletion)
    func getProviderInstance(identifier: String) -> PluginAdapterProtocol?
    func getProviderInstance(condition: (Any) -> Any?) -> PluginAdapterProtocol?
}

protocol PluginManagerProtocol: PluginManagerControlFlowProtocol {
    associatedtype pluginTypeProtocol
    var pluginType: ZPPluginType { get }
    var pluginProtocol: pluginTypeProtocol.Type { get }

    var providers: [String: pluginTypeProtocol] { get set }
    func prepareManager(completion: PluginManagerCompletion)
}
