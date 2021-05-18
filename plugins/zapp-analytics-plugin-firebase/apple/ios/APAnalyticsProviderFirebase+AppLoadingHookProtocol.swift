//
//  APAnalyticsProviderFirebase+AppLoadingHookProtocol.swift
//  ZappAnalyticsPluginFirebase
//
//  Created by Alex Zchut on 24/03/2021.
//  Copyright © 2021 Applicaster Ltd. All rights reserved.
//

import Foundation
import ZappCore

extension APAnalyticsProviderFirebase: AppLoadingHookProtocol {
    public func executeAfterAppRootPresentation(displayViewController: UIViewController?, completion: (() -> Void)?) {
        requestTrackingAuthorization { status in

            switch status {
            case .authorized:
                // do something after getting access to idfa if needed
                break
            default:
                break
            }
            completion?()
        }
    }
}
