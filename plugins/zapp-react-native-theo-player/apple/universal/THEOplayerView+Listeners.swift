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
        logger?.debugLog(message: "Player Add event listeners")
        
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
        
        // Ads events
        listeners[AdsEventTypes.AD_BREAK_BEGIN.name] = player.ads.addEventListener(type: AdsEventTypes.AD_BREAK_BEGIN, listener: adBreakBegin)
        listeners[AdsEventTypes.AD_BREAK_END.name] = player.ads.addEventListener(type: AdsEventTypes.AD_BREAK_END, listener: adBreakEnd)
        listeners[AdsEventTypes.AD_ERROR.name] = player.ads.addEventListener(type: AdsEventTypes.AD_ERROR, listener: adError)
        listeners[AdsEventTypes.AD_BEGIN.name] = player.ads.addEventListener(type: AdsEventTypes.AD_BEGIN, listener: adBegin)
        listeners[AdsEventTypes.AD_END.name] = player.ads.addEventListener(type: AdsEventTypes.AD_END, listener: adEnd)

    }

    func removeEventListeners() {
        
        logger?.debugLog(message: "Player Remove event listeners")
        
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

        player.ads.removeEventListener(type: AdsEventTypes.AD_BREAK_BEGIN, listener: listeners[AdsEventTypes.AD_BREAK_BEGIN.name]!)
        player.ads.removeEventListener(type: AdsEventTypes.AD_BREAK_END, listener: listeners[AdsEventTypes.AD_BREAK_END.name]!)
        player.ads.removeEventListener(type: AdsEventTypes.AD_ERROR, listener: listeners[AdsEventTypes.AD_ERROR.name]!)
        player.ads.removeEventListener(type: AdsEventTypes.AD_BEGIN, listener: listeners[AdsEventTypes.AD_BEGIN.name]!)
        player.ads.removeEventListener(type: AdsEventTypes.AD_END, listener: listeners[AdsEventTypes.AD_END.name]!)
        listeners.removeAll()
    }

    private func play(event: PlayEvent) {
        logger?.debugLog(message: "\(eventNamesKey) \(event.type)",
                         data: [RNTHEOplayerKeys.type: event.type,
                                RNTHEOplayerKeys.currentTime: event.getPatchedCurrentTime])
        onPlayerPlay?([RNTHEOplayerKeys.type: event.type,
                       RNTHEOplayerKeys.currentTime: event.getPatchedCurrentTime])
    }

    private func playing(event: PlayingEvent) {
        logger?.debugLog(message: "\(eventNamesKey) \(event.type)",
                         data: [RNTHEOplayerKeys.type: event.type,
                                RNTHEOplayerKeys.currentTime: event.getPatchedCurrentTime])
        onPlayerPlaying?([RNTHEOplayerKeys.type: event.type,
                          RNTHEOplayerKeys.currentTime: event.getPatchedCurrentTime])
    }

    private func pause(event: PauseEvent) {
        logger?.debugLog(message: "\(eventNamesKey) \(event.type)",
                         data: [RNTHEOplayerKeys.type: event.type,
                                RNTHEOplayerKeys.currentTime: event.getPatchedCurrentTime])
        onPlayerPause?([RNTHEOplayerKeys.type: event.type,
                        RNTHEOplayerKeys.currentTime: event.getPatchedCurrentTime])
    }

    private func progress(event: ProgressEvent) {
        onPlayerProgress?([RNTHEOplayerKeys.type: event.type,
                           RNTHEOplayerKeys.currentTime: event.getPatchedCurrentTime])
    }

    private func seeking(event: SeekingEvent) {
        onPlayerSeeking?([RNTHEOplayerKeys.type: event.type,
                          RNTHEOplayerKeys.currentTime: event.getPatchedCurrentTime])
    }

    private func seeked(event: SeekedEvent) {
        logger?.debugLog(message: "\(eventNamesKey) \(event.type)",
                         data: [RNTHEOplayerKeys.type: event.type,
                                RNTHEOplayerKeys.currentTime: event.getPatchedCurrentTime])
        onPlayerSeeked?([RNTHEOplayerKeys.type: event.type,
                         RNTHEOplayerKeys.currentTime: event.getPatchedCurrentTime])
    }

    private func waiting(event: WaitingEvent) {
        logger?.debugLog(message: "\(eventNamesKey) \(event.type)",
                         data: [RNTHEOplayerKeys.type: event.type,
                                RNTHEOplayerKeys.currentTime: event.getPatchedCurrentTime])
        onPlayerWaiting?([RNTHEOplayerKeys.type: event.type,
                          RNTHEOplayerKeys.currentTime: event.getPatchedCurrentTime])
    }

    private func timeUpdate(event: TimeUpdateEvent) {
        var info: [String: Any] = [RNTHEOplayerKeys.type: event.type,
                                   RNTHEOplayerKeys.currentTime: event.getPatchedCurrentTime]

        if let currentTime = event.currentProgramDateTime?.timeIntervalSince1970 {
            info[RNTHEOplayerKeys.currentProgramDateTime] = currentTime
        }
        logger?.debugLog(message: "\(eventNamesKey) \(event.type)",
                         data: info)
        onPlayerTimeUpdate?(info)
    }

    private func rateChange(event: RateChangeEvent) {
        logger?.debugLog(message: "\(eventNamesKey) \(event.type)",
                         data: [RNTHEOplayerKeys.type: event.type,
                                RNTHEOplayerKeys.currentTime: event.getPatchedCurrentTime,
                                RNTHEOplayerKeys.playbackRate: event.playbackRate])
        onPlayerRateChange?([RNTHEOplayerKeys.type: event.type,
                             RNTHEOplayerKeys.currentTime: event.getPatchedCurrentTime,
                             RNTHEOplayerKeys.playbackRate: event.playbackRate])
    }

    private func readyStateChange(event: ReadyStateChangeEvent) {
        logger?.debugLog(message: "\(eventNamesKey) \(event.type)",
                         data: [RNTHEOplayerKeys.type: event.type,
                                RNTHEOplayerKeys.currentTime: event.getPatchedCurrentTime,
                                RNTHEOplayerKeys.readyState: event.readyState.toString()])
        onPlayerTimeUpdate?([RNTHEOplayerKeys.type: event.type,
                             RNTHEOplayerKeys.currentTime: event.getPatchedCurrentTime,
                             RNTHEOplayerKeys.readyState: event.readyState.toString()])
    }

    private func loadedMetaData(event: LoadedMetaDataEvent) {
        logger?.debugLog(message: "\(eventNamesKey) \(event.type)",
                         data: [RNTHEOplayerKeys.type: event.type,
                                RNTHEOplayerKeys.currentTime: event.getPatchedCurrentTime,
                                RNTHEOplayerKeys.readyState: event.readyState.toString()])
        onPlayerLoadedMetaData?([RNTHEOplayerKeys.type: event.type,
                                 RNTHEOplayerKeys.currentTime: event.getPatchedCurrentTime,
                                 RNTHEOplayerKeys.readyState: event.readyState.toString()])
    }

    private func loadedData(event: LoadedDataEvent) {
        logger?.debugLog(message: "\(eventNamesKey) \(event.type)",
                         data: [RNTHEOplayerKeys.type: event.type,
                                RNTHEOplayerKeys.currentTime: event.getPatchedCurrentTime,
                                RNTHEOplayerKeys.readyState: event.readyState.toString()])
        onPlayerLoadedData?([RNTHEOplayerKeys.type: event.type,
                             RNTHEOplayerKeys.currentTime: event.getPatchedCurrentTime,
                             RNTHEOplayerKeys.readyState: event.readyState.toString()])
    }

    private func loadStart(event: LoadStartEvent) {
        logger?.debugLog(message: "\(eventNamesKey) \(event.type)",
                         data: [RNTHEOplayerKeys.type: event.type,
                                RNTHEOplayerKeys.currentTime: event.getPatchedCurrentTime])
        onPlayerLoadStart?([RNTHEOplayerKeys.type: event.type,
                            RNTHEOplayerKeys.currentTime: event.getPatchedCurrentTime])
    }

    private func canPlay(event: CanPlayEvent) {
        logger?.debugLog(message: "\(eventNamesKey) \(event.type)",
                         data: [RNTHEOplayerKeys.type: event.type,
                                RNTHEOplayerKeys.currentTime: event.getPatchedCurrentTime,
                                RNTHEOplayerKeys.readyState: event.readyState.toString()])
        onPlayerCanPlay?([RNTHEOplayerKeys.type: event.type,
                          RNTHEOplayerKeys.currentTime: event.getPatchedCurrentTime,
                          RNTHEOplayerKeys.readyState: event.readyState.toString()])
    }

    private func canPlayThrough(event: CanPlayThroughEvent) {
        logger?.debugLog(message: "\(eventNamesKey) \(event.type)",
                         data: [RNTHEOplayerKeys.type: event.type,
                                RNTHEOplayerKeys.currentTime: event.getPatchedCurrentTime,
                                RNTHEOplayerKeys.readyState: event.readyState.toString()])
        onPlayerCanPlayThrough?([RNTHEOplayerKeys.type: event.type,
                                 RNTHEOplayerKeys.currentTime: event.getPatchedCurrentTime,
                                 RNTHEOplayerKeys.readyState: event.readyState.toString()])
    }

    private func durationChange(event: DurationChangeEvent) {
        var info: [String: Any] = [RNTHEOplayerKeys.type: event.type]
        if let duration = event.getPatchedDuration {
            info[RNTHEOplayerKeys.duration] = duration
        }
        logger?.debugLog(message: "\(eventNamesKey) \(event.type)",
                         data: info)
        onPlayerDurationChange?(info)
    }

    private func sourceChange(event: SourceChangeEvent) {
        os_log("SOURCE_CHANGE")
        logger?.debugLog(message: "\(eventNamesKey) \(event.type)",
                         data: [RNTHEOplayerKeys.type: event.type])

        onPlayerSourceChange?([RNTHEOplayerKeys.type: event.type,
                               RNTHEOplayerKeys.source: [
                               ]])
        // TODO: !!!!!!!!! not finished
    }

    private func presentationModeChange(event: PresentationModeChangeEvent) {
        logger?.debugLog(message: "\(eventNamesKey) \(event.type)",
                         data: [RNTHEOplayerKeys.type: event.type,
                                RNTHEOplayerKeys.presentationMode: event.presentationMode.rawValue])
        onPlayerPresentationModeChange?([RNTHEOplayerKeys.type: event.type,
                                         RNTHEOplayerKeys.presentationMode: event.presentationMode.rawValue])
    }

    private func volumeChange(event: VolumeChangeEvent) {
        logger?.debugLog(message: "\(eventNamesKey) \(event.type)",
                         data: [RNTHEOplayerKeys.type: event.type,
                                RNTHEOplayerKeys.currentTime: event.getPatchedCurrentTime,
                                RNTHEOplayerKeys.volume: event.volume])

        onPlayerVolumeChange?([RNTHEOplayerKeys.type: event.type,
                               RNTHEOplayerKeys.currentTime: event.getPatchedCurrentTime,
                               RNTHEOplayerKeys.volume: event.volume])
    }

    private func playerResize(event: ResizeEvent) {
        logger?.debugLog(message: "\(eventNamesKey) \(event.type)",
                         data: [RNTHEOplayerKeys.type: event.type])
        onPlayerResize?([RNTHEOplayerKeys.type: event.type])
    }

    private func resize(event: ResizeEvent) {
        logger?.debugLog(message: "\(eventNamesKey) \(event.type)",
                         data: [RNTHEOplayerKeys.type: event.type])
        onPlayerCanPlayThrough?([RNTHEOplayerKeys.type: event.type])
    }

    private func destroy(event: DestroyEvent) {
        logger?.debugLog(message: "\(eventNamesKey) \(event.type)",
                         data: [RNTHEOplayerKeys.type: event.type])
        onPlayerDestroy?([RNTHEOplayerKeys.type: event.type])
    }

    private func ended(event: EndedEvent) {
        logger?.debugLog(message: "\(eventNamesKey) \(event.type)",
                         data: [RNTHEOplayerKeys.type: event.type])
        onPlayerEnded?([RNTHEOplayerKeys.type: event.type])
    }

    private func error(event: ErrorEvent) {
        logger?.debugLog(message: "ERROR event, error: \(event.error)",
                         data: [RNTHEOplayerKeys.type: event.type,
                                "error": event.error])
        onPlayerError?([RNTHEOplayerKeys.type: event.type,
                        RNTHEOplayerKeys.error: event.error,
            ])
    }
    
    // MARK: - Ad Events
    private func adBreakBegin(event: AdBreakBeginEvent) {
        let params = [RNTHEOplayerKeys.type: event.type]
 
        logger?.debugLog(message: "\(eventNamesKey) \(event.type)",
                         data: params)
        onAdBreakBegin?(params)
    }
    
    private func adBreakEnd(event: AdBreakEndEvent) {
        let params = [RNTHEOplayerKeys.type: event.type]

        logger?.debugLog(message: "\(eventNamesKey) \(event.type)",
                         data: params)
        onAdBreakEnd?(params)
    }
    
    private func adError(event: AdErrorEvent) {
        logger?.debugLog(message: "\(eventNamesKey) \(event.type)",
                         data: [RNTHEOplayerKeys.type: event.type])
        onAdError?([RNTHEOplayerKeys.type: event.type])
    }
    
    private func adBegin(event: AdBeginEvent) {
        var params:[String: Any] = [RNTHEOplayerKeys.type: event.type]
        //append params
        getAdParams(from: event).forEach { params[$0] = $1 }
        
        logger?.debugLog(message: "\(eventNamesKey) \(event.type)",
                         data: params)
        onAdBegin?(params)
    }
    
    private func adEnd(event: AdEndEvent) {
        var params:[String: Any] = [RNTHEOplayerKeys.type: event.type]
        //append params
        getAdParams(from: event).forEach { params[$0] = $1 }
        
        logger?.debugLog(message: "\(eventNamesKey) \(event.type)",
                         data: params)
        
        onAdEnd?(params)
    }

    // MARK: - THEOplayer JS listener sended from JS script

    func attachJSEventListeners() {
        logger?.debugLog(message: "Attach JS Event Listeners")
        player.addJavascriptMessageListener(name: jsEventListenerKey, listener: jsMessageReceived)
    }

    func removeJSEventListeners() {
        logger?.debugLog(message: "Remove JS Event Listeners")
        player.removeJavascriptMessageListener(name: jsEventListenerKey)
    }

    func jsMessageReceived(message: [String: Any]) {
        logger?.debugLog(message: "JS Message recieved",
                         data: ["message": message])

        onJSWindowEvent?(message)
    }
    
    fileprivate func getAdParams(from event: AdEvent) -> [String: Any] {
        return ["id": event.ad?.id ?? "",
                "type": event.ad?.type ?? "",
                "skipOffset": event.ad?.skipOffset ?? 0,
                "breakSize": event.ad?.adBreak?.ads.count ?? 0,
                "timeOffset": event.ad?.adBreak?.timeOffset ?? 0,
                "maxDuration": event.ad?.adBreak?.maxDuration ?? 0,
                "maxRemainingDuration": event.ad?.adBreak?.maxRemainingDuration ?? 0]
    }
}

extension CurrentTimeEvent {
    /// This function was crated to wrapp infinity bug of TheoPlayer returned to current time
    /// - Returns: -1 in case infinite value
    var getPatchedCurrentTime: Double {
        guard currentTime.isInfinite == false else {
            return 0
        }
        return currentTime
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
