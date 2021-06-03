//
//  SessionStorageIdfa.swift
//  ZappSessionStorageIdfa
//
//  Created by Alex Zchut on 24/03/2021.
//  Copyright © 2021 Applicaster Ltd. All rights reserved.
//


import Foundation

#if canImport(AppTrackingTransparency)
    import AppTrackingTransparency
#endif

extension SessionStorageIdfa {
    public enum AuthorizationStatus: UInt {
        case notDetermined = 0
        case restricted = 1
        case denied = 2
        case authorized = 3
    }
    
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

