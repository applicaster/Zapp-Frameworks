//
//  RootController+FacadeConnectorChromecastProtocol.swift
//  ZappApple
//
//  Created by Alex Zchut on 13/04/2020.
//

import Foundation
import ZappCore

extension RootController: FacadeConnectorChromecastProtocol {
    public var isEnabled: Bool {
        return pluginInstance?.isEnabled ?? false
    }
    
    public var isSynced: Bool {
        return pluginInstance?.hasConnectedCastSession() ?? false
    }
    
    public var isReachableViaWiFi: Bool {
        let value = FacadeConnector.connector?.connectivity?.getCurrentConnectivityState() ?? .offline
        return value == .wifi
    }
    
    public var canShowPlayerBeforeCastSync: Bool {
        return pluginInstanceExtendedPlayerControls?.canShowPlayerBeforeCastSync() ?? false
    }
    
    public var extendedPlayerViewController: UIViewController? {
        return pluginInstanceExtendedPlayerControls?.getExpandedPlayerControlsViewController()
    }
    
    public var inlinePlayerViewController: UIViewController? {
        return pluginInstanceExtendedPlayerControls?.getInlinePlayerControlsViewController()
    }
    
    public var miniPlayerViewController: UIViewController? {
        return pluginInstanceExtendedPlayerControls?.getMiniPlayerControlsViewController()
    }
    
    public func play(with playableItems: [NSObject], playPosition: TimeInterval, completion: ((_ success:Bool) -> Void)?) {
        pluginInstanceExtendedPlayerControls?.play(playableItems: playableItems, playPosition: playPosition, completion: completion)
    }
    
    public func showExtendedPlayer() {
        pluginInstanceExtendedPlayerControls?.presentExtendedPlayerControls()
    }
    
    public func setNotificationsDelegate(_ delegate: NSObject?) {
        guard var plugin = pluginInstance else {
            return
        }
        plugin.containerViewEventsDelegate = delegate
    }
    
    public func addButton(to container: UIView?, key: String, color: UIColor?) {
        pluginInstance?.addButton(to: container, key: key, color: color)
    }
    
    fileprivate var pluginInstance: ChromecastProtocol? {
        guard let chromecastPlugin = FacadeConnector.connector?.pluginManager?.getProviderInstance(pluginType: ZPPluginType.General.rawValue,
                                                                                                   condition: { $0 as? ChromecastProtocol }) else {
                return nil
        }
        return chromecastPlugin as? ChromecastProtocol
    }
    
    fileprivate var pluginInstanceExtendedPlayerControls: ChromecastExtendedPlayerControlsProtocol? {
        return pluginInstance as? ChromecastExtendedPlayerControlsProtocol
    }
}
