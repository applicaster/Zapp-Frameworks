//
//  DidomiCMP+EventListeners.swift
//  ZappCMPDidomi
//
//  Created by Alex Zchut on 29/03/2021.
//  Copyright © 2021 Applicaster Ltd. All rights reserved.
//

import Didomi
import Foundation
import ZappCore

extension DidomiCMP {
    func subscribeToEventListeners() {
        subscribeToEventListenerToRequestTrackingAuthorizationWhenNeeded()
        subscribeToEventListenerForConsentChanged()
    }

    func subscribeToEventListenerForConsentChanged() {
        let eventListener = EventListener()
        eventListener.onConsentChanged = { _ in
            _ = FacadeConnector.connector?.storage?.localStorageSetValue(for: Params.jsPreferencesKey,
                                                                         value: Didomi.shared.getJavaScriptForWebView(),
                                                                         namespace: Params.pluginIdentifier)
        }

        Didomi.shared.addEventListener(listener: eventListener)
    }

    func subscribeToEventListenerToRequestTrackingAuthorizationWhenNeeded() {
        let eventListener = EventListener()

        eventListener.onConsentChanged = { _ in
            self.saveParamsToSessionStorage()
        }

        eventListener.onNoticeClickAgree = { _ in
            // Click on Agree in the notice
            // Request tracking permission from the user
            self.requestTrackingAuthorization { status in
                switch status {
                case .authorized:
                    Didomi.shared.setUserAgreeToAll()
                case .denied:
                    Didomi.shared.setUserDisagreeToAll()
                case .restricted:
                    Didomi.shared.setUserDisagreeToAll()
                case .notDetermined:
                    break
                }
                self.saveParamsToSessionStorage()
            }
        }

        eventListener.onPreferencesClickAgreeToAll = { _ in
            // Click on Agree to all in the Preferences popup
            // Request tracking permission from the user
            self.requestTrackingAuthorization { status in
                switch status {
                case .authorized:
                    Didomi.shared.setUserAgreeToAll()
                case .denied:
                    Didomi.shared.setUserDisagreeToAll()
                case .restricted:
                    Didomi.shared.setUserDisagreeToAll()
                case .notDetermined:
                    break
                }
                self.saveParamsToSessionStorage()
            }
        }

        Didomi.shared.addEventListener(listener: eventListener)
    }

    func saveParamsToSessionStorage() {
        if let didomiGDPRApplies = UserDefaults.standard.string(forKey: "IABConsent_SubjectToGDPR") {
            _ = FacadeConnector.connector?.storage?.sessionStorageSetValue(for: Params.didomiGDPRApplies,
                                                                           value: didomiGDPRApplies,
                                                                           namespace: Params.pluginIdentifier)
        }

        if let didomiIABConsent = UserDefaults.standard.string(forKey: "IABConsent_ConsentString") {
            _ = FacadeConnector.connector?.storage?.sessionStorageSetValue(for: Params.didomiIABConsent,
                                                                           value: didomiIABConsent,
                                                                           namespace: Params.pluginIdentifier)
        }
    }
}
