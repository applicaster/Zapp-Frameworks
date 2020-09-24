//
//  GoogleInteractiveMediaAdsAdapterTrackingIdentifier.swift
//  GoogleInteractiveMediaAds
//
//  Created by Alex Zchut on 02/09/2020.
//  Copyright (c) 2020 Applicaster. All rights reserved.
//

import Foundation

#if canImport(AppTrackingTransparency)
import AppTrackingTransparency
#endif

@objc public class GoogleInteractiveMediaAdsAdapterTrackingIdentifier: NSObject {

    @objc static public func requestTrackingAuthorization(_ completion: @escaping () -> Void) {

        if #available(iOS 14, tvOS 14, *) {
            #if canImport(AppTrackingTransparency)
            ATTrackingManager.requestTrackingAuthorization(completionHandler: { status in
                // Tracking authorization completed. Start loading ads.
                completion()
            })
            #else
            completion()
            #endif
        } else {
            completion()
        }
    }
}
