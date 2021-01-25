/*
 Copyright (C) 2017 Apple Inc. All Rights Reserved.
 See LICENSE.txt for this sample’s licensing information

 Abstract:
 `ContentKeyDelegate` is a class that implements the `AVContentKeySessionDelegate` protocol to respond to content key
 requests using FairPlay Streaming.
 */

//  Adopted by Alex Zchut for plugin usage on 21/01/2021.

import AVFoundation
import XrayLogger
import ZappCore

typealias ContentKeyToRequestCompletion = (_ isReady: Bool) -> Void

class ContentKeyDelegate: NSObject, AVContentKeySessionDelegate {
    // MARK: Types

    enum ProcessError: Error {
        case missingApplicationCertificate
        case missingLicenseServerUrl
        case noCKCReturnedByKSM
        case failedToRetrieveContentId
    }

    // MARK: Properties

    /// A set containing the currently pending content key identifiers associated with persistable content key requests that have not been completed.
    var pendingPersistableContentKeyIdentifiers = Set<String>()
    /// A dictionary mapping content key identifiers to comletions.
    var contentKeyToRequestCompletionsMap = [String: [ContentKeyToRequestCompletion?]]()

    var contentKeyRequestParams: ContentKeyRequestParams?
    var contentKeyStorageNamespace: String?
    var logger: Logger?

    func requestApplicationCertificate() throws -> Data {
        guard let certificateUrlString = contentKeyRequestParams?.certificateUrlString,
              let certificateUrl = URL(string: certificateUrlString),
              let certificateData = try? Data(contentsOf: certificateUrl) else {
            throw ProcessError.missingApplicationCertificate
        }

        return certificateData
    }

    func requestContentKeyFromKeySecurityModule(spcData: Data, assetID: String) throws -> Data {
        guard let licenseServerUrlString = contentKeyRequestParams?.licenseServerUrlString,
              let licenseServerUrl = URL(string: licenseServerUrlString) else {
            throw ProcessError.missingLicenseServerUrl
        }

        let semaphore: DispatchSemaphore = DispatchSemaphore(value: 0)
        var retValue: Data?
        var request = URLRequest(url: licenseServerUrl)
        request.httpMethod = "POST"

        if let customContentType = contentKeyRequestParams?.licenseServerRequestContentType {
            request.setValue(customContentType, forHTTPHeaderField: "Content-Type")
            request.setValue(customContentType, forHTTPHeaderField: "Accept")
        }

        if let customJsonKeyForData = contentKeyRequestParams?.licenseServerRequestJsonObjectKey {
            let dict = [customJsonKeyForData: spcData]
            request.httpBody = try! JSONEncoder().encode(dict)
        } else {
            request.httpBody = spcData
        }
        let session = URLSession(configuration: .default)
        let task = session.dataTask(with: request) { data, _, _ in
            if let data = data {
                retValue = data
            }
            semaphore.signal()
        }
        task.resume()
        semaphore.wait()

        guard let data = retValue else {
            throw ProcessError.noCKCReturnedByKSM
        }
        return data
    }

    /// Preloads all the content keys associated with an Asset for persisting on disk.
    ///
    /// It is recommended you use AVContentKeySession to initiate the key loading process
    /// for online keys too. Key loading time can be a significant portion of your playback
    /// startup time because applications normally load keys when they receive an on-demand
    /// key request. You can improve the playback startup experience for your users if you
    /// load keys even before the user has picked something to play. AVContentKeySession allows
    /// you to initiate a key loading process and then use the key request you get to load the
    /// keys independent of the playback session. This is called key preloading. After loading
    /// the keys you can request playback, so during playback you don't have to load any keys,
    /// and the playback decryption can start immediately.
    ///
    /// - Parameter asset: The `Asset` to preload keys for.
    func requestPersistableContentKeys(for contentKeyRequestParams: ContentKeyRequestParams, completion: ContentKeyToRequestCompletion?) {
        guard let contentKeyUrlString = contentKeyRequestParams.contentKeyUrlString,
              let assetIDString = host(fromUrlString: contentKeyUrlString) else {
            completion?(false)
            return
        }

        pendingPersistableContentKeyIdentifiers.insert(assetIDString)

        let currentCompletions = contentKeyToRequestCompletionsMap[assetIDString]
        var updatedCompletions = currentCompletions
        if updatedCompletions == nil {
            updatedCompletions = [ContentKeyToRequestCompletion]()
        }
        updatedCompletions?.append(completion)
        contentKeyToRequestCompletionsMap[assetIDString] = updatedCompletions

        ContentKeyManager.shared.contentKeySession.processContentKeyRequest(withIdentifier: contentKeyUrlString,
                                                                            initializationData: nil,
                                                                            options: nil)
    }

