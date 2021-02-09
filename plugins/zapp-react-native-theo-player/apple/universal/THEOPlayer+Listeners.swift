//
//  THEOPlayer+Listeners.swift
//  ZappTHEOplayer
//
//  Created by Anton Kononenko on 2/2/21.
//

import Foundation
import os.log
import THEOplayerSDK

struct RNTHEOplayerKeys {
    static let currentTime = "currentTime"
    static let type = "type"
    static let currentProgramDateTime = "currentProgramDateTime"
    static let playbackRate = "playbackRate"
    static let readyState = "readyState"
    static let duration = "duration"
    static let presentationMode = "presentationMode"
    static let volume = "volume"
    static let source = "source"
    struct Source {
    }

    static let error = "error"
}

extension ReadyState {
    func toString() -> String {
        switch self {
        case .HAVE_CURRENT_DATA:
            return "HaveCurrentData"
        case .HAVE_NOTHING:
            return "HaveNothing"
        case .HAVE_METADATA:
            return "HaveMetaData"
        case .HAVE_FUTURE_DATA:
            return "HaveFutureData"
        case .HAVE_ENOUGH_DATA:
            return "HaveEnoughData"
        @unknown default:
            return ""
        }
    }
}

let jsEventListenerKey = "onJSMessageReceived"
struct JSListersEvents {
    static let onCloseButtonHandle = "onCloseButtonHandle"
}

extension THEOplayerView {
    // MARK: - THEOplayer listener related functions and closures

    func attachEventListeners() {
        // Listen to event and store references in dictionary
        listeners[PlayerEventTypes.PLAY.name] = player.addEventListener(type: PlayerEventTypes.PLAY, listener: play)
        listeners[PlayerEventTypes.PLAYING.name] = player.addEventListener(type: PlayerEventTypes.PLAYING, listener: playing)
        listeners[PlayerEventTypes.PAUSE.name] = player.addEventListener(type: PlayerEventTypes.PAUSE, listener: pause)
        listeners[PlayerEventTypes.PROGRESS.name] = player.addEventListener(type: PlayerEventTypes.PROGRESS, listener: progress)
        listeners[PlayerEventTypes.SEEKING.name] = player.addEventListener(type: PlayerEventTypes.SEEKING, listener: seeking)
        listeners[PlayerEventTypes.SEEKED.name] = player.addEventListener(type: PlayerEventTypes.SEEKED, listener: seeked)
        listeners[PlayerEventTypes.WAITING.name] = player.addEventListener(type: PlayerEventTypes.WAITING, listener: waiting)
        listeners[PlayerEventTypes.TIME_UPDATE.name] = player.addEventListener(type: PlayerEventTypes.TIME_UPDATE, listener: timeUpdate)
        listeners[PlayerEventTypes.RATE_CHANGE.name] = player.addEventListener(type: PlayerEventTypes.RATE_CHANGE, listener: rateChange)
        listeners[PlayerEventTypes.READY_STATE_CHANGE.name] = player.addEventListener(type: PlayerEventTypes.READY_STATE_CHANGE, listener: readyStateChange)
        listeners[PlayerEventTypes.LOADED_META_DATA.name] = player.addEventListener(type: PlayerEventTypes.LOADED_META_DATA, listener: loadedMetaData)
        listeners[PlayerEventTypes.LOADED_DATA.name] = player.addEventListener(type: PlayerEventTypes.LOADED_DATA, listener: loadedData)
        listeners[PlayerEventTypes.LOAD_START.name] = player.addEventListener(type: PlayerEventTypes.LOAD_START, listener: loadStart)
        listeners[PlayerEventTypes.CAN_PLAY.name] = player.addEventListener(type: PlayerEventTypes.CAN_PLAY, listener: canPlay)
        listeners[PlayerEventTypes.CAN_PLAY_THROUGH.name] = player.addEventListener(type: PlayerEventTypes.CAN_PLAY_THROUGH, listener: canPlayThrough)
        listeners[PlayerEventTypes.DURATION_CHANGE.name] = player.addEventListener(type: PlayerEventTypes.DURATION_CHANGE, listener: durationChange)
        listeners[PlayerEventTypes.SOURCE_CHANGE.name] = player.addEventListener(type: PlayerEventTypes.SOURCE_CHANGE, listener: sourceChange)
        listeners[PlayerEventTypes.PRESENTATION_MODE_CHANGE.name] = player.addEventListener(type: PlayerEventTypes.PRESENTATION_MODE_CHANGE, listener: presentationModeChange)
        listeners[PlayerEventTypes.VOLUME_CHANGE.name] = player.addEventListener(type: PlayerEventTypes.VOLUME_CHANGE, listener: volumeChange)
        listeners[PlayerEventTypes.RESIZE.name] = player.addEventListener(type: PlayerEventTypes.RESIZE, listener: resize)
        listeners[PlayerEventTypes.DESTROY.name] = player.addEventListener(type: PlayerEventTypes.DESTROY, listener: destroy)
        listeners[PlayerEventTypes.ENDED.name] = player.addEventListener(type: PlayerEventTypes.ENDED, listener: ended)
        listeners[PlayerEventTypes.ERROR.name] = player.addEventListener(type: PlayerEventTypes.ERROR, listener: error)
    }

