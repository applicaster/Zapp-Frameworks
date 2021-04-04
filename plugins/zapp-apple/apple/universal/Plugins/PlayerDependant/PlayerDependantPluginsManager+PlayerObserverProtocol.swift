
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

    public func playerVideoSeek(player: PlayerProtocol,
                                currentTime: TimeInterval,
                                seekTime: TimeInterval) {
        if let providers = providers(playerPlugin: player) {
            providers.forEach { providerDict in
                let provider = providerDict.value
                if let provider = provider as? PlayerObserverProtocol {
                    provider.playerVideoSeek?(player: player,
                                              currentTime: currentTime,
                                              seekTime: seekTime)
                }
            }
        }
    }

    public func playerReadyToPlay(player: PlayerProtocol) -> Bool {
        // provider can prevent from starting to play when player is ready to play
        // provider should call player.pluggablePlayerResume() when finished its operations
        var shouldContinuePlaying = true

        // should continue on first iteration when providers are not yet created
        guard providers(playerPlugin: player) == nil else {
            return shouldContinuePlaying
        }

        createProvidersIfNeeded(with: player)

        if let providers = providers(playerPlugin: player) {
            providers.forEach { providerDict in
                let provider = providerDict.value
                if let provider = provider as? PlayerObserverProtocol,
                   let value = provider.playerReadyToPlay?(player: player),
                   value == false {
                    // update only if false as player dependent plugins may have different value and we need single false to stop playback
                    shouldContinuePlaying = value
                }
            }
        }
        return shouldContinuePlaying
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
        createProvidersIfNeeded(with: player)

        if let providersForPlayer = providers(playerPlugin: player) {
            providersForPlayer.forEach { providerDict in
                let provider = providerDict.value
                if let provider = provider as? PlayerObserverProtocol {
                    provider.playerDidCreate(player: player)
                }
            }
        }
    }

    private func createProvidersIfNeeded(with player: PlayerProtocol) {
        // should continue on first iteration when providers are not yet created
        guard providers(playerPlugin: player) == nil else {
            return
        }

        unRegisterProviders(playerPlugin: player)

        let dependantPlayerProviders = createPlayerDependantProviders(for: player)

        if dependantPlayerProviders.count > 0 {
            providers["\(player.hash)"] = dependantPlayerProviders
        }
    }
}