    func processPendingCompletionsForContentKeyRequest(for keyRequest: AVContentKeyRequest, isReady: Bool) {
        guard let contentKey = host(fromContentKeyRequest: keyRequest) else {
            return
        }
        processPendingCompletionsForContentKey(for: contentKey, isReady: isReady)
    }
    
    func processPendingCompletionsForContentKey(for contentKey: String, isReady: Bool) {
        guard let completions = contentKeyToRequestCompletionsMap.removeValue(forKey: contentKey),
              completions.count > 0 else {
            return
        }
        for completion in completions {
            completion?(isReady)
        }
    }

    /// Returns whether or not a content key should be persistable on disk.
    ///
    /// - Parameter identifier: The asset ID associated with the content key request.
    /// - Returns: `true` if the content key request should be persistable, `false` otherwise.
    func shouldRequestPersistableContentKey(withIdentifier identifier: String) -> Bool {
        return pendingPersistableContentKeyIdentifiers.contains(identifier)
    }

    func host(fromContentKeyRequest keyRequest: AVContentKeyRequest) -> String? {
        guard let contentKeyIdentifierString = keyRequest.identifier as? String else {
            return nil
        }
        return host(fromUrlString: contentKeyIdentifierString)
    }
    
    func host(fromUrlString urlString: String) -> String? {
        guard let contentKeyIdentifierURL = URL(string: urlString) else {
            return nil
        }
        return contentKeyIdentifierURL.host
    }
    // MARK: AVContentKeySessionDelegate Methods

    /*
     The following delegate callback gets called when the client initiates a key request or AVFoundation
     determines that the content is encrypted based on the playlist the client provided when it requests playback.
     */
    func contentKeySession(_ session: AVContentKeySession, didProvide keyRequest: AVContentKeyRequest) {
        handleStreamingContentKeyRequest(keyRequest: keyRequest)
    }

    /*
     Provides the receiver with a new content key request representing a renewal of an existing content key.
     Will be invoked by an AVContentKeySession as the result of a call to -renewExpiringResponseDataForContentKeyRequest:.
     */
    func contentKeySession(_ session: AVContentKeySession, didProvideRenewingContentKeyRequest keyRequest: AVContentKeyRequest) {
        handleStreamingContentKeyRequest(keyRequest: keyRequest)
    }

    /*
     Provides the receiver a content key request that should be retried because a previous content key request failed.
     Will be invoked by an AVContentKeySession when a content key request should be retried. The reason for failure of
     previous content key request is specified. The receiver can decide if it wants to request AVContentKeySession to
     retry this key request based on the reason. If the receiver returns YES, AVContentKeySession would restart the
     key request process. If the receiver returns NO or if it does not implement this delegate method, the content key
     request would fail and AVContentKeySession would let the receiver know through
     -contentKeySession:contentKeyRequest:didFailWithError:.
     */
    func contentKeySession(_ session: AVContentKeySession, shouldRetry keyRequest: AVContentKeyRequest,
                           reason retryReason: AVContentKeyRequest.RetryReason) -> Bool {
        var shouldRetry = false

        switch retryReason {
        /*
         Indicates that the content key request should be retried because the key response was not set soon enough either
         due the initial request/response was taking too long, or a lease was expiring in the meantime.
         */
        case AVContentKeyRequest.RetryReason.timedOut:
            shouldRetry = true

        /*
         Indicates that the content key request should be retried because a key response with expired lease was set on the
         previous content key request.
         */
        case AVContentKeyRequest.RetryReason.receivedResponseWithExpiredLease:
            shouldRetry = true

        /*
         Indicates that the content key request should be retried because an obsolete key response was set on the previous
         content key request.
         */
        case AVContentKeyRequest.RetryReason.receivedObsoleteContentKey:
            shouldRetry = true

        default:
            break
        }

        return shouldRetry
    }

