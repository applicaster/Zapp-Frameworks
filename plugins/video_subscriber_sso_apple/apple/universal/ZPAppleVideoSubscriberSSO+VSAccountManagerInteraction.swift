//
//  ZPAppleVideoSubscriberSSO+VSAccountManagerInteraction.swift
//  ZappAppleVideoSubscriberSSO
//
//  Created by Alex Zchut on 20/03/2020.
//  Copyright © 2020 Applicaster Ltd. All rights reserved.
//

import VideoSubscriberAccount

struct VideoSubscriberAccountManagerInfo {
    var isAuthorized: Bool = false // do we have access to the framework?
    var isAuthenticated: Bool = false // are we logged in?
}

struct VideoSubscriberAccountManagerResult {
    var accountProviderID: String?
    var authExpirationDate: Date?
    var verificationData: Data?
    var samlAttributeQueryResponse: String?
    var accountProviderResponseBody: String?

    static func createFromMetadata(_ metadata: VSAccountMetadata) -> VideoSubscriberAccountManagerResult {
        var result = VideoSubscriberAccountManagerResult()

        result.accountProviderID = metadata.accountProviderIdentifier
        result.authExpirationDate = metadata.authenticationExpirationDate
        result.verificationData = metadata.verificationData
        result.samlAttributeQueryResponse = metadata.samlAttributeQueryResponse
        result.accountProviderResponseBody = metadata.accountProviderResponse?.body

        return result
    }

    var success: Bool {
        guard let _ = accountProviderID,
            let authExpirationDate = authExpirationDate, authExpirationDate > Date(),
            let _ = verificationData else {
            return false
        }
        return true
    }
}

extension ZPAppleVideoSubscriberSSO {
    func askForAccessIfNeeded(prompt: Bool, _ completion: @escaping (_ result: Bool) -> Void) {
        videoSubscriberAccountManager.checkAccessStatus(options: [VSCheckAccessOption.prompt: NSNumber(booleanLiteral: prompt)]) { status, _ in
            if prompt {
                DispatchQueue.main.async {
                    completion(status == .granted)
                }
            } else {
                if status != .granted {
                    self.askForAccessIfNeeded(prompt: true, completion)
                } else {
                    DispatchQueue.main.async {
                        completion(status == .granted)
                    }
                }
            }
        }
    }

    func requestAuthenticationStatus(interrruption: Bool = false, completion: @escaping (_ result: VideoSubscriberAccountManagerResult?, _ error: VSError?) -> Void) {
        let request = VSAccountMetadataRequest()
        request.includeAccountProviderIdentifier = true
        request.includeAuthenticationExpirationDate = true
        request.isInterruptionAllowed = interrruption
        if interrruption {
            /*
             When requesting authentication, you should set the supportedAccountProviderIdentifiers property to a list of TV providers supported by your application. This limits the TV providers presented to the customer and establishes the order in which they will be displayed.
             */
            request.supportedAccountProviderIdentifiers = vsSupportedProviderIdentifiers
        }

        videoSubscriberAccountManager.enqueue(request) { userMetadata, error in
            if let data = userMetadata {
                DispatchQueue.main.async {
                    completion(VideoSubscriberAccountManagerResult.createFromMetadata(data), error as? VSError)
                }
            } else {
                if interrruption == false {
                    /*
                     If the customer has not authenticated with a TV provider yet and authentication is required because of a user action, device authentication can be requested. The key differentiator between requesting device authentication status and requesting device authentication is that interruption is allowed for authentication.
                     */
                    self.requestAuthenticationStatus(interrruption: true, completion: completion)
                } else {
                    DispatchQueue.main.async {
                        completion(nil, error as? VSError)
                    }
                }
            }
        }
    }

    func requestAppLevelAuthentication(verificationToken: String, _ completion: @escaping (_ result: VideoSubscriberAccountManagerResult?, _ error: VSError?) -> Void) {
        let request = VSAccountMetadataRequest()
        request.includeAccountProviderIdentifier = true
        request.includeAuthenticationExpirationDate = true
        request.isInterruptionAllowed = true
        request.verificationToken = verificationToken
        request.channelIdentifier = vsApplevelAuthenticationEndpoint
        request.attributeNames = vsApplevelAuthenticationAttributes
        request.supportedAuthenticationSchemes = [VSAccountProviderAuthenticationScheme(rawValue: "OAuth")]

        videoSubscriberAccountManager.enqueue(request) { userMetadata, error in
            if let data = userMetadata {
                DispatchQueue.main.async {
                    completion(VideoSubscriberAccountManagerResult.createFromMetadata(data), error as? VSError)
                }
            } else {
                DispatchQueue.main.async {
                    completion(nil, error as? VSError)
                }
            }
        }
    }

