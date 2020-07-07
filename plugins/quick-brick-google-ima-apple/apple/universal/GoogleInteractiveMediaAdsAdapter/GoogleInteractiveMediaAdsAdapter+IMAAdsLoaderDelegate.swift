//
//  GoogleInteractiveMediaAdsAdapter+IMAAdsLoaderDelegate.swift
//  GoogleInteractiveMediaAdsTvOS
//
//  Created by Anton Kononenko on 7/25/19.
//  Copyright © 2019 Anton Kononenko. All rights reserved.
//

import AVFoundation
import Foundation
import GoogleInteractiveMediaAds

// MARK: - IMAAdsLoaderDelegate

extension GoogleInteractiveMediaAdsAdapter: IMAAdsLoaderDelegate {
    public func adsLoader(_ loader: IMAAdsLoader?, adsLoadedWith adsLoadedData: IMAAdsLoadedData!) {
        // Grab the instance of the IMAAdsManager and set ourselves as the delegate.

        adsManager = adsLoadedData.adsManager
        adsManager?.delegate = self

        if let playerViewController = playerPlugin?.pluginPlayerViewController {
            // Create ads rendering settings and tell the SDK to use the in-app browser.
            let adsRenderingSettings = IMAAdsRenderingSettings()
            adsRenderingSettings.webOpenerPresentingController = playerViewController

            // Initialize the ads manager.
            adsManager?.initialize(with: adsRenderingSettings)
        }
    }

    public func adsLoader(_ loader: IMAAdsLoader!, failedWith adErrorData: IMAAdLoadingErrorData!) {
        let errorMessage = String(describing: adErrorData.adError.message)
        let errorCode = adErrorData.adError.code.rawValue
        let errorType = adErrorData.adError.type.rawValue
        debugPrint("Error loading ads: \(errorMessage), \(errorCode), \(errorType)")
        isPrerollAdLoading = false
        if let completion = postrollCompletion {
            completion(true)
            postrollCompletion = nil
            adsLoader?.contentComplete()
        } else {
            resumePlayback()
        }
    }
}
