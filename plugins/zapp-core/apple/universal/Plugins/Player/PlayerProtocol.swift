//
//  QBPlayerProtocol.swift
//  ZappPlugins
//
//  Created by Anton Kononenko on 7/23/19.
//  Copyright © 2019 Applicaster LTD. All rights reserved.
//

import Foundation
import UIKit

/// Conforming this protocol allows Zapp Player plugin to support generic analytics system of Zapp App
@objc public protocol PlayerProtocol: NSObjectProtocol {
    /// DS raw atom entry format
    @objc var entry: [String: Any]? { get }

    /// Player instance that represents Player
    @objc var playerObject: NSObject? { get }

    /// Container where player was added
    @objc var pluginPlayerContainer: UIView? { get }

    /// UIViewController instance if player plugin is using it
    @objc var pluginPlayerViewController: UIViewController? { get }

    /// Pauses active player
    @objc func pluggablePlayerPause()

    /// Resume playing loaded item
    @objc func pluggablePlayerResume()

    /// Position of the video item that player is playing
    ///
    /// - Returns: TimeInterval value
    @objc func playbackPosition() -> TimeInterval

    /// Duration of the video item that player is playing
    ///
    /// - Returns: TimeInterval value
    @objc func playbackDuration() -> TimeInterval
}
