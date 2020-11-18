//
//  APAnalyticsProviderComScore+PlayerObserverProtocol.swift
//  ZappAnalyticsPluginComScore
//
//  Created by Alex Zchut on 18/11/2020.
//

import Foundation
import ZappCore

extension APAnalyticsProviderComScore: PlayerObserverProtocol {
    public func playerDidFinishPlayItem(player: PlayerProtocol, completion: @escaping (Bool) -> Void) {

    }

    public func playerDidCreate(player: PlayerProtocol) {
        guard let entry = player.entry else {
            return
        }

        APStreamSenseManager.sharedInstance()?.playerDidStartPlayItem(entry)
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(handleAccessLogEntry(notification:)),
                                               name: NSNotification.Name.AVPlayerItemNewAccessLogEntry,
                                               object: nil)
    }

    public func playerDidDismiss(player: PlayerProtocol) {
        //
    }

    public func playerProgressUpdate(player: PlayerProtocol, currentTime: TimeInterval, duration: TimeInterval) {
        //
    }

    @objc func handleAccessLogEntry(notification: NSNotification) {
        // Remove listening to the AccessLogs after first log received
        NotificationCenter.default.removeObserver(self,
                                                  name: NSNotification.Name.AVPlayerItemNewAccessLogEntry,
                                                  object: nil)
//        akamaiClient?.setPlayerItemState()
    }
}
