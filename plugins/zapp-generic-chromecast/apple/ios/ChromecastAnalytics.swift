//
//  ChromecastAnalytics.swift
//  ZappChromecast
//
//  Created by Alex Zchut on 4/12/2020
//  Copyright © 2020 Applicaster. All rights reserved.
//

import Foundation
import GoogleCast
import ZappCore

open class ChromecastAnalytics: NSObject {
    
    struct ChromecastEventName {
        static let IconTapped = "Tap Chromecast Icon"
        static let openExpandedControl = "Open Chromecast Expanded View"
        static let closeExpandedControl = "Close Chromecast Expanded View"
        static let startCasting = "Start Casting"
        static let stopCasting = "Stop Casting"
        static let castingError = "Chromecast Returns Error"
    }
    
    struct ChromecastEventProperties {
        static let IconLocation = "Icon location"
        static let InVideo = "In Video"
        static let VideoProperties = "Video Properties"
        static let Trigger = "Trigger"
        static let VideoTimecode = "Video Timecode"
        static let ErrorID = "Error ID"
        static let ChromecastFrameworkVersion = "Chromecast Framework Version"
        static let CustomProperties = "Custom Properties"
    }
    
    public enum controlType:String {
        case mini = "Mini View"
        case expanded = "Expanded View"
        case noting = "N/A"
    }
    
    static func getVideoPropertiesFromMetadata(for key: String) -> Dictionary<String, Any>? {
        guard GCKCastContext.isSharedInstanceInitialized() else {
            return nil
        }
        
        guard let remoteMediaClient = GCKCastContext.sharedInstance().sessionManager.currentCastSession?.remoteMediaClient,
            let metadata = remoteMediaClient.mediaStatus?.mediaInformation?.metadata,
            let playableParams = metadata.object(forKey: key) as? String,
            let dataString = playableParams.data(using: .utf8),
            let playableAnalyticsDic = try? JSONSerialization.jsonObject(with: dataString, options: []) as? Dictionary<String, Any>  else {
            return nil
        }
        
        return playableAnalyticsDic
    }
    
    static func isChromecastStreaming() -> Bool {
        
        guard GCKCastContext.isSharedInstanceInitialized(),
            let remoteMediaClient = GCKCastContext.sharedInstance().sessionManager.currentCastSession?.remoteMediaClient,
            let playerState = remoteMediaClient.mediaStatus?.playerState else {
            return false
        }
        
        return playerState == .playing || playerState == .buffering || playerState == .paused
    }
    
    static func videoTimecode() -> String? {
        
        guard GCKCastContext.isSharedInstanceInitialized(),
            let remoteMediaClient = GCKCastContext.sharedInstance().sessionManager.currentCastSession?.remoteMediaClient,
            let mediaStatus = remoteMediaClient.mediaStatus else {
            return nil
        }
        
        return stringFromTimeInterval(interval: mediaStatus.streamPosition)
    }
    
    static func stringFromTimeInterval(interval: Double) -> String {
        
        let hours = (Int(interval) / 3600)
        let minutes = Int(interval / 60) - Int(hours * 60)
        let seconds = Int(interval) - (Int(interval / 60) * 60)
        
        return String(format: "%0.2d:%0.2d:%0.2d", hours, minutes, seconds)
    }
    
    static func getViewType(triggeredChromecastButton: ChromecastButtonOrigin, isStreaming: Bool) -> controlType {
        if triggeredChromecastButton == .expendedNavbar {
            return .expanded
        } else if isStreaming {
            return .mini
        } else {
            return .noting
        }
    }
    
    static func getChromecastSDKVersion() -> String {
        return String(format: "%d.%d.%d", GCK_VERSION_MAJOR, GCK_VERSION_MINOR, GCK_VERSION_FIX)
    }
    
    // Triggered when user taps Chromecast Icon in the app
    static func sendChromecastButtonDidTappedEvent(lastActiveChromecastButton: ChromecastButtonOrigin) {
        DispatchQueue.global(qos: .background).async {
            
            var eventDictionary = [String: Any]()
            
            /* Where the icon was tapped from */
            eventDictionary[ChromecastEventProperties.IconLocation] = lastActiveChromecastButton.rawValue
            
            /* Whether or not a video is loaded (playing or paused)
             * when the user taps the Chromecast icon
             */
            let isStreaming = isChromecastStreaming()
            eventDictionary[ChromecastEventProperties.InVideo] = isStreaming
            
            /* If "In Video" = Yes, use the Video Model Dictionary to display data
             * about the video which was playing when user tapped the icon
             */
            if isChromecastStreaming() {
                eventDictionary = fillStreamingParams(to: eventDictionary, shouldAddTimeCode: false)
            }

            FacadeConnector.connector?.analytics?.sendEvent?(name: ChromecastEventName.IconTapped,
                                                             parameters: eventDictionary)
        }
    }
    
    // Triggered when user maximizes the chromecast player in the app while still casting
    static func sendOpenExpandedControlsEvent(triggeredChromecastButton: ChromecastButtonOrigin) {
        DispatchQueue.global(qos: .background).async {
            
            var eventDictionary = [String: Any]()
            
            // What the "Icon Location" was that the tap which lead to the casting came from
            eventDictionary[ChromecastEventProperties.Trigger] = triggeredChromecastButton.rawValue
            
            if isChromecastStreaming() {
                eventDictionary = fillStreamingParams(to: eventDictionary)
            }
            
            FacadeConnector.connector?.analytics?.sendEvent?(name: ChromecastEventName.openExpandedControl,
                                                             parameters: eventDictionary)
        }
    }
    
