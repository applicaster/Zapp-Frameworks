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

    override public init() {
        super.init()
        #if DEBUG
            thread = Thread(target: self, selector: #selector(NowPlayingLogger.logEvent), object: nil)
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

    /* logger is the main function for the thread that logs changes to the Now playing Info.
     * Every 100us, it pulls the NowPlayingInfo, and compares it to the Now Playing Info
     * that was retrieved in the last iteration. If it's different, it logs it to the console
     */
    @objc func logEvent() {
        #if DEBUG
            /* while the thread is not marked as cancelled, check to see if the current Now Playing
             * Info has changed since the last iteration, and log it if so */
            while thread?.isCancelled == false {
                if let npi = MPNowPlayingInfoCenter.default().nowPlayingInfo as NSDictionary? {
                    if npi != lastNowPlayingInfo {
                        lastNowPlayingInfo = npi
                        print("[NowPlayingLogger] \(npi)")
                    }

                    if !isRegisteredForRemoteCommands() {
                        print("[NowPlayingLogger] ERROR: You are not registered for remote commands, which is required. See MPRemoteCommandCenter.")
                    }
                } else {
                    print("[NowPlayingLogger] INFO: No data available")
                }
            }
            usleep(100)

        #endif
    }

    func isRegisteredForRemoteCommands() -> Bool {
        if let activeCommands = MPRemoteCommandCenter.shared().value(forKeyPath: "activeCommands.hasTargets") as? Array<Bool> {
            return activeCommands.count > 0 && activeCommands.first { $0 == true } != nil
        } else {
            print("warning: failed to determine if registered for remote commands")
        }
        return false
    }
}
