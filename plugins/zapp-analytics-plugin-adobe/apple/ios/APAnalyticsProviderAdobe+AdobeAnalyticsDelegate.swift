//
//  APAnalyticsProviderAdobe+AdobeAnalyticsDelegate.swift
//  ZappAnalyticsPluginAdobe
//
//  Created by Alex Zchut on 22/11/2020.
//

import Foundation
import AVFoundation
import ZappCore

extension APAnalyticsProviderAdobe: AdobeAnalyticsDelegate {
    public func isDebug() -> Bool {
        guard let value = FacadeConnector.connector?.storage?.sessionStorageValue(for: "application_environment", namespace: nil) else {
            return false
        }
        
        return Bool(value) ?? false
    }
    
    public func getDeviceID() -> String! {
        return FacadeConnector.connector?.storage?.sessionStorageValue(for: "uuid", namespace: nil) ?? ""
    }
    
    public func getCurrentPlayedItemEntry() -> [AnyHashable : Any] {
        return self.playerPlugin?.entry ?? [:]
    }
    
    public func getCurrentPlayerInstance() -> AVPlayer? {
        return self.avPlayer
    }
    
    
}