    func getVerificationToken(_ completion: @escaping (_ status: Bool, _ verificationToken: String?, _ message: String?) -> Swift.Void) {
        guard let providerName = self.vsProviderName?.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed),
            let endpointForVerificationToken = self.vsVerificationTokenEndpoint else {
            completion(false, nil, nil)
            return
        }

        let urlString = endpointForVerificationToken + providerName
        guard let url = URL(string: urlString) else {
            completion(false, nil, nil)
            return
        }

        let sessionTask = URLSession.shared.dataTask(with: url, completionHandler: { data, response, error in
            var token: String?
            var status: Bool = false
            var message: String?

            if let error = error {
                message = error.localizedDescription
            }

            let httpResponse = response as? HTTPURLResponse

            if httpResponse?.statusCode == 200,
                let data = data {
                token = String(bytes: data, encoding: String.Encoding.utf8)
                status = true
            } else {
                if response != nil {
                    message = "HTTP Error Code: " + (httpResponse?.statusCode.description ?? "") + " " + HTTPURLResponse.localizedString(forStatusCode: (httpResponse?.statusCode)!)
                } else {
                    message = "SP Server is unreachable"
                }
            }

            completion(status, token, message)
        })

        sessionTask.resume()
    }

    func getServiceProviderToken(for authResult: VideoSubscriberAccountManagerResult?, completion: @escaping (_ success: Bool, _ token: String?, _ message: String?) -> Void) {
        guard let postString = authResult?.samlAttributeQueryResponse,
            let urlString = self.vsAuthenticationEndpoint,
            let url = URL(string: urlString) else {
            completion(false, nil, nil)
            return
        }

        var token: String?
        var status: Bool = false
        var message: String?

        var request = URLRequest(url: url)

        request.httpMethod = "POST"
        request.httpBody = "response=\(postString)".data(using: String.Encoding.utf8)

        let tokenSession = URLSession.shared.dataTask(with: request) { data, _, error in

            if error != nil {
                message = "Error: \(String(describing: error?.localizedDescription))"
            } else {
                let jsonResponse: Dictionary<String, AnyObject>
                do {
                    jsonResponse = try JSONSerialization.jsonObject(with: data!, options: .allowFragments) as! Dictionary
                    if let authToken = jsonResponse["authN"] as? String {
                        token = authToken
                        status = true
                    }
                } catch {
                    message = "Error parsing JSON Response"
                }
            }

            completion(status, token, message)
        }

        tokenSession.resume()
    }
    
    func getServiceProviderAuthorization(for authenticationToken: String?, completion: @escaping (_ success: Bool) -> Void) {
        guard let authToken = authenticationToken?.addingPercentEncoding(withAllowedCharacters: self.authTokenCharacterSet),
            let channelID = self.vsProviderChannelID,
            let authorizationEndpoint = self.vsAuthorizationEndpoint,
            let url = URL(string: authorizationEndpoint) else {
                completion(false)
            return
        }
        let postBody = ("authToken=\(authToken)&channelID=\(channelID)")

        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "POST"
        urlRequest.httpBody = postBody.data(using: String.Encoding.utf8)
        
        let sessionTask = URLSession.shared.dataTask(with:urlRequest, completionHandler: { (data, response, error) in
            if let err = error {
                print("Error: " + err.localizedDescription)
            }
            
            var isAuthed : String = "false"
            let jsonResponse : Dictionary<String,AnyObject>
            do {
                jsonResponse = try JSONSerialization.jsonObject(with: data!, options: .allowFragments) as! Dictionary
                if let authed = jsonResponse["authZ"] as? String {
                    isAuthed = authed
                }
            } catch {
                print("Error parsing JSON Response")
            }
            
            if(isAuthed == "true"){
                completion(true)
            }else{
                completion(false)
            }
        })
        
        sessionTask.resume()
    }
}