    func removeEventListeners() {
        // Remove event listenrs
        player.removeEventListener(type: PlayerEventTypes.PLAY, listener: listeners[PlayerEventTypes.PLAY.name]!)
        player.removeEventListener(type: PlayerEventTypes.PLAYING, listener: listeners[PlayerEventTypes.PLAYING.name]!)
        player.removeEventListener(type: PlayerEventTypes.PAUSE, listener: listeners[PlayerEventTypes.PAUSE.name]!)
        player.removeEventListener(type: PlayerEventTypes.PROGRESS, listener: listeners[PlayerEventTypes.PROGRESS.name]!)
        player.removeEventListener(type: PlayerEventTypes.SEEKING, listener: listeners[PlayerEventTypes.SEEKING.name]!)
        player.removeEventListener(type: PlayerEventTypes.SEEKED, listener: listeners[PlayerEventTypes.SEEKED.name]!)
        player.removeEventListener(type: PlayerEventTypes.WAITING, listener: listeners[PlayerEventTypes.WAITING.name]!)
        player.removeEventListener(type: PlayerEventTypes.TIME_UPDATE, listener: listeners[PlayerEventTypes.TIME_UPDATE.name]!)
        player.removeEventListener(type: PlayerEventTypes.RATE_CHANGE, listener: listeners[PlayerEventTypes.RATE_CHANGE.name]!)
        player.removeEventListener(type: PlayerEventTypes.READY_STATE_CHANGE, listener: listeners[PlayerEventTypes.READY_STATE_CHANGE.name]!)
        player.removeEventListener(type: PlayerEventTypes.LOADED_META_DATA, listener: listeners[PlayerEventTypes.LOADED_META_DATA.name]!)
        player.removeEventListener(type: PlayerEventTypes.LOADED_DATA, listener: listeners[PlayerEventTypes.LOADED_DATA.name]!)
        player.removeEventListener(type: PlayerEventTypes.LOAD_START, listener: listeners[PlayerEventTypes.LOAD_START.name]!)
        player.removeEventListener(type: PlayerEventTypes.CAN_PLAY, listener: listeners[PlayerEventTypes.CAN_PLAY.name]!)
        player.removeEventListener(type: PlayerEventTypes.CAN_PLAY_THROUGH, listener: listeners[PlayerEventTypes.CAN_PLAY_THROUGH.name]!)
        player.removeEventListener(type: PlayerEventTypes.DURATION_CHANGE, listener: listeners[PlayerEventTypes.DURATION_CHANGE.name]!)
        player.removeEventListener(type: PlayerEventTypes.SOURCE_CHANGE, listener: listeners[PlayerEventTypes.SOURCE_CHANGE.name]!)
        player.removeEventListener(type: PlayerEventTypes.VOLUME_CHANGE, listener: listeners[PlayerEventTypes.VOLUME_CHANGE.name]!)
        player.removeEventListener(type: PlayerEventTypes.RESIZE, listener: listeners[PlayerEventTypes.RESIZE.name]!)
        player.removeEventListener(type: PlayerEventTypes.PRESENTATION_MODE_CHANGE, listener: listeners[PlayerEventTypes.PRESENTATION_MODE_CHANGE.name]!)
        player.removeEventListener(type: PlayerEventTypes.DESTROY, listener: listeners[PlayerEventTypes.DESTROY.name]!)
        player.removeEventListener(type: PlayerEventTypes.ENDED, listener: listeners[PlayerEventTypes.ENDED.name]!)
        player.removeEventListener(type: PlayerEventTypes.ERROR, listener: listeners[PlayerEventTypes.ERROR.name]!)

        listeners.removeAll()
    }

