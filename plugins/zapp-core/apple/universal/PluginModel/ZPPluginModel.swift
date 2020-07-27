//
//  ZPPluginModel.swift
//  Zapp-App
//
//  Created by Anton Kononenko on 03/05/16.
//  Copyright © 2016 Applicaster LTD. All rights reserved.
//

import Foundation

/// General keys of the Zapp Plugin Model
public struct ZappPluginModelKeys {
    static let kPlugin = "plugin"
    static let kIdentifier = "identifier"
    static let kPluginTypeString = "type"
    static let kPluginNameString = "name"
    static let kApiString = "api"
    static let kPluginClassNameString = "class_name"
    static let kPluginModulesString = "modules"
    static let kPluginRequireStartupExecution = "require_startup_execution"
    static let kConfigurationJSON = "configuration_json"
    static let kReactNativePlugin = "react_native"
}

/// Availible types of ZappPlugins
public enum ZPPluginType: String {
    case Root = "menu"
    case VideoPlayer = "player"
    case Analytics = "analytics"
    case BroadcasterPicker = "broadcaster_selector"
    case Push = "push_provider"
    case General = "general"
    case Login = "login"
    case AuthProvider = "auth_provider"
    case NavigationBar = "nav_bar"
    case CellStyleFamily = "cell_style_family"
    case VideoAdvertisement = "video_advertisement"
    case Crashlogs = "error_monitoring"

    /// Provides a new screen (view controller) for displaying articles
    case Article = "article"
    case Advertisement = "advertisement"

    case Unknown = "unknown"
}

@objc open class ZPPluginModel: NSObject {
    public private(set) var object: NSDictionary

    public var api: [String: Any]? {
        return plugin?[ZappPluginModelKeys.kApiString] as? [String: Any]
    }

    public var plugin: [String: Any]? {
        return object[ZappPluginModelKeys.kPlugin] as? [String: Any]
    }

    @objc public var identifier: String {
        return plugin?[ZappPluginModelKeys.kIdentifier] as? String ?? ""
    }

    public var pluginRequireStartupExecution: Bool {
        return api?[ZappPluginModelKeys.kPluginRequireStartupExecution] as? Bool ?? false
    }

    public var isReactNativePlugin: Bool {
        return plugin?[ZappPluginModelKeys.kReactNativePlugin] as? Bool ?? false
    }

    public var pluginName: String {
        return plugin?[ZappPluginModelKeys.kPluginNameString] as? String ?? ""
    }

    public lazy var pluginType: ZPPluginType? = {
        guard let stringPluginType = plugin?[ZappPluginModelKeys.kPluginTypeString] as? String else {
            return nil
        }
        return ZPPluginType(rawValue: stringPluginType)
    }()

    public var pluginClassName: String? {
        return api?[ZappPluginModelKeys.kPluginClassNameString] as? String
    }

    public var pluginModules: [String]? {
        return api?[ZappPluginModelKeys.kPluginModulesString] as? [String]
    }

    public var configurationJSON: NSDictionary?

    @objc public init?(object: NSDictionary?) {
        guard let objectDictionary = object,
            objectDictionary[ZappPluginModelKeys.kPlugin] as? NSDictionary != nil else {
            return nil
        }
        self.object = objectDictionary
        configurationJSON = objectDictionary[ZappPluginModelKeys.kConfigurationJSON] as? NSDictionary
    }

    static public func == (lhs: ZPPluginModel, rhs: ZPPluginModel) -> Bool {
        return lhs.identifier == rhs.identifier
    }

    public func configurationValue(for key: String) -> AnyObject? {
        var retValue: AnyObject?
        if let pluginConfiguration = self.object[ZappPluginModelKeys.kConfigurationJSON] as? [String: AnyObject],
            let value = pluginConfiguration[key] {
            retValue = value
        }
        return retValue
    }
}
