//
//  THEOPlayer+PlayerProtocol.swift
//  ZappTHEOplayer
//
//  Created by Alex Zchut on 04/04/2021.
//

import Foundation
import ZappCore

extension THEOplayerView: PlayerProtocol {
    public var entry: [String: Any]? {
        return nil
    }

    public var playerObject: NSObject? {
        return self
    }

    public var pluginPlayerContainer: UIView? {
        return nil
    }

    public var pluginPlayerViewController: UIViewController? {
        return nil
    }

    public func pluggablePlayerPause() {
    }

    public func pluggablePlayerResume() {
    }

    public func playbackPosition() -> TimeInterval {
        return 0
    }

    public func playbackDuration() -> TimeInterval {
        return 0
    }
}
