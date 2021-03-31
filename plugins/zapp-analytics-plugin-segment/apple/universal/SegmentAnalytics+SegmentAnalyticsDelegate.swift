//
//  SegmentAnalytics+SegmentAnalyticsDelegate.swift
//  SegmentAnalytics
//
//  Created by Alex Zchut on 10/03/2021.
//  Copyright © 2021 Applicaster Ltd. All rights reserved.
//

import AVFoundation
import Foundation
import ZappCore

extension SegmentAnalytics: SegmentAnalyticsDelegate {
    public func isDebug() -> Bool {
        guard let value = FacadeConnector.connector?.storage?.sessionStorageValue(for: "application_environment", namespace: nil) else {
            return false
        }

        return Bool(value) ?? false
    }

    public func getDeviceID() -> String? {
        return FacadeConnector.connector?.storage?.sessionStorageValue(for: "uuid", namespace: nil) ?? ""
    }

    public func getCurrentPlayedItemEntry() -> [AnyHashable: Any]? {
        return playerPlugin?.entry ?? [:]
    }

    public func getCurrentPlayerInstance() -> AVPlayer? {
        return avPlayer
    }
}
