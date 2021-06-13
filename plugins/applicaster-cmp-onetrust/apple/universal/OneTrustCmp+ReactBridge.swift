//
//  OneTrustCmp+ReactBridge.swift
//  ZappCmpOneTrust
//
//  Created by Alex Zchut on 13/06/2021.
//  Copyright © 2021 Applicaster Ltd. All rights reserved.
//

#if os(tvOS) && canImport(OTPublishersHeadlessSDKtvOS)
    import OTPublishersHeadlessSDKtvOS
#elseif os(iOS) && canImport(OTPublishersHeadlessSDK)
    import OTPublishersHeadlessSDK
#endif

import Foundation

extension OneTrustCmp {
    public func showPreferences() -> (success: Bool, errorDescription: String?) {
        guard cmpStatus == .ready else {
            return (false, "OneTrust is not ready")
        }

        OTPublishersHeadlessSDK.shared.showPreferenceCenterUI()

        return (true, nil)
    }

    public func showNotice() -> (success: Bool, errorDescription: String?) {
        guard cmpStatus == .ready else {
            return (false, "OneTrust is not ready")
        }

        OTPublishersHeadlessSDK.shared.showBannerUI()

        return (true, nil)
    }
}
