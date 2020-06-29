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
        guard let identifiers = configurationJSON?["provider_identifiers"] as? String,
            !identifiers.isEmpty else {
            return []
        }
        return identifiers.components(separatedBy: ",")
    }()

    lazy var vsProviderName: String? = {
        guard let identifier = configurationJSON?["provider_name"] as? String,
            !identifier.isEmpty else {
            return nil
        }
        return identifier
    }()
    
    lazy var vsProviderChannelID: String? = {
        guard let channelID = configurationJSON?["provider_channe_id"] as? String,
            !channelID.isEmpty else {
            return nil
        }
        return channelID
    }()
    

    lazy var vsApplevelAuthenticationEndpoint: String? = {
        guard let endpoint = configurationJSON?["app_level_authentication_endpoint"] as? String,
            !endpoint.isEmpty else {
            return nil
        }
        return endpoint
    }()

    lazy var vsApplevelAuthenticationAttributes: [String] = {
        guard let attributes = configurationJSON?["app_level_authentication_attributes"] as? String,
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
                    self.performApplevelAuthenticationIfNeeded()
                }
            } else {
                self.processResult()
            }
        }
    }

    fileprivate func performApplevelAuthenticationIfNeeded() {
        // check and perform app level authentication if required
        if vsApplevelAuthenticationEndpoint?.isEmpty == false && vsApplevelAuthenticationAttributes.count > 0 {
            // reset authentication status
            managerInfo.isAuthenticated = false

            getVerificationToken { status, verificationToken, _ in
                if status, let verificationToken = verificationToken {
                    /*
                     Once the customer is authenticated to a TV provider, the next step is to request information from your service provider for the specific app using the customer’s TV provider. This information includes the verificationToken used to authenticate at the app-level and attributesNames in the metadata request. Along with this request, you are required to request at least one attribute.
                     */
                    self.requestAppLevelAuthentication(verificationToken: verificationToken) { authResult, _ in
                        self.getServiceProviderToken(for: authResult) { success, token, message in
                            self.getServiceProviderAuthorization(for: token) { (success) in
                                self.managerInfo.isAuthenticated = success
                                self.processResult()
                            }
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
