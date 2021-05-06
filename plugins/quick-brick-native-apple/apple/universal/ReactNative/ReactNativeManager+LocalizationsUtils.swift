//
//  ReactNativeManager+LocalizationsUtils.swift
//  QuickBrickApple
//
//  Created by François Roland on 23/09/2020.
//  Updated by Alex Zchut on 02/05/2021
//

import Foundation
import React
import ZappCore

extension ReactNativeManager {
    public func setRightToLeftFlag(completion: @escaping () -> Void) {
        if let localeToUse = FacadeConnector.connector?.storage?.sessionStorageValue(for: "languageCode", namespace: nil) {
            self.setRTL(RTLLocales.includes(locale: localeToUse))
        }
        completion()
    }
    
    private func setRTL(_ isRTL: Bool) {
        if let reactI18Util = RCTI18nUtil.sharedInstance() {
            reactI18Util.allowRTL(isRTL)
            reactI18Util.forceRTL(isRTL)
        }
    }
}
