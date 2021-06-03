//
//  SessionStorageIdfa.swift
//  ZappSessionStorageIdfa
//
//  Created by Alex Zchut on 24/03/2021.
//  Copyright © 2021 Applicaster Ltd. All rights reserved.
//

import AdSupport
import Foundation
import ZappPlugins

extension SessionStorageIdfa: ZPAppLoadingHookProtocol {
    @objc open func executeOnLaunch(completion: (() -> Void)?) {
        requestTrackingAuthorization { status in
            switch status {
            case .authorized:
                self.saveDataToStorage()
                break
            default:
                break
            }
            completion?()
        }
    }

    func saveDataToStorage() {
        let idfaString = ASIdentifierManager.shared().advertisingIdentifier.uuidString

        _ = ZAAppConnector.sharedInstance().storageDelegate?.sessionStorageSetValue(for: "idfa",
                                                                                    value: idfaString,
                                                                                    namespace: nil)

        _ = ZAAppConnector.sharedInstance().storageDelegate?.sessionStorageSetValue(for: "advertisingIdentifier",
                                                                                    value: idfaString,
                                                                                    namespace: nil)
    }
}
