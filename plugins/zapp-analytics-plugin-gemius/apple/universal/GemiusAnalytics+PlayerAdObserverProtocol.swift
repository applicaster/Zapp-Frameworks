//
//  GemiusAnalytics+PlayerAdObserverProtocol.swift
//  GemiusAnalytics
//
//  Created by Alex Zchut on 29/03/2021.
//  Copyright © 2021 Applicaster Ltd. All rights reserved.
//

import Foundation
import ZappCore

extension GemiusAnalytics: PlayerAdObserverProtocol {
    func playerAdStarted(player: PlayerProtocol) {
        objcHelper?.prepareEventPlayerDidStartPlayAd { eventName, parameters in
            let trackParameters = parameters as? [String: NSObject] ?? [:]
            self.trackEvent(eventName, parameters: trackParameters)
        }
    }
    
    func playerAdCompleted(player: PlayerProtocol) {
        objcHelper?.prepareEventPlayerDidFinishPlayAd { eventName, parameters in
            let trackParameters = parameters as? [String: NSObject] ?? [:]
            self.trackEvent(eventName, parameters: trackParameters)
        }
    }
    
    func playerAdSkiped(player: PlayerProtocol) {
        objcHelper?.prepareEventPlayerDidSkippedPlayAd { eventName, parameters in
            let trackParameters = parameters as? [String: NSObject] ?? [:]
            self.trackEvent(eventName, parameters: trackParameters)
        }
    }
    
    func playerAdProgressUpdate(player: PlayerProtocol, currentTime: TimeInterval, duration: TimeInterval) {
        let heartbeatDelay = 3.0
        if lastSavedAdPosition + heartbeatDelay < currentTime {
            objcHelper?.prepareEventPlayerAdPlaybackProgress(currentTime) { eventName, parameters in
                let trackParameters = parameters as? [String: NSObject] ?? [:]
                self.trackEvent(eventName, parameters: trackParameters)
            }
        }
    }
    
    
}
