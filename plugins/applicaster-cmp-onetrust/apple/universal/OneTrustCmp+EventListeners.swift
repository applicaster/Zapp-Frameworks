//
//  OneTrustCmp+EventListeners.swift
//  ZappCmpOneTrust
//
//  Created by Alex Zchut on 13/06/2021.
//  Copyright © 2021 Applicaster Ltd. All rights reserved.
//

import OneTrust
import Foundation
import ZappCore

extension OneTrustCmp {
    func subscribeToEventListeners() {
        subscribeToEventListenerToRequestTrackingAuthorizationWhenNeeded()
        subscribeToEventListenerForConsentChanged()
    }

    func subscribeToEventListenerForConsentChanged() {
        let eventListener = EventListener()
        eventListener.onConsentChanged = { _ in
            _ = FacadeConnector.connector?.storage?.localStorageSetValue(for: Params.jsPreferencesKey,
                                                                         value: OneTrust.shared.getJavaScriptForWebView(),
                                                                         namespace: Params.pluginIdentifier)
        }

        OneTrust.shared.addEventListener(listener: eventListener)
    }

    func subscribeToEventListenerToRequestTrackingAuthorizationWhenNeeded() {
        let eventListener = EventListener()

        eventListener.onConsentChanged = { _ in
            self.saveParamsToSessionStorageIfExists()
        }

        eventListener.onNoticeClickAgree = { _ in
            // Click on Agree in the notice
            // Request tracking permission from the user
            self.requestTrackingAuthorization { _ in
                OneTrust.shared.setUserAgreeToAll()
                self.procceedWithProcessCompletion()
            }
        }

        eventListener.onNoticeClickDisagree = { _ in
            self.procceedWithProcessCompletion()
        }

        eventListener.onPreferencesClickAgreeToAll = { _ in
            // Click on Agree to all in the Preferences popup
            // Request tracking permission from the user
            self.requestTrackingAuthorization { _ in
                OneTrust.shared.setUserAgreeToAll()
            }
        }

        OneTrust.shared.addEventListener(listener: eventListener)
    }

    func saveParamsToSessionStorageIfExists() {
        DispatchQueue.main.async {
            if let onetrustGDPRApplies = UserDefaults.standard.string(forKey: Params.onetrustGDPRApplies) {
                _ = FacadeConnector.connector?.storage?.sessionStorageSetValue(for: Params.onetrustGDPRApplies,
                                                                               value: onetrustGDPRApplies,
                                                                               namespace: Params.pluginIdentifier)
            }

            if let onetrustIABConsent = UserDefaults.standard.string(forKey: Params.onetrustIABConsent) {
                _ = FacadeConnector.connector?.storage?.sessionStorageSetValue(for: Params.onetrustIABConsent,
                                                                               value: onetrustIABConsent,
                                                                               namespace: Params.pluginIdentifier)
            }
        }
    }

    func procceedWithProcessCompletion() {
        presentationCompletion?()
        presentationCompletion = nil
    }
}
