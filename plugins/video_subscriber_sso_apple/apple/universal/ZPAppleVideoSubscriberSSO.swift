//
//  ZPAppleVideoSubscriberSSO.swift
//  ZappAppleVideoSubscriberSSO for iOS
//
//  Created by Alex Zchut on 22/03/2020.
//  Copyright © 2020 Applicaster Ltd. All rights reserved.
//

import VideoSubscriberAccount
import ZappCore

class ZPAppleVideoSubscriberSSO: NSObject {
    var playerPlugin: PlayerProtocol?
    var configurationJSON: NSDictionary?
    var model: ZPPluginModel?
    var managerInfo = VideoSubscriberAccountManagerInfo()
    var vsaAccessOperationCompletion: ((_ success: Bool) -> Void)?
    let authTokenCharacterSet = CharacterSet(charactersIn: "=\"#%/<>?@\\^`{|}")

    lazy var videoSubscriberAccountManager: VSAccountManager = {
        VSAccountManager()
    }()

    lazy var vsIsZSO: Bool = {
        var retVal = false

        guard let value = configurationJSON?["is_zso"] else {
            return retVal
        }

        // Check if value bool or string
        if let value = value as? String {
            if let valueBool = Bool(value) {
                retVal = valueBool
            } else if let valueInt = Int(value) {
                retVal = Bool(truncating: valueInt as NSNumber)
            }
        } else if let value = value as? Bool {
            retVal = value
        }

        return retVal
    }()

    lazy var vsVerificationTokenEndpoint: String? = {
        guard let endpoint = configurationJSON?["verification_token_endpoint"] as? String,
            !endpoint.isEmpty else {
            return nil
        }
        return endpoint
    }()

    lazy var vsAuthenticationEndpoint: String? = {
        guard let endpoint = configurationJSON?["authentication_endpoint"] as? String,
            !endpoint.isEmpty else {
            return nil
        }
        return endpoint
    }()

    lazy var vsAuthorizationEndpoint: String? = {
        guard let endpoint = configurationJSON?["authorization_endpoint"] as? String,
            !endpoint.isEmpty else {
            return nil
        }
        return endpoint
    }()

    lazy var vsSupportedProviderIdentifiers: [String] = {
        guard let identifier = configurationJSON?["provider_identifier"] as? String,
            !identifier.isEmpty else {
            return []
        }
        return [identifier]
    }()

    lazy var vsProviderName: String? = {
        guard let name = configurationJSON?["provider_name"] as? String,
            !name.isEmpty else {
            return nil
        }
        return name
    }()

    lazy var vsProviderChannelID: String? = {
        guard let channelID = configurationJSON?["provider_channe_id"] as? String,
            !channelID.isEmpty else {
            return nil
        }
        return channelID
    }()

    lazy var vsApplevelUserMetadataEndpoint: String? = {
        guard let endpoint = configurationJSON?["app_level_user_metadata_endpoint"] as? String,
            !endpoint.isEmpty else {
            return nil
        }
        return endpoint
    }()

    lazy var vsApplevelUserMetadataAttributes: [String] = {
        guard let attributes = configurationJSON?["app_level_user_metadata_attributes"] as? String,
            !attributes.isEmpty else {
            return []
        }
        return attributes.components(separatedBy: ",")
    }()

    required init(pluginModel: ZPPluginModel) {
        super.init()
        model = pluginModel
        configurationJSON = model?.configurationJSON

        videoSubscriberAccountManager.delegate = self
    }

    func performSsoOperation(_ completion: @escaping (_ success: Bool) -> Void) {
        vsaAccessOperationCompletion = completion

        askForAccessIfNeeded(prompt: false) { status in
            // update authorization status
            self.managerInfo.isAuthorized = status

            if self.managerInfo.isAuthorized {
                self.requestAuthenticationStatus { authResult, _ in
                    if let authResult = authResult {
                        // update authentication status
                        self.managerInfo.isAuthenticated = authResult.success
                    }
                    // continue to app level auth if device authenticated and authorized
                    if self.managerInfo.isAuthenticated && self.managerInfo.isAuthorized {
                        self.performApplevelAuthenticationIfNeeded()
                    } else {
                        self.processResult()
                    }
                }
            } else {
                self.processResult()
            }
        }
    }

    fileprivate func performApplevelAuthenticationIfNeeded() {
        // check and perform app level authentication if required
        if vsApplevelUserMetadataEndpoint?.isEmpty == false && vsApplevelUserMetadataAttributes.count > 0 {
            // reset authentication status
            managerInfo.isAuthenticated = false

            getVerificationToken { status, verificationToken, _ in
                if status, let verificationToken = verificationToken {
                    /*
                     Once the customer is authenticated to a TV provider, the next step is to request information from your service provider for the specific app using the customer’s TV provider. This information includes the verificationToken used to authenticate at the app-level and attributesNames in the metadata request. Along with this request, you are required to request at least one attribute.
                     */
                    self.requestAppLevelAuthentication(verificationToken: verificationToken) { authResult, error in
                        if error == nil {
                            self.getServiceProviderToken(for: authResult) { success, token, _ in
                                self.getServiceProviderAuthorization(for: token) { success in
                                    self.managerInfo.isAuthenticated = success
                                    self.processResult()
                                }
                            }
                        } else {
                            self.processResult()
                        }
                    }
                } else {
                    self.processResult()
                }
            }
        } else {
            processResult()
        }
    }

    fileprivate func processResult() {
        let success = managerInfo.isAuthorized && managerInfo.isAuthenticated
        DispatchQueue.main.async {
            self.vsaAccessOperationCompletion?(success)
        }
    }
}

extension ZPAppleVideoSubscriberSSO {
    // should be called to log in
    public func signIn(_ completion: ((_ success: Bool) -> Void)?) {
        performSsoOperation({ success in
            completion?(success)
        })
    }

    // should be called to check if logged in
    public func isSignedIn(_ completion: ((_ success: Bool) -> Void)?) {
        checkSignInStatus { success in
            completion?(success)
        }
    }
}
