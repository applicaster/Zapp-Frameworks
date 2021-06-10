//
//  SessionStorageIdfa.swift
//  ZappSessionStorageIdfa
//
//  Created by Alex Zchut on 24/03/2021.
//  Copyright © 2021 Applicaster Ltd. All rights reserved.
//

import AdSupport
import Foundation
import ZappCore

extension SessionStorageIdfa: AppLoadingHookProtocol {
    public func executeOnLaunch(completion: (() -> Void)?) {
        requestTrackingAuthorization { status in
            var idfaString = "00000000-0000-0000-0000-000000000000"
            switch status {
            case .authorized:
                idfaString = ASIdentifierManager.shared().advertisingIdentifier.uuidString
                break
            default:
                break
            }
            self.saveDataToStorage(idfaString)
            completion?()
        }
    }

    func saveDataToStorage(_ idfaString: String) {
        _ = FacadeConnector.connector?.storage?.sessionStorageSetValue(for: "idfa",
                                                                       value: idfaString,
                                                                       namespace: nil)

        _ = FacadeConnector.connector?.storage?.sessionStorageSetValue(for: "advertisingIdentifier",
                                                                       value: idfaString,
                                                                       namespace: nil)
    }
}
