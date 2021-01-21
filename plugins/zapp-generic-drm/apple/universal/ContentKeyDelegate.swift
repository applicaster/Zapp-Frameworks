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

class ContentKeyDelegate: NSObject, AVContentKeySessionDelegate {
    // MARK: Types

    enum ProcessError: Error {
        case missingApplicationCertificate
        case missingLicenseServerUrl
        case noCKCReturnedByKSM
    }

    // MARK: Properties

    var contentKeyRequestParams: ContentKeyRequestParams?
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
        let task = session.dataTask(with: request) { data, response, error in
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
        default:
            break
        }
    }

    func contentKeySession(_ session: AVContentKeySession, contentKeyRequestDidSucceed keyRequest: AVContentKeyRequest) {
        logger?.debugLog(message: "Success fetching protected content")
    }

    // MARK: API

    func handleStreamingContentKeyRequest(keyRequest: AVContentKeyRequest) {
        guard let contentKeyIdentifierString = keyRequest.identifier as? String,
              let contentKeyIdentifierURL = URL(string: contentKeyIdentifierString),
              let assetIDString = contentKeyIdentifierURL.host,
              let assetIDData = assetIDString.data(using: .utf8)
        else {
            logger?.errorLog(message: "Failed to retrieve the assetID from the keyRequest")
            return
        }

        let provideOnlinekey: () -> Void = { () -> Void in

            do {
                let applicationCertificate = try self.requestApplicationCertificate()

                let completionHandler = { [weak self] (spcData: Data?, error: Error?) in
                    guard let strongSelf = self else { return }
                    if let error = error {
                        keyRequest.processContentKeyResponseError(error)
                        return
                    }

                    guard let spcData = spcData else { return }

                    do {
                        // Send SPC to Key Server and obtain CKC
                        let ckcData = try strongSelf.requestContentKeyFromKeySecurityModule(spcData: spcData, assetID: assetIDString)

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

        provideOnlinekey()
    }
}
