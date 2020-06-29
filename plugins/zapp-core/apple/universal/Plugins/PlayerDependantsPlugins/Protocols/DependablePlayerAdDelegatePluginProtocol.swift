//
//  DependablePlayerAdDelegatePluginProtocol.swift
//  ZappPlugins
//
//  Created by Anton Kononenko on 7/22/19.
//  Copyright © 2019 Applicaster LTD. All rights reserved.
//

import Foundation

/// Ad Delegate keys
public struct DependablePlayerAdDelegatePluginProtocolKeys {
    public static let playingKey = "advertismentPlaying"
}

/// Delegation that Video ads plugin pass data about ad
@objc public protocol DependablePlayerAdDelegatePluginProtocol: NSObjectProtocol {
    /// Video Ad will be presented
    ///
    /// - Parameter provider: instance of PlayerDependantPluginProtocol that will present ad
    func advertisementWillPresented(provider: PlayerDependantPluginProtocol)

    /// Video Ad will be removed
    ///
    /// - Parameter provider: instance of PlayerDependantPluginProtocol that will present ad
    func advertisementWillDismissed(provider: PlayerDependantPluginProtocol)

    /// Video Ad failed to load
    ///
    /// - Parameter provider: instance of PlayerDependantPluginProtocol that will present ad
    func advertisementFailedToLoad(provider: PlayerDependantPluginProtocol)
}
