//
//  RootController+FacadeConnectorAudioSessionProtocol.swift
//  ZappApple
//
//  Created by Alex Zchut on 06/07/2020.
//

import Foundation
import ZappCore
import AVFoundation

extension RootController: FacadeConnectorAudioSessionProtocol {
    public func enableAudioSessionWithPlayback() {
         let session = AVAudioSession.sharedInstance()
       _ = try? session.setCategory(.playback, mode: .default, options: [])

       _ = try? session.setActive(true, options: [])
    }
    
    public func disableAudioSession() {
        let session = AVAudioSession.sharedInstance()
        _ = try? session.setActive(false, options: [])
        
    }
    
    public func notifyBackgroundAudioToContinuePlaying() {
        let session = AVAudioSession.sharedInstance()
        if session.isOtherAudioPlaying {
            do {
                // This is to unduck others, make other playing sounds go back up in volume
                try session.setActive(false, options: .notifyOthersOnDeactivation)
            } catch {
                NSLog("AVAudioSession unable to restore the bg audio")
            }
        }
        else {
            disableAudioSession()
        }
    }
    
    public func enablePlaybackCategoryIfNeededToMuteBackgroundAudio(forItem item: NSObject?) {
        if let item = item as? AVPlayerItem,
            item.asset.tracks(withMediaType: .audio).count > 0 {
                self.enablePlaybackCategoryIfNeededToMuteBackgroundAudio()
        }
        else {
            disableAudioSession()
        }
    }
    
    private func enablePlaybackCategoryIfNeededToMuteBackgroundAudio() {
        let session = AVAudioSession.sharedInstance()
        if session.isOtherAudioPlaying {
            _ = try? session.setCategory(.playback, mode: .default, options: .duckOthers)
            _ = try? session.setActive(true, options: [])
        }
    }
}
