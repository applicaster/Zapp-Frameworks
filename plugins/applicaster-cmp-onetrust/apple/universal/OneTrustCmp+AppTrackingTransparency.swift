//
//  OneTrustCmp+AppTrackingTransparency.swift
//  ZappCmpOneTrust
//
//  Created by Alex Zchut on 13/06/2021.
//  Copyright © 2021 Applicaster Ltd. All rights reserved.
//

import Foundation
#if canImport(AppTrackingTransparency)
    import AppTrackingTransparency
#endif

extension OneTrustCmp {
    public func requestTrackingAuthorization(_ completion: @escaping (OTAuthorizationStatus) -> Void) {
        if #available(iOS 14, tvOS 14, *) {
            #if canImport(AppTrackingTransparency)
                ATTrackingManager.requestTrackingAuthorization(completionHandler: { status in
                    // Tracking authorization completed. Start loading ads.
                    completion(OTAuthorizationStatus(rawValue: status.rawValue) ?? .notDetermined)
                })
            #else
                completion(.notDetermined)
            #endif
        } else {
            // prior to iOS 14, tracking identifier can be fetched without request
            completion(.authorized)
        }
    }
}
