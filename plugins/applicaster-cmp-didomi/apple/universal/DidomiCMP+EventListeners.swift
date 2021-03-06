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
            self.saveParamsToSessionStorageIfExists()
        }

        eventListener.onNoticeClickAgree = { _ in
            // Click on Agree in the notice
            // Request tracking permission from the user
            self.requestTrackingAuthorization { _ in
                Didomi.shared.setUserAgreeToAll()
                self.procceedWithProcessCompletion()
            }
        }

        eventListener.onNoticeClickDisagree = { _ in
            self.requestTrackingAuthorization { _ in
                self.procceedWithProcessCompletion()
            }
        }

        eventListener.onPreferencesClickSaveChoices = { _ in
            self.requestTrackingAuthorization { _ in
                self.procceedWithProcessCompletion()
            }
        }

        eventListener.onPreferencesClickDisagreeToAll = { _ in
            self.requestTrackingAuthorization { _ in
                Didomi.shared.setUserDisagreeToAll()
                self.procceedWithProcessCompletion()
            }
        }

        eventListener.onPreferencesClickAgreeToAll = { _ in
            self.requestTrackingAuthorization { _ in
                Didomi.shared.setUserAgreeToAll()
                self.procceedWithProcessCompletion()
            }
        }

        Didomi.shared.addEventListener(listener: eventListener)
    }

    func saveParamsToSessionStorageIfExists() {
        DispatchQueue.main.async {
            if let didomiGDPRApplies = UserDefaults.standard.string(forKey: Params.didomiGDPRApplies) {
                _ = FacadeConnector.connector?.storage?.sessionStorageSetValue(for: Params.didomiGDPRApplies,
                                                                               value: didomiGDPRApplies,
                                                                               namespace: Params.pluginIdentifier)
            }

            if let didomiIABConsent = UserDefaults.standard.string(forKey: Params.didomiIABConsent) {
                _ = FacadeConnector.connector?.storage?.sessionStorageSetValue(for: Params.didomiIABConsent,
                                                                               value: didomiIABConsent,
                                                                               namespace: Params.pluginIdentifier)
            }
        }
    }

    func procceedWithProcessCompletion() {
        presentationCompletion?()
        presentationCompletion = nil
    }
}