    // Informs the receiver a content key request has failed.
    func contentKeySession(_ session: AVContentKeySession, contentKeyRequest keyRequest: AVContentKeyRequest, didFailWithError err: Error) {
        // Add your code here to handle errors.
        switch err {
        case ProcessError.missingApplicationCertificate:
            logger?.errorLog(message: "Certificate Url is not provided")
        case ProcessError.missingLicenseServerUrl:
            logger?.errorLog(message: "License server url is not provided")
        case ProcessError.noCKCReturnedByKSM:
            logger?.errorLog(message: "Unable to fetch the CKC")
        case ProcessError.failedToRetrieveContentId:
            logger?.errorLog(message: "Failed to retrieve the assetID from the keyRequest")
        default:
            logger?.errorLog(message: (err as NSError).description)
            break
        }

        processPendingCompletionsForContentKeyRequest(for: keyRequest, isReady: false)
    }

    func contentKeySession(_ session: AVContentKeySession, contentKeyRequestDidSucceed keyRequest: AVContentKeyRequest) {
        logger?.debugLog(message: "Success fetching protected content")
    }
    
    // MARK: API

    func handleStreamingContentKeyRequest(keyRequest: AVContentKeyRequest) {
        guard let assetIDString = host(fromContentKeyRequest: keyRequest),
              let assetIDData = assetIDString.data(using: .utf8)
        else {
            logger?.errorLog(message: "Failed to retrieve the assetID from the keyRequest")
            return
        }

        // saving contentKey url for content url for future use if needed by offline content
        if let contentUrlString = contentKeyRequestParams?.contentUrlString,
           let contentKeyIdentifierString = keyRequest.identifier as? String {
            DispatchQueue.main.async {
                _ = FacadeConnector.connector?.storage?.sessionStorageSetValue(for: contentUrlString,
                                                                               value: contentKeyIdentifierString,
                                                                               namespace: self.contentKeyStorageNamespace)
            }
        }

        let provideOnlinekey: () -> Void = { () -> Void in

            do {
                let applicationCertificate = try self.requestApplicationCertificate()

                let completionHandler = { (spcData: Data?, error: Error?) in
                    if let error = error {
                        keyRequest.processContentKeyResponseError(error)
                        return
                    }

                    guard let spcData = spcData else { return }

                    do {
                        // Send SPC to Key Server and obtain CKC
                        let ckcData = try self.requestContentKeyFromKeySecurityModule(spcData: spcData, assetID: assetIDString)

                        /*
                         AVContentKeyResponse is used to represent the data returned from the key server when requesting a key for
                         decrypting content.
                         */
                        let keyResponse = AVContentKeyResponse(fairPlayStreamingKeyResponseData: ckcData)

                        /*
                         Provide the content key response to make protected content available for processing.
                         */
                        keyRequest.processContentKeyResponse(keyResponse)

                    } catch {
                        keyRequest.processContentKeyResponseError(error)
                    }
                }

                keyRequest.makeStreamingContentKeyRequestData(forApp: applicationCertificate,
                                                              contentIdentifier: assetIDData,
                                                              options: [AVContentKeyRequestProtocolVersionsKey: [1]],
                                                              completionHandler: completionHandler)
            } catch {
                keyRequest.processContentKeyResponseError(error)
            }
        }

        #if os(iOS)
            /*
             When you receive an AVContentKeyRequest via -contentKeySession:didProvideContentKeyRequest:
             and you want the resulting key response to produce a key that can persist across multiple
             playback sessions, you must invoke -respondByRequestingPersistableContentKeyRequest on that
             AVContentKeyRequest in order to signal that you want to process an AVPersistableContentKeyRequest
             instead. If the underlying protocol supports persistable content keys, in response your
             delegate will receive an AVPersistableContentKeyRequest via -contentKeySession:didProvidePersistableContentKeyRequest:.
             */
            if shouldRequestPersistableContentKey(withIdentifier: assetIDString) ||
                persistableContentKeyExists(withContentKeyIdentifier: assetIDString) {
                // Request a Persistable Key Request.
                do {
                    try keyRequest.respondByRequestingPersistableContentKeyRequestAndReturnError()
                } catch {
                    /*
                     This case will occur when the client gets a key loading request from an AirPlay Session.
                     You should answer the key request using an online key from your key server.
                     */
                    provideOnlinekey()
                }

                return
            }
        #endif

        provideOnlinekey()
    }
}
