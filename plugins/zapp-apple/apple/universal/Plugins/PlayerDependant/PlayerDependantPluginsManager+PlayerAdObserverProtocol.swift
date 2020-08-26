//
//  PlayerDependantPluginsManager_PlayerAdObserverProtocol.swift
//  Alamofire
//
//  Created by Shay markovich on 26/08/2020.
//

import Foundation
import ZappCore

extension PlayerDependantPluginsManager: PlayerAdObserverProtocol {
    public func playerAdStarted(player: PlayerProtocol) {
           if let providers = providers(playerPlugin: player) {
               providers.forEach { providerDict in
                   let provider = providerDict.value
                   if let provider = provider as? PlayerAdObserverProtocol {
                    provider.playerAdStarted(player: player)
                   }
               }
           }
       }
    
    public func playerAdCompleted(player: PlayerProtocol) {
          if let providers = providers(playerPlugin: player) {
              providers.forEach { providerDict in
                  let provider = providerDict.value
                  if let provider = provider as? PlayerAdObserverProtocol {
                   provider.playerAdCompleted(player: player)
                  }
              }
          }
      }
    
    public func playerAdProgressUpdate(player: PlayerProtocol,
                                     currentTime: TimeInterval,
                                     duration: TimeInterval) {
        if let providers = providers(playerPlugin: player) {
            providers.forEach { providerDict in
                let provider = providerDict.value
                if let provider = provider as? PlayerAdObserverProtocol {
                    provider.playerAdProgressUpdate(player: player,
                                                  currentTime: currentTime,
                                                  duration: duration)
                }
            }
        }
    }
    
    public func playerAdSkiped(player: PlayerProtocol) {
         if let providers = providers(playerPlugin: player) {
             providers.forEach { providerDict in
                 let provider = providerDict.value
                 if let provider = provider as? PlayerAdObserverProtocol {
                  provider.playerAdSkiped(player: player)
                 }
             }
         }
     }
    
}
