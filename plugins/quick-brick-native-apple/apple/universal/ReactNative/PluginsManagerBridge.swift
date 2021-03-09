//
//  PluginsManager.swift
//  QuickBrickApple
//
//  Created by Anton Kononenko on 1/27/20.
//

import Foundation
import React
import ZappCore

@objc(PluginsManagerBridge)
class PluginsManagerBridge: NSObject, RCTBridgeModule {
    let noIdentifierErrorCode = "error_identifier_empty"
    let noIdentifierErrorBody = "Plugin identifier is nil"

    let noTypeErrorCode = "error_type_empty"
    let noTypeErrorBody = "Plugin types is nil"

    static func moduleName() -> String! {
        return "PluginsManager"
    }

    public class func requiresMainQueueSetup() -> Bool {
        return true
    }

    /// prefered thread on which to run this native module
    @objc public var methodQueue: DispatchQueue {
        return DispatchQueue.main
    }

    @objc public func disablePlugin(_ identifier: String?,
                                    resolver: @escaping RCTPromiseResolveBlock,
                                    rejecter: @escaping RCTPromiseRejectBlock) {
        guard let identifier = identifier else {
            rejecter(noIdentifierErrorCode,
                     noIdentifierErrorBody,
                     nil)
            return
        }
        FacadeConnector.connector?.pluginManager?.disablePlugin(identifier: identifier, completion: { success in
            if success {
                resolver(true)
            } else {
                rejecter("disable_plugins",
                         "Failed to enable plugin with id:\(identifier)",
                         nil)
            }
        })
    }

    @objc public func disableAllPlugins(_ pluginType: String?,
                                        resolver: @escaping RCTPromiseResolveBlock,
                                        rejecter: @escaping RCTPromiseRejectBlock) {
        guard let pluginType = pluginType else {
            rejecter(noTypeErrorCode,
                     noTypeErrorBody,
                     nil)
            return
        }
        FacadeConnector.connector?.pluginManager?.disableAllPlugins(pluginType: pluginType, completion: { success in
            if success {
                resolver(true)
            } else {
                rejecter("disable_all_plugins",
                         "Failed to disable all plugins with type:\(pluginType)",
                         nil)
            }

        })
    }

    @objc public func enablePlugin(_ identifier: String?,
                                   resolver: @escaping RCTPromiseResolveBlock,
                                   rejecter: @escaping RCTPromiseRejectBlock) {
        guard let identifier = identifier else {
            rejecter(noIdentifierErrorCode,
                     noIdentifierErrorBody,
                     nil)
            return
        }
        FacadeConnector.connector?.pluginManager?.enablePlugin(identifier: identifier,
                                                               completion: { success in
                                                                   if success {
                                                                       resolver(true)
                                                                   } else {
                                                                       rejecter("enable_plugins",
                                                                                "Failed to enable plugin with id:\(identifier)",
                                                                                nil)
                                                                   }

        })
    }

    @objc public func enableAllPlugins(_ pluginType: String?,
                                       resolver: @escaping RCTPromiseResolveBlock,
                                       rejecter: @escaping RCTPromiseRejectBlock) {
        guard let pluginType = pluginType else {
            rejecter(noTypeErrorCode,
                     noTypeErrorBody,
                     nil)
            return
        }
        FacadeConnector.connector?.pluginManager?.enableAllPlugins(pluginType: pluginType,
                                                                   completion: { success in
                                                                       if success {
                                                                           resolver(true)
                                                                       } else {
                                                                           rejecter("enable_all_plugins",
                                                                                    "Failed to enable all plugins with type:\(pluginType)",
                                                                                    nil)
                                                                       }

        })
    }
}
