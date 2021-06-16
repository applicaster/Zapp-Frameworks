//
//  OneTrustCmp+AppLoadingHookProtocol.swift
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
import XrayLogger
import ZappCore

extension OneTrustCmp: AppLoadingHookProtocol {
    public func executeOnLaunch(completion: (() -> Void)?) {
        DispatchQueue.main.async {
            guard let displayViewController = UIApplication.shared.keyWindow?.rootViewController else {
                self.logger?.infoLog(message: "Unable to present user consent")
                completion?()
                return
            }

            guard self.shouldPresentOnStartup == true else {
                self.logger?.infoLog(message: "User consent presentOnStartup is disabled")
                completion?()
                return
            }

            switch self.cmpStatus {
            case .undefined:
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    self.executeOnLaunch(completion: completion)
                }
            case .ready:
                guard OTPublishersHeadlessSDK.shared.shouldShowBanner() else {
                    completion?()
                    return
                }

                self.presentationCompletion = completion
                OTPublishersHeadlessSDK.shared.setupUI(displayViewController, UIType: .banner)
                OTPublishersHeadlessSDK.shared.showBannerUI()
            case .error:
                completion?()
            }
        }
    }

    public func executeAfterAppRootPresentation(displayViewController: UIViewController?, completion: (() -> Void)?) {
        saveParamsToSessionStorageIfExists()

        DispatchQueue.main.async {
            if let rootController = UIApplication.shared.keyWindow?.rootViewController {
                OTPublishersHeadlessSDK.shared.setupUI(rootController)
            }
        }

        completion?()
    }
}
