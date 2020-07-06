//
//  FacadeConnectorAudioSessionProtocol.swift
//  ZappCore
//
//  Created by Alex Zchut on 06/07/2020.
//

import Foundation

@objc public protocol FacadeConnectorAudioSessionProtocol {

    @objc func enableAudioSessionWithPlayback()
    @objc func disableAudioSession()
    @objc func enablePlaybackCategoryIfNeededToMuteBackgroundAudio(forItem item: NSObject?)
    @objc func notifyBackgroundAudioToContinuePlaying()
}
