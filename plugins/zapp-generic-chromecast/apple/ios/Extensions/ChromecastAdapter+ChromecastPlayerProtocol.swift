//
//  ChromecastAdapter+ChromecastPlayerProtocol.swift
//  ZappChromecast
//
//  Created by Alex Zchut on 4/12/2020
//  Copyright © 2020 Applicaster. All rights reserved.
//

import Foundation
import ZappCore
import GoogleCast

public let kChromecastPosterDefaultKey = "image_base"

public protocol ChromecastPlayerProtocol {
    func prepareToPlay(playableItems: [NSObject],  playPosition: TimeInterval, completion: ((_ success: Bool) -> Void)?)
}

extension ChromecastAdapter: ChromecastPlayerProtocol {
    public func prepareToPlay(playableItems: [NSObject],  playPosition: TimeInterval, completion: ((_ success: Bool) -> Void)?) {
        guard let playableItem = playableItems.first as? [String: Any] else {
            return
        }
        
        let chromecastPlayableItem = ChromecastPlayableItem(entry: playableItem)
        
        guard GCKCastContext.isSharedInstanceInitialized() else {
            return
        }

        if let remoteMediaClient = GCKCastContext.sharedInstance().sessionManager.currentCastSession?.remoteMediaClient,
            let remoteCastCurrentStreamUrl = remoteMediaClient.mediaStatus?.mediaInformation?.contentID,
            self.getContentSource(item: chromecastPlayableItem) == remoteCastCurrentStreamUrl {
            //Do noting, we already cast the this playable
            NotificationCenter.default.post(name: .chromecastStartedPlaying, object: nil)
            completion?(true)
        } else {
            if let mediaInfo = parsePlayableToGCKMediaInformation(item: chromecastPlayableItem) {
                self.mediaInfo = mediaInfo
                self.loadSelectedItem(byAppending: false, playPosition: playPosition)
                self.castDidStartMediaSession = completion
            }
        }
    }

    fileprivate func parsePlayableToGCKMediaInformation(item: ChromecastPlayableItem) -> GCKMediaInformation? {
        let contentId = getContentID(item: item)
        let contentSource = getContentSource(item: item)
        let streamType = getStreamType(item: item)
        let contentType = getContentType(item: item)
        let metadata = getGCKMediaMetadata(item: item)
        let mediaTracks = getGCKMediaTracks(item: item)
        let duration = getDuration(item: item)
        let trackStyle = getTrackStyle(item: item)

        guard let contentUrl = URL(string: contentSource) else {
            return nil
        }
        
        let mediaInfoBuilder = GCKMediaInformationBuilder(contentURL: contentUrl)
        mediaInfoBuilder.contentID = contentId
        mediaInfoBuilder.streamType = streamType
        mediaInfoBuilder.contentType = contentType
        mediaInfoBuilder.metadata = metadata
        mediaInfoBuilder.mediaTracks = mediaTracks
        mediaInfoBuilder.textTrackStyle = trackStyle
        mediaInfoBuilder.streamDuration = duration
        return mediaInfoBuilder.build()
    }

    fileprivate func getStreamType(item: ChromecastPlayableItem) -> GCKMediaStreamType {
        return (item.isLive) ? .live : .buffered
    }

    fileprivate func getGCKMediaMetadata(item: ChromecastPlayableItem) -> GCKMediaMetadata?{
        let metadata = GCKMediaMetadata(metadataType: .movie)

        //get item title
        if let title = item.title {
            metadata.setString(title, forKey: kGCKMetadataKeyTitle)
        }

        //get item description, on later cast frameworks use kMediaKeyDescription
        if let description = item.summary {
            metadata.setString(description, forKey: kGCKMetadataKeySubtitle)
        }

        //Set a Poster image
        let screenBounds = UIScreen.main.bounds
        if let chromecastPosterImageUrl = item.chromecastPosterImageUrl,
            let url = URL.init(string: chromecastPosterImageUrl) {
            metadata.addImage(GCKImage(url: url, width: Int(screenBounds.width), height: Int(screenBounds.height)))
        }
        else if let defaultImageUrl = item.defaultImageUrl,
            let url = URL.init(string: defaultImageUrl) {
            metadata.addImage(GCKImage(url: url, width: 480, height: 360))
        }
        
        //Default post URL can be set in the CMS advertising screen of the relevant app
        if let pluginPosterURL = pluginPosterURL,
            let imageBaseUrl = URL.init(string: pluginPosterURL) {
            metadata.addImage(GCKImage(url: imageBaseUrl, width: Int(screenBounds.width), height: Int(screenBounds.height)))
        }

        //Add analytics params info for analytics reasons
        if let analyticsParams = item.analytics,
            let jsonData = try? JSONSerialization.data( withJSONObject: analyticsParams, options: []),
            let jsonText = String(data: jsonData, encoding: .utf8) {

            metadata.setString(jsonText, forKey: ChromecastAnalyticsParams.playable)
        }
        
        return metadata
    }

    fileprivate func getGCKMediaTracks(item: ChromecastPlayableItem) -> [GCKMediaTrack]? {
        //This support subtitles
        return nil
    }

    fileprivate func getDuration(item: ChromecastPlayableItem) -> TimeInterval {
        if !item.isLive {
            return item.duration
        } else {
            return 0
        }
    }

    fileprivate func getContentID(item: ChromecastPlayableItem) -> String {
        return item.src ?? ""
    }
    
    fileprivate func getContentSource(item: ChromecastPlayableItem) -> String {
        return item.src ?? ""
    }

    fileprivate func getTrackStyle(item: ChromecastPlayableItem) -> GCKMediaTextTrackStyle? {
        return nil
    }

    fileprivate func getContentType(item: ChromecastPlayableItem) -> String {
        return ""
    }

    /**
     * Loads the currently selected item in the current cast media session.
     * @param appending If YES, the item is appended to the current queue if there
     * is one. If NO, or if
     * there is no queue, a new queue containing only the selected item is created.
     */
    public func loadSelectedItem(byAppending appending: Bool, playPosition:TimeInterval) {
        print("enqueue item \(String(describing: self.mediaInfo))")

        if let remoteMediaClient = GCKCastContext.sharedInstance().sessionManager.currentCastSession?.remoteMediaClient {
            let builder = GCKMediaQueueItemBuilder()
            builder.mediaInformation = self.mediaInfo
            builder.autoplay = true

            let item = builder.build()
            if ((remoteMediaClient.mediaStatus) != nil) && appending {
                let request = remoteMediaClient.queueInsert(item, beforeItemWithID: kGCKMediaQueueInvalidItemID)
                request.delegate = self
            } else {
                let repeatMode = remoteMediaClient.mediaStatus?.queueRepeatMode ?? .off
                
                let mediaQueueDataBuilder = GCKMediaQueueDataBuilder(queueType: .generic)
                mediaQueueDataBuilder.items = [item]
                mediaQueueDataBuilder.startIndex = 0
                mediaQueueDataBuilder.startTime = playPosition
                mediaQueueDataBuilder.repeatMode = repeatMode
                
                let loadRequestDataBuilder = GCKMediaLoadRequestDataBuilder()
                loadRequestDataBuilder.queueData = mediaQueueDataBuilder.build()
                
                let request = remoteMediaClient.loadMedia(with: loadRequestDataBuilder.build())

                request.delegate = self
            }
        }
    }
}

