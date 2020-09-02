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
import AdSupport

@objc public class GoogleInteractiveMediaAdsAdapterTrackingIdentifier: NSObject {
    static let defaultIdentifier = "00000000-0000-0000-0000-000000000000"

    @objc static public func requestTrackingAuthorization(_ completion: @escaping (_ identifier: String) -> Void) {

        if #available(iOS 14, tvOS 14, *) {
            #if canImport(AppTrackingTransparency)
            ATTrackingManager.requestTrackingAuthorization(completionHandler: { status in
                // Tracking authorization completed. Start loading ads.
                var identifier = self.defaultIdentifier
                if (status == .authorized) {
                    identifier = self.getAdvertisingIdentifierValue()
                }
                completion(identifier)
            })
            #else
            completion(self.getAdvertisingIdentifierValue())
            #endif
        } else {
            completion(self.getAdvertisingIdentifierValue())
        }
    }
    
    static func getAdvertisingIdentifierValue() -> String {
        var identifier = ASIdentifierManager.shared().advertisingIdentifier.uuidString
        if identifier.isEmpty {
            identifier = defaultIdentifier
        }
        
        return identifier
    }
}
