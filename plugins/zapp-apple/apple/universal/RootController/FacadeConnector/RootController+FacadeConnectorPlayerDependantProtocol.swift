//
//  RootController+FacadeConnectorPlayerDependantProtocol.swift
//  ZappApple
//
//  Created by Anton Kononenko on 10/17/19.
//  Copyright © 2019 Applicaster LTD. All rights reserved.
//

import Foundation
import ZappCore

extension RootController: FacadeConnectorPlayerDependantProtocol {
    public func playerDidFinishPlayItem(player: PlayerProtocol,
                                        completion: @escaping (Bool) -> Void) {
        pluginsManager.playerDependants.playerDidFinishPlayItem(player: player,
                                                                completion: completion)
    }

    public func playerDidCreate(player: PlayerProtocol) {
        pluginsManager.playerDependants.playerDidCreate(player: player)
    }

    public func playerDidDismiss(player: PlayerProtocol) {
        pluginsManager.playerDependants.playerDidDismiss(player: player)
    }

    public func playerProgressUpdate(player: PlayerProtocol,
                                     currentTime: TimeInterval,
                                     duration: TimeInterval) {
        pluginsManager.playerDependants.playerProgressUpdate(player: player,
                                                             currentTime: currentTime,
                                                             duration: duration)
    }

    public func playerReadyToPlay(player: PlayerProtocol) -> Bool {
        return pluginsManager.playerDependants.playerReadyToPlay(player: player)
    }

    public func playerAdStarted(player: PlayerProtocol) {
        pluginsManager.playerDependants.playerAdStarted(player: player)
    }

    public func playerAdCompleted(player: PlayerProtocol) {
        pluginsManager.playerDependants.playerAdCompleted(player: player)
    }

    public func playerAdSkiped(player: PlayerProtocol) {
        pluginsManager.playerDependants.playerAdSkiped(player: player)
    }

    public func playerAdProgressUpdate(player: PlayerProtocol,
                                       currentTime: TimeInterval,
                                       duration: TimeInterval) {
        pluginsManager.playerDependants.playerAdProgressUpdate(player: player,
                                                               currentTime: currentTime,
                                                               duration: duration)
    }
}
