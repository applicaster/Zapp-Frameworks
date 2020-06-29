//
//  PluginAdapterProtocol.swift
//  ZappCore
//
//  Created by Anton Kononenko on 1/24/20.
//

import Foundation

/// Base Zapp Plugin protocol
@objc public protocol PluginAdapterProtocol: NSObjectProtocol {
    /// Initialize with plugin model
    /// - Parameter pluginModel: Dictionary with configuration params that passed  from ZPPluginModel
    init(pluginModel: ZPPluginModel)

    /// Zapp Plugin Model
    var model: ZPPluginModel? { get }

    /// Readable name of the plugin
    var providerName: String { get }

    /// Invocation of this function must prepare push notification plugin for use.
    /// - Attention: Application will wait completion of this func to present application.
    /// Completion must be called as soon as  possible
    /// - Parameters:
    ///   - defaultParams: default parameters of the plugin
    ///   - completion: Completion handler that notify app level that component  ready to  be presented or fail
    ///     - isReady: notify callback if analytics plugin is ready for use
    func prepareProvider(_ defaultParams: [String: Any],
                         completion: ((_ isReady: Bool) -> Void)?)

    /// Notify plugin that plugin must be disabled
    /// - Note: On this stop plugin must stop any activity, remove observers, stop load data and etc
    /// - Parameter completion: Notify application that plugin has been disable
    func disable(completion: ((_ success:Bool) -> Void)?)
}

