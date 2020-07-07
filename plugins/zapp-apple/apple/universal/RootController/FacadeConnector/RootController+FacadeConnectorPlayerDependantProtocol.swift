//
//  RootController+FacadeConnectorPlayerDependantProtocol.swift
//  ZappApple
//
//  Created by Anton Kononenko on 10/17/19.
//  Copyright © 2019 Anton Kononenko. All rights reserved.
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
}