    // Triggered when user minimizes the chromecast player's expanded view in the app while still casting
    static func sendCloseExpandedControlsEvent(triggeredChromecastButton: ChromecastButtonOrigin) {
        DispatchQueue.global(qos: .background).async {
            var eventDictionary = [String: Any]()
            
            // What the "Icon Location" was that the tap which lead to the casting came from
            eventDictionary[ChromecastEventProperties.Trigger] = triggeredChromecastButton.rawValue
            
            if isChromecastStreaming() {
                eventDictionary = fillStreamingParams(to: eventDictionary)
            }
            
            FacadeConnector.connector?.analytics?.sendEvent?(name: ChromecastEventName.closeExpandedControl,
                                                             parameters: eventDictionary)
        }
    }
    
    static func fillStreamingParams(to eventDictionary: [String: Any], shouldAddTimeCode: Bool = true) -> [String: Any] {
        var retObject = eventDictionary
        
        /* If Chromecast is currenlty streaming use the Video Model Dictionary to display data
         * about the video which was playing when user tapped the icon
         */
        if let playableParams = getVideoPropertiesFromMetadata(for: ChromecastAnalyticsParams.playable) {
            retObject[ChromecastEventProperties.VideoProperties] = playableParams
        }
        
        if let customProperties = getVideoPropertiesFromMetadata(for: ChromecastAnalyticsParams.customPlayable) {
            retObject[ChromecastEventProperties.CustomProperties] = customProperties
        }
        
        /* The timecode of the content at the moment of switching view. (hh:mm:ss)
         */
        if let timeCode = videoTimecode(), shouldAddTimeCode == true {
            retObject[ChromecastEventProperties.VideoTimecode] = timeCode
        }
        
        return retObject
    }
    
    // Triggered when the casting successfully occurs
    static func sendStartCastingEvent(triggeredChromecastButton: ChromecastButtonOrigin) {
        DispatchQueue.global(qos: .background).async {
            var eventDictionary = [String: Any]()
            
            /* Whether or not a video is loaded (playing or paused)
             * when the user taps the Chromecast icon
             */
            let isStreaming = isChromecastStreaming()
            eventDictionary[ChromecastEventProperties.InVideo] = isStreaming
            
            // What the "Icon Location" was that the tap which lead to the casting came from
            eventDictionary[ChromecastEventProperties.Trigger] = triggeredChromecastButton.rawValue
            
            if isChromecastStreaming() {
                eventDictionary = fillStreamingParams(to: eventDictionary)
            }
            
            FacadeConnector.connector?.analytics?.sendEvent?(name: ChromecastEventName.startCasting,
                                                             parameters: eventDictionary)
        }
    }
    
    // Triggered when user actively cancels the casting process
    static func sendStopCastingEvent(triggeredChromecastButton: ChromecastButtonOrigin) {
        DispatchQueue.global(qos: .background).async {
            
            var eventDictionary = [String: Any]()
            
            /* Whether or not a video is loaded (playing or paused)
             * when the user taps the Chromecast icon
             */
            let isStreaming = isChromecastStreaming()
            eventDictionary[ChromecastEventProperties.InVideo] = isStreaming
            
            // What the "Icon Location" was that the tap which lead to the casting came from
            eventDictionary[ChromecastEventProperties.Trigger] = triggeredChromecastButton.rawValue
            
            if isChromecastStreaming() {
                eventDictionary = fillStreamingParams(to: eventDictionary)
            }
            
            FacadeConnector.connector?.analytics?.sendEvent?(name: ChromecastEventName.stopCasting,
                                                             parameters: eventDictionary)
        }
    }
    
    // Triggered when the casting does not occur successfully and Chromecast returns an error
    static func sendChromecastErrorReportEvent(triggeredChromecastButton: ChromecastButtonOrigin,
                                               request: GCKRequest,
                                               error: GCKError) {
        DispatchQueue.global(qos: .background).async {
            var eventDictionary = [String: Any]()
            
            // What the "Icon Location" was that the tap which lead to the casting came from
            eventDictionary[ChromecastEventProperties.Trigger] = triggeredChromecastButton.rawValue
            
            /* Whether or not a video is loaded (playing or paused)
             * when the user taps the Chromecast icon
             */
            let isStreaming = isChromecastStreaming()
            eventDictionary[ChromecastEventProperties.InVideo] = isStreaming
            
            
            if isChromecastStreaming() {
                eventDictionary = fillStreamingParams(to: eventDictionary, shouldAddTimeCode: false)
            }
            
            // Chromecast error code
            eventDictionary[ChromecastEventProperties.ErrorID] = error.code
            
            // Chromecast SDK version
            eventDictionary[ChromecastEventProperties.ChromecastFrameworkVersion] = getChromecastSDKVersion()
            FacadeConnector.connector?.analytics?.sendEvent?(name: ChromecastEventName.castingError,
                                                             parameters: eventDictionary)
        }
    }
    
}
