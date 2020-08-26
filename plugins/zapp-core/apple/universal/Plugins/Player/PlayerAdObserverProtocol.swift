//
//  PlayerAdObserverProtocol.swift
//  ZappPlugins
//
//  Created by Shay markovich on 26/08/2020.
//

import Foundation

/// Implamentation of this protocol allow Player dependant plugins type to observe a player ad  events
@objc public protocol PlayerAdObserverProtocol {
    /// Player Ad Started
    ///
    ///  - player: instance of the player that conform PlayerProtocol protocol
    func playerAdStarted(player: PlayerProtocol)
    
    /// Player Ad Completed
    ///
    ///  - player: instance of the player that conform PlayerProtocol protocol
    func playerAdCompleted(player: PlayerProtocol)
   
    /// Player Ad Skiped
    ///
    ///  - player: instance of the player that conform PlayerProtocol protocol
    func playerAdSkiped(player: PlayerProtocol)
   
    /// Player instance update current time
    ///
    /// - Parameters:
    ///  - player: instance of the player that conform PlayerProtocol protocol
    ///  - currentTime: current Ad  time
    ///  - duration: Ad item duration
    func playerAdProgressUpdate(player: PlayerProtocol, currentTime: TimeInterval, duration: TimeInterval)
}
