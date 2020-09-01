//
//  GoogleInteractiveMediaAdsAdapter+IMAAdsManagerDelegate.swift
//  GoogleInteractiveMediaAdsTvOS
//
//  Created by Anton Kononenko on 7/25/19.
//  Copyright © 2019 Anton Kononenko. All rights reserved.
//

import AVFoundation
import Foundation
import GoogleInteractiveMediaAds
import ZappCore

extension GoogleInteractiveMediaAdsAdapter: IMAAdsManagerDelegate {
    var delegate: DependablePlayerAdDelegatePluginProtocol? {
        return playerPlugin as? DependablePlayerAdDelegatePluginProtocol
    }

    public func adsManager(_ adsManager: IMAAdsManager?, didReceive event: IMAAdEvent?) {
        switch event?.type {
        case .LOADED:
            adsManager?.start()
            isPrerollAdLoading = false
        case .ALL_ADS_COMPLETED:
            if let urlTagData = urlTagData, urlTagData.isVmapAd {
                isVMAPAdsCompleted = true
            }
            postrollCompletion?(true)
        case .SKIPPED:
            if let playerPlugin = playerPlugin {
                FacadeConnector.connector?.playerDependant?.playerAdSkiped(player: playerPlugin)
            }
        default:
            return
        }
    }

    public func adsManagerDidRequestContentPause(_ adsManager: IMAAdsManager!) {
        delegate?.advertisementWillPresented(provider: self)
        if let playerPlugin = playerPlugin {
            FacadeConnector.connector?.playerDependant?.playerAdStarted(player: playerPlugin)
        }
        // The SDK is going to play ads, so pause the content.
        pausePlayback()
    }

    public func adsManager(_ adsManager: IMAAdsManager!, didReceive error: IMAAdError!) {
        delegate?.advertisementFailedToLoad(provider: self)
        // Something went wrong with the ads manager after ads were loaded. Log the error and play the
        // content.
        isPrerollAdLoading = false
        if let completion = postrollCompletion {
            completion(true)
            postrollCompletion = nil
            adsLoader?.contentComplete()
        } else {
            resumePlayback()
        }
    }

    public func adsManagerDidRequestContentResume(_ adsManager: IMAAdsManager!) {
        delegate?.advertisementWillDismissed(provider: self)
        if let playerPlugin = playerPlugin {
            FacadeConnector.connector?.playerDependant?.playerAdCompleted(player: playerPlugin)
        }
        // The SDK is done playing ads (at least for now), so resume the content.
        resumePlayback()
    }
    
    public func adsManager(_ adsManager: IMAAdsManager!, adDidProgressToTime mediaTime: TimeInterval, totalTime: TimeInterval) {
        if let playerPlugin = playerPlugin {
            FacadeConnector.connector?.playerDependant?.playerAdProgressUpdate(player: playerPlugin, currentTime: mediaTime, duration: totalTime)
        }
    }
    
}
