//
//  PlayerObserverProtocol.swift
//  ZappPlugins
//
//  Created by Anton Kononenko on 7/26/19.
//  Copyright © 2019 Applicaster LTD. All rights reserved.
//

import Foundation

/// Implamentation of this protocol allow Player dependant plugins type to observe a player isntance
@objc public protocol PlayerObserverProtocol {
    /// Player finished play video item
    ///
    /// - Parameters:
    ///   - player: instance of the player that conform PlayerProtocol protocol
    ///   - completion: completion when all dependant item will be completed player can start next move or can be closed
    func playerDidFinishPlayItem(player: PlayerProtocol,
                                 completion: @escaping (_ finished: Bool) -> Void)

    /// Player instance did created
    ///
    ///  - player: instance of the player that conform PlayerProtocol protocol
    func playerDidCreate(player: PlayerProtocol)

    /// Player instance did dismiss
    ///
    ///  - player: instance of the player that conform PlayerProtocol protocol
    func playerDidDismiss(player: PlayerProtocol)

    /// Player instance update current time
    ///
    /// - Parameters:
    ///  - player: instance of the player that conform PlayerProtocol protocol
    ///   - currentTime: current time
    ///   - duration: video item duration
    func playerProgressUpdate(player: PlayerProtocol,
                              currentTime: TimeInterval,
                              duration: TimeInterval)
}
