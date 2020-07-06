//
//  ZPAppleVideoNowPlayingInfoBase+PlayerObserverProtocol.swift
//  ZappAppleVideoNowPlayingInfo
//
//  Created by Alex Zchut on 11/02/2020.
//

import Foundation
import ZappCore

extension ZPAppleVideoNowPlayingInfoBase: PlayerObserverProtocol {
    func playerDidFinishPlayItem(player: PlayerProtocol, completion: @escaping (Bool) -> Void) {
        //implement in child classes
        completion(true)
    }
    
    func playerDidDismiss(player: PlayerProtocol) {
        //implement in child classes
    }
    
    func playerProgressUpdate(player: PlayerProtocol, currentTime: TimeInterval, duration: TimeInterval) {
        //implement in child classes
    }
    
    public func playerDidCreate(player: PlayerProtocol) {
        //implement in child classes
    }
}

