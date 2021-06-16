//
//  OneTrustCmp+EventListeners.swift
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
import ZappCore

extension OneTrustCmp {
    func subscribeToEventListeners() {
        subscribeToEventListenerForConsentChanged()
    }

    func subscribeToEventListenerForConsentChanged() {
        OTPublishersHeadlessSDK.shared.addEventListener(self)
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

extension OneTrustCmp: OTEventListener {
    /// Conform to this method to get notified when Banner view is shown in the view hierarchy.
    public func onShowBanner() {
    }

    /// Conform to this method to get notified when Preference Center is shown in the view hierarchy.
    public func onShowPreferenceCenter() {
    }

    /// Conform to this method to get notified when Vendor List is shown in the view hierarchy.
    public func onShowVendorList() {
    }

    /// Conform to this method to get notified when Consent puurposes is shown in the view hierarchy.
    public func onShowConsentPurposesUI() {
    }

    /// Conform to this method to get notified when all the OT SDK Views are dismissed from the view hierarchy.
    /// - Parameter interactionType: The user interaction type.
    public func allSDKViewsDismissed(interactionType: OTPublishersHeadlessSDKtvOS.ConsentInteractionType) {
    }

    /// Conform to this method to get notified when user selects `Accept All` option from the banner view and the banner view gets dismissed from the view hierarchy.
    public func onBannerClickedAcceptAll() {
        // Request tracking permission from the user
        requestTrackingAuthorization { _ in
            self.procceedWithProcessCompletion()
        }
    }

    /// Conform to this method to get notified when user selects `Reject All` option from the banner view and the banner view gets dismissed from the view hierarchy.
    public func onBannerClickedRejectAll() {
        procceedWithProcessCompletion()
    }

    /// Conform to this method to get notified when user selects `Close` option from the banner view and the banner view gets dismissed from the view hierarchy.
    public func onHideBanner() {
    }

    /// Conform to this method to get notified when user selects `Accept All` option from the prefence center and the prefence center gets dismissed from the view hierarchy.
    public func onPreferenceCenterAcceptAll() {
        // Request tracking permission from the user
        requestTrackingAuthorization { _ in
            OTPublishersHeadlessSDK.shared.optIntoSaleOfData()
            self.procceedWithProcessCompletion()
        }
    }

    /// Conform to this method to get notified when user selects `Reject All` option from the prefence center and the prefence center gets dismissed from the view hierarchy.
    public func onPreferenceCenterRejectAll() {
        procceedWithProcessCompletion()
    }

    /// Conform to this method to get notified when user selects `Confirm Choices` option from the prefence center and the prefence center gets dismissed from the view hierarchy.
    public func onPreferenceCenterConfirmChoices() {
        saveParamsToSessionStorageIfExists()
    }

    /// Conform to this method to get notified when user selects `Close` option from the prefence center and the prefence center gets dismissed from the view hierarchy.
    public func onHidePreferenceCenter() {
    }

    /// Conform to this method to get notified when user selects `Confirm Choices` option from the Vendor List view and the Vendor List view gets dismissed from the view hierarchy.
    public func onVendorConfirmChoices() {
        saveParamsToSessionStorageIfExists()
    }

    /// Conform to this method to get notified when user selects `Back` button from the vendor list view and the Vendor List view gets dismissed from the view hierarchy.
    public func onHideVendorList() {
    }

    /// Conform to this method to get notified when a purpose consent has changed from Preference Center.
    public func onPreferenceCenterPurposeConsentChanged(purposeId: String, consentStatus: Int8) {
        saveParamsToSessionStorageIfExists()
    }

    /// Conform to this method to get notified when a purpose legitimate interest has changed from Preference Center.
    public func onPreferenceCenterPurposeLegitimateInterestChanged(purposeId: String, legitInterest: Int8) {
        saveParamsToSessionStorageIfExists()
    }

    /// Conform to this method to get notified when a purpose consent has changed from Vendor List View.
    public func onVendorListVendorConsentChanged(vendorId: String, consentStatus: Int8) {
        saveParamsToSessionStorageIfExists()
    }

    /// Conform to this method to get notified when a purpose legitimate interest has changed from Vendor List View.
    public func onVendorListVendorLegitimateInterestChanged(vendorId: String, legitInterest: Int8) {
        saveParamsToSessionStorageIfExists()
    }
}
