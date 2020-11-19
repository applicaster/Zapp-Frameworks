//
//  ZappAnalyticsPluginAkamai+PlayerObserverProtocol.swift
//  ZappAnalyticsPluginAkamai
//
//  Created by Alex Zchut on 18/11/2020.
//

import Foundation
import ZappCore

extension APAnalyticsProviderAkamai: PlayerObserverProtocol {
    public func playerDidFinishPlayItem(player: PlayerProtocol, completion: @escaping (Bool) -> Void) {
        akamaiClient?.playerPlaybackCompleted()
    }

    public func playerDidCreate(player: PlayerProtocol) {
        guard let playerObject = player.playerObject,
            let title = player.entry?["title"] else {
            return
        }

        let playerParams = ["AVPlayerKey": playerObject,
                            "title": title]

        akamaiClient?.playerWasCreated(playerParams)

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
        akamaiClient?.setPlayerItemState()
    }
}
