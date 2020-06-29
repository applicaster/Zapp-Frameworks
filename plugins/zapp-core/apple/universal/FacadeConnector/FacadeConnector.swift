//
//  FacadeConnector.swift
//  ZappPlugins
//
//  Created by Anton Kononenko on 9/23/19.
//  Copyright © 2019 Applicaster LTD. All rights reserved.
//

import Foundation
import UIKit

@objc public class FacadeConnector: NSObject {
    public static let enterpriseAppPrefix = "com.applicaster.ent."

    // Protocols

    @objc public var applicationData: FacadeConnectorAppDataProtocol? {
        return connectorProvider as? FacadeConnectorAppDataProtocol
    }

    @objc public var analytics: FacadeConnectorAnalyticsProtocol? {
        return connectorProvider as? FacadeConnectorAnalyticsProtocol
    }

    @objc public var playerDependant: FacadeConnectorPlayerDependantProtocol? {
        return connectorProvider as? FacadeConnectorPlayerDependantProtocol
    }

    @objc public var storage: FacadeConnectorStorageProtocol? {
        return connectorProvider as? FacadeConnectorStorageProtocol
    }

    @objc public var pluginManager: FacadeConnectorPluginManagerProtocol? {
        return connectorProvider as? FacadeConnectorPluginManagerProtocol
    }

    @objc public var push: FacadeConnectorPushProtocol? {
        return connectorProvider as? FacadeConnectorPushProtocol
    }

    @objc public var localNotification: FacadeConnectorLocalNotificationProtocol? {
        return connectorProvider as? FacadeConnectorLocalNotificationProtocol
    }

    @objc public var connectivity: FacadeConnectorConnnectivityProtocol? {
        return connectorProvider as? FacadeConnectorConnnectivityProtocol
    }
    
    @objc public var chromecast: FacadeConnectorChromecastProtocol? {
        return connectorProvider as? FacadeConnectorChromecastProtocol
    }
    
    
    let connectorProvider: NSObject

    @objc public static var connector: FacadeConnector? {
        guard Thread.isMainThread,
            let application = UIApplication.shared.delegate as? FacadeConnectorProtocol else {
            return nil
        }
        return application.connectorInstance
    }

    public init(connectorProvider: NSObject) {
        self.connectorProvider = connectorProvider
    }
}
