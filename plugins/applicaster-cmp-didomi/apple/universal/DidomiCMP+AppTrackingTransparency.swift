//
//  DidomiCMP+AppTrackingTransparency.swift
//  ZappCMPDidomi
//
//  Created by Alex Zchut on 24/03/2021.
//

import Foundation

#if canImport(AppTrackingTransparency)
    import AppTrackingTransparency
#endif

extension DidomiCMP {
    public func requestTrackingAuthorization(_ completion: @escaping (AuthorizationStatus) -> Void) {
        if #available(iOS 14, tvOS 14, *) {
            #if canImport(AppTrackingTransparency)
                ATTrackingManager.requestTrackingAuthorization(completionHandler: { status in
                    // Tracking authorization completed. Start loading ads.
                    completion(AuthorizationStatus(rawValue: status.rawValue) ?? .notDetermined)
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
