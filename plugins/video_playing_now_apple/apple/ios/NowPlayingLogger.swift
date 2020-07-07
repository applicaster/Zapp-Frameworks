//
//  NowPlayingLogger.swift
//  ZappAppleVideoNowPlayingInfo for iOS
//
//  Created by Alex Zchut on 11/02/2020.
//

import Foundation
import MediaPlayer

public class NowPlayingLogger: NSObject {
    var thread: Thread?
    var lastNowPlayingInfo: NSDictionary?

    public override init() {
        super.init()
        #if DEBUG
        thread = Thread(target: self, selector: #selector(NowPlayingLogger.logger), object: nil)
        #endif
    }

    func start() {
        #if DEBUG
        thread?.start()
        #endif
    }

    func stop() {
        #if DEBUG
        thread?.cancel()
        #endif
    }

    @objc func logger() {
        #if DEBUG
        if let npi = MPNowPlayingInfoCenter.default().nowPlayingInfo as NSDictionary? {
            if npi != lastNowPlayingInfo {
                lastNowPlayingInfo = npi
                print("[NowPlayingLogger] \(npi)")
            }

            if !isRegisteredForRemoteCommands() {
                print("[NowPlayingLogger] ERROR: You are not registered for remote commands, which is required. See MPRemoteCommandCenter.")
            }
        }

        #endif

    }

    func isRegisteredForRemoteCommands() -> Bool {
        if let activeCommands = MPRemoteCommandCenter.shared().value(forKeyPath: "activeCommands.hasTargets") as? Array<Bool> {
            return activeCommands.count > 0 && activeCommands.first { $0 == true} != nil
        }
        else {
            print("warning: failed to determine if registered for remote commands")
        }
        return false
    }
}