    private func play(event: PlayEvent) {
        os_log("PLAY event")

        onPlayerPlay?([RNTHEOplayerKeys.type: event.type,
                       RNTHEOplayerKeys.currentTime: event.getPatchedCurrentTime])
    }

    private func playing(event: PlayingEvent) {
        os_log("PLAYING event")
        onPlayerPlaying?([RNTHEOplayerKeys.type: event.type,
                          RNTHEOplayerKeys.currentTime: event.getPatchedCurrentTime])
    }

    private func pause(event: PauseEvent) {
        os_log("PAUSE event")
        onPlayerPause?([RNTHEOplayerKeys.type: event.type,
                        RNTHEOplayerKeys.currentTime: event.getPatchedCurrentTime])
    }

    private func progress(event: ProgressEvent) {
        os_log("PROGRESS event")
        onPlayerProgress?([RNTHEOplayerKeys.type: event.type,
                           RNTHEOplayerKeys.currentTime: event.getPatchedCurrentTime])
    }

    private func seeking(event: SeekingEvent) {
        os_log("SEEKING event")
        onPlayerSeeking?([RNTHEOplayerKeys.type: event.type,
                          RNTHEOplayerKeys.currentTime: event.getPatchedCurrentTime])
    }

    private func seeked(event: SeekedEvent) {
        os_log("SEEKED even")
        onPlayerSeeked?([RNTHEOplayerKeys.type: event.type,
                         RNTHEOplayerKeys.currentTime: event.getPatchedCurrentTime])
    }

    private func waiting(event: WaitingEvent) {
        os_log("WAITING event")
        onPlayerWaiting?([RNTHEOplayerKeys.type: event.type,
                          RNTHEOplayerKeys.currentTime: event.getPatchedCurrentTime])
    }

    private func timeUpdate(event: TimeUpdateEvent) {
        os_log("TIME_UPDATE event")
        var info: [String: Any] = [RNTHEOplayerKeys.type: event.type,
                                   RNTHEOplayerKeys.currentTime: event.getPatchedCurrentTime]

        if let currentTime = event.currentProgramDateTime?.timeIntervalSince1970 {
            info[RNTHEOplayerKeys.currentProgramDateTime] = currentTime
        }
        onPlayerTimeUpdate?(info)
    }

    private func rateChange(event: RateChangeEvent) {
        os_log("RATE_CHANGE event")
        onPlayerRateChange?([RNTHEOplayerKeys.type: event.type,
                             RNTHEOplayerKeys.currentTime: event.getPatchedCurrentTime,
                             RNTHEOplayerKeys.playbackRate: event.playbackRate])
    }

    private func readyStateChange(event: ReadyStateChangeEvent) {
        os_log("READY_STATE_CHANGE")
        onPlayerTimeUpdate?([RNTHEOplayerKeys.type: event.type,
                             RNTHEOplayerKeys.currentTime: event.getPatchedCurrentTime,
                             RNTHEOplayerKeys.readyState: event.readyState.toString()])
    }

    private func loadedMetaData(event: LoadedMetaDataEvent) {
        os_log("LOADED_META_DATA")
        onPlayerLoadedMetaData?([RNTHEOplayerKeys.type: event.type,
                                 RNTHEOplayerKeys.currentTime: event.getPatchedCurrentTime,
                                 RNTHEOplayerKeys.readyState: event.readyState.toString()])
    }

    private func loadedData(event: LoadedDataEvent) {
        os_log("LOADED_DATA event")
        onPlayerLoadedData?([RNTHEOplayerKeys.type: event.type,
                             RNTHEOplayerKeys.currentTime: event.getPatchedCurrentTime,
                             RNTHEOplayerKeys.readyState: event.readyState.toString()])
    }

