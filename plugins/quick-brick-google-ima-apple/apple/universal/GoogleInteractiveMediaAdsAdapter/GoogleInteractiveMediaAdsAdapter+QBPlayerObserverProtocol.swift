//
//  GoogleInteractiveMediaAdsAdapter+QBPlayerObserverProtocol.swift
//  GoogleInteractiveMediaAdsTvOS
//
//  Created by Anton Kononenko on 7/25/19.
//  Copyright © 2019 Anton Kononenko. All rights reserved.
//

import Foundation
import ZappCore

extension GoogleInteractiveMediaAdsAdapter: PlayerObserverProtocol {
    public func playerDidFinishPlayItem(player: PlayerProtocol,
                                        completion: @escaping (_ finished: Bool) -> Void) {
        adsLoader?.contentComplete()
        handlePlayerFinish(completion: completion)
        Timer.scheduledTimer(withTimeInterval: 1,
                             repeats: false) { [weak self] _ in
            if ((self?.postrollCompletion) != nil) && self?.adsManager == nil {
                self?.postrollCompletion?(true)
                self?.postrollCompletion = nil
            }
        }
    }

    private func handlePlayerFinish(completion: @escaping (_ finished: Bool) -> Void) {
        guard let urlTagData = urlTagData else {
            return
        }
        if urlTagData.isVmapAd {
            if isVMAPAdsCompleted {
                completion(true)
                return
            }
            postrollCompletion = completion
        } else {
            guard let postrollUrl = urlTagData.postrollUrlString() else {
                completion(true)
                return
            }
            postrollCompletion = completion
            requestAd(adUrl: postrollUrl)
        }
    }
    
    public func playerProgressUpdate(player: PlayerProtocol,
                                     currentTime: TimeInterval,
                                     duration: TimeInterval) {
        if let currentVideoTime = playerPlugin?.playbackPosition(),
            let url = urlTagData?.requestMiddroll(currentVideoTime: currentVideoTime) {
            requestAd(adUrl: url)
        }
    }

    public func playerDidDismiss(player: PlayerProtocol) {
        avPlayer?.removeObserver(self, forKeyPath: MediaAdsConstants.playerPlaybackRate)
        playerPlugin = nil
        adsLoader?.delegate = nil
        adsLoader = nil
        contentPlayhead = nil
        adsManager?.delegate = nil
        adsManager = nil
        adRequest = nil
    }

    public func playerDidCreate(player: PlayerProtocol) {
        prepareGoogleIMA()
    }
}
