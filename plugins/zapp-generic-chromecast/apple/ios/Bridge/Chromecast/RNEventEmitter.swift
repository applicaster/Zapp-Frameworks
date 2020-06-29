//
//  RNEventEmitter.swift
//  ZappChromecast
//
//  Created by Alex Zchut on 05/05/2020.
//

import Foundation
import React

@objc(RNGoogleCastEventEmitter)
open class RNEventEmitter: RCTEventEmitter {
    public static var emitter: RCTEventEmitter!
    
    public enum Events: String, CaseIterable {
        
        case CAST_STATE_CHANGED = "GoogleCast:CastStateChanged"
        case SESSION_STARTED = "GoogleCast:SessionStarted"
        case SESSION_START_FAILED = "GoogleCast:SessionStartFailed"
        case SESSION_SUSPENDED = "GoogleCast:SessionSuspeneded"
        case SESSION_RESUMING = "GoogleCast:SessionResuming"
        case SESSION_RESUMED = "GoogleCast:SessionResumed"
        case SESSION_ENDING = "GoogleCast:SessionEnding"
        case MEDIA_STATUS_UPDATED = "GoogleCast:MediaStatusUpdated"
        case MEDIA_PLAYBACK_STARTED = "GoogleCast:MediaPlaybackStarted"
        case MEDIA_PLAYBACK_ENDED = "GoogleCast:MediaPlaybackEnded"
        case MEDIA_PROGRESS_UPDATED = "GoogleCast:MediaProgressUpdated"
        case CHANNEL_CONNECTED = "GoogleCast:ChannelConnected"
        case CHANNEL_DISCONNECTED = "GoogleCast:ChannelDisconnected"
        case CHANNEL_MESSAGE_RECEIVED = "GoogleCast:ChannelMessageReceived"
    }
    
    public static func sendEvent(for event: Events, with body: Any) {
        emitter.sendEvent(withName: event.rawValue, body: body)
    }
    
    override init() {
        super.init()
        RNEventEmitter.emitter = self
    }
    
    override public class func requiresMainQueueSetup() -> Bool {
        return true
    }

    open override func supportedEvents() -> [String] {
        return Events.allCases.map { $0.rawValue}
    }
}
