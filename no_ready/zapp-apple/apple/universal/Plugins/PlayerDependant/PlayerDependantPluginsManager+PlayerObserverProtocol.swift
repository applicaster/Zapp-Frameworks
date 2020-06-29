
//
//  QBPlayerObserverProtocol.swift
//  ZappPlugins
//
//  Created by Anton Kononenko on 7/25/19.
//

import Foundation
import ZappCore

extension PlayerDependantPluginsManager: PlayerObserverProtocol {
    public func playerDidFinishPlayItem(player: PlayerProtocol,
                                        completion: @escaping (_ completion: Bool) -> Void) {
        var finishedProviderCount = 0
        guard let providers = providers(playerPlugin: player),
            providers.count > 0 else {
            completion(true)
            return
        }
        
        providers.forEach { providerDict in
            let provider = providerDict.value
            if let provider = provider as? PlayerObserverProtocol {
                provider.playerDidFinishPlayItem(player: player, completion: { _ in
                    finishedProviderCount += 1
                    if finishedProviderCount == providers.count {
                        completion(true)
                    }
                })
            } else {
                finishedProviderCount += 1
                if finishedProviderCount == providers.count {
                    completion(true)
                }
            }
        }
    }

    public func playerProgressUpdate(player: PlayerProtocol,
                                     currentTime: TimeInterval,
                                     duration: TimeInterval) {
        if let providers = providers(playerPlugin: player) {
            providers.forEach { providerDict in
                let provider = providerDict.value
                if let provider = provider as? PlayerObserverProtocol {
                    provider.playerProgressUpdate(player: player,
                                                  currentTime: currentTime,
                                                  duration: duration)
                }
            }
        }
    }

    public func playerDidDismiss(player: PlayerProtocol) {
        if let providersForPlayer = providers(playerPlugin: player) {
            providersForPlayer.forEach { providerDict in
                let provider = providerDict.value
                if let provider = provider as? PlayerObserverProtocol {
                    provider.playerDidDismiss(player: player)
                }
            }
            unRegisterProviders(playerPlugin: player)
        }
    }

    public func playerDidCreate(player: PlayerProtocol) {

        unRegisterProviders(playerPlugin: player)

        let dependantPlayerProviders = createPlayerDependantProviders(for: player)

        if dependantPlayerProviders.count > 0 {
            providers["\(player.hash)"] = dependantPlayerProviders
        }
    }
}