    private func loadStart(event: LoadStartEvent) {
        os_log("LOAD_START event")
        onPlayerLoadStart?([RNTHEOplayerKeys.type: event.type,
                            RNTHEOplayerKeys.currentTime: event.getPatchedCurrentTime])
    }

    private func canPlay(event: CanPlayEvent) {
        os_log("CAN_PLAY event")
        onPlayerCanPlay?([RNTHEOplayerKeys.type: event.type,
                          RNTHEOplayerKeys.currentTime: event.getPatchedCurrentTime,
                          RNTHEOplayerKeys.readyState: event.readyState.toString()])
    }

    private func canPlayThrough(event: CanPlayThroughEvent) {
        os_log("CAN_PLAY_THROUGH event")
        onPlayerCanPlayThrough?([RNTHEOplayerKeys.type: event.type,
                                 RNTHEOplayerKeys.currentTime: event.getPatchedCurrentTime,
                                 RNTHEOplayerKeys.readyState: event.readyState.toString()])
    }

    private func durationChange(event: DurationChangeEvent) {
        os_log("DURATION_CHANGE event")
        var info: [String: Any] = [RNTHEOplayerKeys.type: event.type]
        if let duration = event.getPatchedDuration {
            info[RNTHEOplayerKeys.duration] = duration
        }
        onPlayerDurationChange?(info)
    }

    private func sourceChange(event: SourceChangeEvent) {
        os_log("SOURCE_CHANGE")
        onPlayerSourceChange?([RNTHEOplayerKeys.type: event.type,
                               RNTHEOplayerKeys.source: [
                               ]])
        // TODO: !!!!!!!!! not finished
    }

    private func presentationModeChange(event: PresentationModeChangeEvent) {
        os_log("PRESENTATION_MODE_CHANGE")
        onPlayerPresentationModeChange?([RNTHEOplayerKeys.type: event.type,
                                         RNTHEOplayerKeys.presentationMode: event.presentationMode.rawValue])
    }

    private func volumeChange(event: VolumeChangeEvent) {
        os_log("VOLUME_CHANGE event")

        onPlayerVolumeChange?([RNTHEOplayerKeys.type: event.type,
                               RNTHEOplayerKeys.currentTime: event.getPatchedCurrentTime,
                               RNTHEOplayerKeys.volume: event.volume])
    }

    private func playerResize(event: ResizeEvent) {
        onPlayerResize?([RNTHEOplayerKeys.type: event.type])
    }

    private func resize(event: ResizeEvent) {
        os_log("RESIZE")
        onPlayerCanPlayThrough?([RNTHEOplayerKeys.type: event.type])
    }

    private func destroy(event: DestroyEvent) {
        os_log("DESTROY")
        onPlayerDestroy?([RNTHEOplayerKeys.type: event.type])
    }

    private func ended(event: EndedEvent) {
        os_log("ENDED event")
        onPlayerEnded?([RNTHEOplayerKeys.type: event.type])
    }

    private func error(event: ErrorEvent) {
        os_log("ERROR event, error: %@", event.error)
        // TODO: !!!!!!!!! not finished

        onPlayerError?([RNTHEOplayerKeys.type: event.type,
                        RNTHEOplayerKeys.error: event.error,
            ])
    }

    // MARK: - THEOplayer JS listener sended from JS script

    func attachJSEventListeners() {
        player.addJavascriptMessageListener(name: jsEventListenerKey, listener: jsMessageReceived)
    }

    func removeJSEventListeners() {
        player.removeJavascriptMessageListener(name: jsEventListenerKey)
    }

    func jsMessageReceived(message: [String: Any]) {
        onJSWindowEvent?(message)
    }
}

extension CurrentTimeEvent {
    /// This function was crated to wrapp infinity bug of TheoPlayer returned to current time
    /// - Returns: -1 in case infinite value
    var getPatchedCurrentTime: Double {
        guard self.currentTime.isInfinite == false else {
            return 0
        }
        return self.currentTime
    }
}

extension DurationChangeEvent {
    /// This function was crated to wrapp infinity bug of TheoPlayer returned to duration
    /// - Returns: -1 in case infinite value
    var getPatchedDuration: Double? {
        guard let duration = self.duration,
              duration.isInfinite == false else {
            return 0
        }
        return self.duration
    }
}
